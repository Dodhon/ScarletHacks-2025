import asyncio

from crawl4ai import AsyncWebCrawler
from dotenv import load_dotenv

from config import BASE_URL, CSS_SELECTOR, REQUIRED_KEYS
from utils.data_utils import (
    save_events_to_csv,
)
from utils.scraper_utils import (
    fetch_and_process_page,
    get_browser_config,
    get_llm_strategy,
)

load_dotenv()


async def crawl_event():
    """
    Main function to crawl events data from the website.
    """
    # Initialize configurations
    browser_config = get_browser_config()
    llm_strategy = get_llm_strategy()
    session_id = "event_crawl_session"

    # Initialize state variables
    page_number = 1
    all_events = []
    seen_names = set()

    empty_pages = 0

    # Start the web crawler context
    # https://docs.crawl4ai.com/api/async-webcrawler/#asyncwebcrawler
    async with AsyncWebCrawler(config=browser_config) as crawler:
        while True:
            # Fetch and process data from the current page
            events, no_results_found = await fetch_and_process_page(
                crawler,
                page_number,
                BASE_URL,
                CSS_SELECTOR,
                llm_strategy,
                session_id,
                REQUIRED_KEYS,
                seen_names,
            )

            # if no_results_found:
            #     print("No more event found. Ending crawl.")
            #     break  # Stop crawling when "No Results Found" message appears

            # if not events:
            #     print(f"No event extracted from page {page_number}.")
            #     break  # Stop if no venues are extracted

            # # Add the venues from this page to the total list
            # all_events.extend(events)
            # page_number += 1  # Move to the next page

            # # Pause between requests to be polite and avoid rate limits
            # await asyncio.sleep(2)  # Adjust sleep time as needed

            if no_results_found or not events:
                empty_page_count += 1
                print(f" Page {page_number} was empty. (Consecutive empty pages: {empty_page_count})")
            else:
                empty_page_count = 0
                all_events.extend(events)

            if empty_page_count >= 2:
                print(" Reached two consecutive empty pages. Ending crawl.")
                break

            page_number += 1
            await asyncio.sleep(2)

    # Save the collected venues to a CSV file
    if all_events:
        save_events_to_csv(all_events, "event_list.csv")
        print(f"Saved {len(all_events)} event to 'event_list.csv'.")
    else:
        print("No event were found during the crawl.")

    # Display usage statistics for the LLM strategy
    llm_strategy.show_usage()


async def main():
    """
    Entry point of the script.
    """
    await crawl_event()


if __name__ == "__main__":
    asyncio.run(main())