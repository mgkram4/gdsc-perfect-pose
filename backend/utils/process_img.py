import os

import cv2
import mediapipe as mp

mp_pose = mp.solutions.pose

def extract_pose_landmarks(image_path):
    print(f"Attempting to read image: {image_path}")
    
    if not os.path.exists(image_path):
        print(f"Error: Image file does not exist: {image_path}")
        return None

    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: Failed to read image: {image_path}")
        return None
    
    if image.size == 0:
        print(f"Error: Image is empty: {image_path}")
        return None

    print(f"Image shape: {image.shape}")

    with mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5) as pose:
        try:
            results = pose.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
        except Exception as e:
            print(f"Error processing image: {e}")
            return None
        
    if results.pose_landmarks:
        landmarks = [[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark]
        return landmarks
    else:
        print(f"No pose landmarks detected in: {image_path}")
        return None