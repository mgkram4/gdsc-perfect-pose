import os
import numpy as np
from utils.process_img import extract_pose_landmarks
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

LIFTING_POSES = ["Bench", "Deadlift", "Squat"]

def load_lifting_poses(pose_analyzer):
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for pose in LIFTING_POSES:
        pose_dir = os.path.join(base_dir, "data", "poses", "lifting", pose)
        if os.path.isdir(pose_dir):
            image_files = [f for f in os.listdir(pose_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
            if image_files:
                file_path = os.path.join(pose_dir, image_files[0])
                logger.info(f"Attempting to load pose: {pose}")
                logger.info(f"File path: {file_path}")
                landmarks = load_landmarks_from_file(file_path)
                if landmarks is not None:
                    pose_analyzer.add_pose("lifting", pose, landmarks)
                    logger.info(f"Successfully added pose: {pose}")
                else:
                    logger.warning(f"Failed to load landmarks for {pose}")
            else:
                logger.warning(f"No image files found for pose: {pose}")
        else:
            logger.warning(f"Directory not found for pose: {pose}")

def load_landmarks_from_file(filename):
    if not os.path.exists(filename):
        logger.error(f"File does not exist: {filename}")
        return None
    
    if not os.access(filename, os.R_OK):
        logger.error(f"File is not readable: {filename}")
        return None
    
    landmarks = extract_pose_landmarks(filename)
    if landmarks is None:
        logger.error(f"Failed to extract landmarks from: {filename}")
    else:
        logger.info(f"Successfully extracted landmarks from: {filename}")
    return landmarks