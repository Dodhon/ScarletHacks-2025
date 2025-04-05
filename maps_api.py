import os
import math
import requests
from dotenv import load_dotenv

load_dotenv()

def geocode_address(address: str) -> dict:
    """
    Geocode an address using the Google Maps Geocoding API.
    
    Args:
        address (str): The full address to geocode.
        
    Returns:
        dict: A dictionary with keys 'lat' and 'lng' representing the coordinates.
    
    Raises:
        Exception: If the API call fails or no results are found.
    """
    api_key = os.getenv("MAPS_API_KEY")
    if not api_key:
        raise Exception("MAPS_API_KEY not set in environment")
    
    encoded_address = requests.utils.quote(address)
    url = f"https://maps.googleapis.com/maps/api/geocode/json?address={encoded_address}&key={api_key}"
    
    response = requests.get(url)
    data = response.json()
    
    if data.get("status") == "OK" and data.get("results"):
        return data["results"][0]["geometry"]["location"]
    else:
        raise Exception("Geocoding API error: " + data.get("status", "Unknown error"))

def calculate_distance(coord1: dict, coord2: dict) -> float:
    """
    Calculate the distance in miles between two coordinate points using the Haversine formula.
    
    Args:
        coord1 (dict): Dictionary with 'lat' and 'lng' keys for the first location.
        coord2 (dict): Dictionary with 'lat' and 'lng' keys for the second location.
    
    Returns:
        float: The distance in miles.
    """
    R = 3958.8

    lat1, lng1 = math.radians(coord1["lat"]), math.radians(coord1["lng"])
    lat2, lng2 = math.radians(coord2["lat"]), math.radians(coord2["lng"])
    
    dlat = lat2 - lat1
    dlng = lng2 - lng1
    
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

def get_real_user_location() -> dict:
    """
    Get the user's real location using an IP geolocation service (ipinfo.io).
    This method retrieves the public IP's approximate location.
    
    Returns:
        dict: A dictionary with 'lat' and 'lng' keys.
    """
    try:
        response = requests.get("https://ipinfo.io/json")
        data = response.json()
        loc_str = data.get("loc")
        if loc_str:
            lat, lng = map(float, loc_str.split(","))
            return {"lat": lat, "lng": lng}
        else:
            raise Exception("Location not found in response.")
    except Exception as e:
        raise Exception("Error retrieving real location: " + str(e))

def test_distance_calculation():
    """
    Testing function that:
      - Retrieves the user's real location using an IP-based service.
      - Geocodes a sample organization address.
      - Calculates and prints the distance (in miles) between them.
    """
    organization_address = "4100 W. Ann Lurie Place Chicago, IL 60632"
    
    try:
        user_location = get_real_user_location()
        print("User real location:", user_location)
        
        org_location = geocode_address(organization_address)
        print("Organization location:", org_location)
        
        distance_miles = calculate_distance(user_location, org_location)
        print(f"Distance between user and organization: {distance_miles:.2f} miles")
    except Exception as e:
        print("Error during test_distance_calculation:", e)

if __name__ == "__main__":
    test_distance_calculation()
