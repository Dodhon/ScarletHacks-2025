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

def calculate_new_user_info(current_user_profile, selected_event, lr=0.1):
    current_user_profile = np.array(current_user_profile)
    new_user_profile = (1.0 - lr) * current_user_profile + lr * selected_event
    
    return new_user_profile

if __name__ == "__main__":
    PROFILE_DIM = 10
    FIXED_LR = 0.1
    NUM_AVAILABLE_EVENTS = 15 
    NUM_ITERATIONS = 5 
    
    # Initialize user profil
    user_profile = generate_random_profile(PROFILE_DIM)

    available_events = [generate_random_profile(PROFILE_DIM) for _ in range(NUM_AVAILABLE_EVENTS)]

    for i in range(NUM_ITERATIONS):
    
        similarities = [calculate_cosine_similarity(user_profile, event) for event in available_events]

        
        most_similar_event_index = np.argmax(similarities)
        selected_event = available_events[most_similar_event_index]
        highest_similarity = similarities[most_similar_event_index]

        
        user_profile = calculate_new_user_info(user_profile, selected_event, FIXED_LR)

    print(f"\nFinal user profile after {NUM_ITERATIONS} iterations (first 5): {user_profile[:5]}...")