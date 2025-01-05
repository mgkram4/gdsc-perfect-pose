import logging
import os
import unicodedata

import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def normalize_filename(filename):
    """Normalize filename to handle Unicode characters"""
    # Normalize Unicode characters
    normalized = unicodedata.normalize('NFKD', filename)
    # Remove any remaining non-ASCII characters
    normalized = normalized.encode('ASCII', 'ignore').decode()
    return normalized

def find_matching_file(files, pose_name):
    """Find a matching file for a pose, ignoring Unicode and case"""
    pose_variations = [
        pose_name,
        pose_name.replace(" ", "_"),
        pose_name.replace(" ", "")
    ]
    
    # Normalize all filenames and pose variations for comparison
    normalized_files = {normalize_filename(f).lower(): f for f in files}
    
    for variation in pose_variations:
        variation = variation.lower()
        for norm_file in normalized_files.keys():
            if variation in norm_file:
                return normalized_files[norm_file]
    return None

def get_base_process_dir():
    """Get the correct base directory for processed files"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(current_dir, "data", "process")

def load_poses(category, pose_list, pose_analyzer):
    """Generic pose loader that handles all categories"""
    process_dir = os.path.join(get_base_process_dir(), category)
    
    logger.info(f"Looking for {category} poses in: {process_dir}")
    
    if not os.path.exists(process_dir):
        logger.error(f"Process directory not found: {process_dir}")
        return
    
    all_files = [f for f in os.listdir(process_dir) if f.endswith('_static.npy')]
    logger.info(f"Found {len(all_files)} .npy files for {category}")
    
    for pose in pose_list:
        matching_file = find_matching_file(all_files, pose)
        
        if matching_file:
            file_path = os.path.join(process_dir, matching_file)
            try:
                landmarks = np.load(file_path)
                if len(landmarks.shape) > 1:
                    landmarks = landmarks[0]
                pose_analyzer.add_pose(category, pose, landmarks)
                logger.info(f"Successfully loaded pose data for {pose} from {file_path}")
            except Exception as e:
                logger.error(f"Failed to load pose data for {pose}: {str(e)}")
        else:
            logger.warning(f"No matching .npy files found for pose: {pose}")
            logger.warning(f"Available files: {all_files}")