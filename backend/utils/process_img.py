import cv2
import mediapipe as mp

mp_pose = mp.solutions.pose

def extract_pose_landmarks(image_path):
    image = cv2.imread(image_path)
    with mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5) as pose:
        results = pose.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
        
    if results.pose_landmarks:
        landmarks = [[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark]
        return landmarks
    else:
        return None