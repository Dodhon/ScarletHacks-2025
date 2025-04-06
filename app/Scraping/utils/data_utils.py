import csv

from models.event import Event


def is_duplicate_event(event_name: str, seen_names: set) -> bool:
    return event_name in seen_names


def is_complete_event(event: dict, required_keys: list) -> bool:
    return all(key in event for key in required_keys)


def save_events_to_csv(events: list, filename: str):
    if not events:
        print("No events to save.")
        return

    # Use field names from the Venue model
    fieldnames = Event.model_fields.keys()

    with open(filename, mode="w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(events)
    print(f"Saved {len(events)} event to '{filename}'.")