import numpy as np
from app.utils.image_processor import extract_pose_landmarks

FUNCTIONAL_POSES = ["Lunge"]

def load_functional_poses(pose_analyzer):
    for pose in FUNCTIONAL_POSES:
        landmarks = load_landmarks_from_file(f"data/functional/{pose}.jpg")
        pose_analyzer.add_pose("functional", pose, landmarks)

def load_landmarks_from_file(filename):
    return extract_pose_landmarks(filename)