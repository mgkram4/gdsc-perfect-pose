import numpy as np
from .utils.process_img.py import extract_pose_landmarks

YOGA_POSES = ["Downward Dog"]

def load_yoga_poses(pose_analyzer):
    for pose in YOGA_POSES:
        landmarks = load_landmarks_from_file(f"data/yoga/{pose}.jpg")
        pose_analyzer.add_pose("yoga", pose, landmarks)

def load_landmarks_from_file(filename):
    return extract_pose_landmarks(filename)