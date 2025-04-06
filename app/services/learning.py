import logging
import numpy as np
from typing import List

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def update_user_embedded_vector(current_vector: List[float],event_vector: List[float],swipe: bool,alpha: float = 0.1) -> List[float]:
    """
    Updates a user's embedded vector using an exponential moving average,
    based on the event vector and the swipe direction.
                       
    Returns:
        List[float]: The updated user embedded vector.
    """
    try:
        current_arr = np.array(current_vector)
        event_arr = np.array(event_vector)
        
        if current_arr.shape != event_arr.shape:
            logging.error("Shape mismatch: current vector and event vector must have the same dimensions.")
            return current_vector
        
        if swipe:
            updated_arr = (1 - alpha) * current_arr + alpha * event_arr
        elif not swipe:
            updated_arr = (1 - alpha) * current_arr - alpha * event_arr
        else:
            return None
        updated_vector = updated_arr.tolist()
        logging.info("User embedded vector updated successfully.")
        return updated_vector
    
    except Exception as e:
        logging.error(f"Error updating embedded vector: {e}")
        return current_vector

