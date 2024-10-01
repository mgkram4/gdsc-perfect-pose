import numpy as np
from app.utils.image_processor import extract_pose_landmarks

BODYWEIGHT_POSES = ["Push-up"]

def load_bodyweight_poses(pose_analyzer):
    for pose in BODYWEIGHT_POSES:
        landmarks = load_landmarks_from_file(f"data/bodyweight/{pose}.jpg")
        pose_analyzer.add_pose("bodyweight", pose, landmarks)

def load_landmarks_from_file(filename):
    return extract_pose_landmarks(filename)