import numpy as np
from app.utils.image_processor import extract_pose_landmarks

LIFTING_POSES = ["Squat"]

def load_lifting_poses(pose_analyzer):
    for pose in LIFTING_POSES:
        landmarks = load_landmarks_from_file(f"data/lifting/{pose}.jpg")
        pose_analyzer.add_pose("lifting", pose, landmarks)

def load_landmarks_from_file(filename):
    return extract_pose_landmarks(filename)