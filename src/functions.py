import math
import random
import numpy as np

def calculate_cosine_similarity(user_profile, event_profile):
    if user_profile.shape != event_profile.shape:
        raise ValueError("User profile and event profile must have the same shape")
    
    dot_product = np.dot(user_profile, event_profile)

    user_magnitude = np.linalg.norm(user_profile)
    event_magnitude = np.linalg.norm(event_profile)

    if user_magnitude == 0 or event_magnitude == 0:
        return 0.0

    similarity = dot_product / (user_magnitude * event_magnitude)
    return similarity 

def generate_random_profile(size):
    return np.random.randint(0, 10, size=size).astype(float)

def calculate_new_user_info(current_user_profile, list_of_selected_events, lr=0.1):
    average_selected_vector = np.mean(list_of_selected_events, axis=0)
    print(f"Calculated average vector (first 5): {average_selected_vector[:5]}...")
    
    current_user_profile = np.array(current_user_profile)
    new_user_profile = (1.0 - lr) * current_user_profile + lr * average_selected_vector
    
    print(f"New user profile (first 5): {new_user_profile[:5]}...")
    
    return new_user_profile

if __name__ == "__main__":
    PROFILE_DIM = 10
    FIXED_LR = 0.1
    
    user_profile = generate_random_profile(PROFILE_DIM)
    selected_events = [] 

    print(f"Initial user profile (first 5): {user_profile[:5]}...")

    for _ in range(5): 
        selected_event = generate_random_profile(PROFILE_DIM)
        selected_events.append(selected_event)
        print(f"Selected event added. Total selected: {len(selected_events)}")
        user_profile = calculate_new_user_info(user_profile, selected_events, FIXED_LR)

    else:
        print("No events met the selection criteria.")