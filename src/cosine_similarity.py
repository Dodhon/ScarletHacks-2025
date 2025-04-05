import math
def cosine_similarity(user_profile, event_profile):
    return calculate_cosine_similarity(user_profile, event_profile)

def calculate_cosine_similarity(user_profile, event_profile):
    if len(user_profile) != len(event_profile):
        raise ValueError("User profile and event profile must have the same length")
    
    dot_product = []
    for user_info, event_info in zip(user_profile, event_profile):
        dot_product.append(user_info * event_info)
    
    user_magnitude = math.sqrt(sum(user_info ** 2 for user_info in user_profile))
    event_magnitude = math.sqrt(sum(event_info ** 2 for event_info in event_profile))

    return dot_product / (user_magnitude * event_magnitude)



