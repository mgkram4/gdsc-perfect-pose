import logging
import os
import unicodedata

import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

FUNCTIONAL_POSES = ["Lunge", "Mountain Climber"]

def load_functional_poses(pose_analyzer):
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    process_dir = os.path.join(base_dir, "data", "process", "functional")
    
    if not os.path.exists(process_dir):
        logger.error(f"Process directory not found: {process_dir}")
        return
    
    all_files = [f for f in os.listdir(process_dir) if f.endswith('_static.npy')]
    logger.info(f"Found {len(all_files)} .npy files in directory")
    
    for pose in FUNCTIONAL_POSES:
        # Convert pose name to match file naming convention and handle Unicode
        pose_prefix = pose.replace(" ", "_")
        # Normalize and lower-case for comparison
        pose_prefix_norm = unicodedata.normalize('NFKD', pose_prefix).lower()
        
        # Find matching files, handling Unicode
        matching_files = []
        for f in all_files:
            f_norm = unicodedata.normalize('NFKD', f).lower()
            if pose_prefix_norm in f_norm:
                matching_files.append(f)
        
        if matching_files:
            file_path = os.path.join(process_dir, matching_files[0])
            try:
                landmarks = np.load(file_path)
                if len(landmarks.shape) > 1:
                    landmarks = landmarks[0]
                pose_analyzer.add_pose("functional", pose, landmarks)
                logger.info(f"Successfully loaded pose data for {pose} from {file_path}")
            except Exception as e:
                logger.error(f"Failed to load pose data for {pose}: {str(e)}")
        else:
            logger.warning(f"No matching .npy files found for pose: {pose}")
            logger.warning(f"Available files: {all_files}")