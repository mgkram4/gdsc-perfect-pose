# backend/utils/process_img.py

import logging
import os

import cv2
import mediapipe as mp
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

mp_pose = mp.solutions.pose

def extract_pose_landmarks(image_path):
    """Extract pose landmarks from an image using MediaPipe"""
    if not os.path.exists(image_path):
        logger.error(f"Image file does not exist: {image_path}")
        return None

    image = cv2.imread(image_path)
    if image is None:
        logger.error(f"Failed to read image: {image_path}")
        return None

    with mp_pose.Pose(
        static_image_mode=True,
        model_complexity=2,
        min_detection_confidence=0.5
    ) as pose:
        try:
            results = pose.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
        except Exception as e:
            logger.error(f"Error processing image: {e}")
            return None
        
    if results.pose_landmarks:
        landmarks = [[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark]
        return np.array(landmarks)
    else:
        logger.warning(f"No pose landmarks detected in: {image_path}")
        return None

def normalize_landmarks(landmarks):
    """Normalize landmarks to be invariant to scale and position"""
    if landmarks is None:
        return None
        
    # Convert to numpy array if not already
    landmarks = np.array(landmarks)
    
    # Calculate center and scale
    center = np.mean(landmarks[:, :2], axis=0)
    scale = np.max(np.abs(landmarks[:, :2] - center))
    
    # Normalize
    normalized = landmarks.copy()
    normalized[:, :2] = (landmarks[:, :2] - center) / scale
    
    return normalized

def extract_angles(landmarks):
    """Extract joint angles from landmarks"""
    if landmarks is None:
        return None
        
    angles = {}
    
    # Define joint connections for angle calculation
    joint_connections = {
        'right_elbow': [12, 14, 16],  # shoulder, elbow, wrist
        'left_elbow': [11, 13, 15],
        'right_shoulder': [14, 12, 24],  # elbow, shoulder, hip
        'left_shoulder': [13, 11, 23],
        'right_hip': [12, 24, 26],  # shoulder, hip, knee
        'left_hip': [11, 23, 25],
        'right_knee': [24, 26, 28],  # hip, knee, ankle
        'left_knee': [23, 25, 27]
    }
    
    for joint_name, (p1, p2, p3) in joint_connections.items():
        angle = calculate_angle(
            landmarks[p1],
            landmarks[p2],
            landmarks[p3]
        )
        angles[joint_name] = angle
        
    return angles

def calculate_angle(p1, p2, p3):
    """Calculate the angle between three points"""
    v1 = p1 - p2
    v2 = p3 - p2
    
    cos_angle = np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))
    angle = np.arccos(np.clip(cos_angle, -1.0, 1.0))
    
    return np.degrees(angle)

def process_video_file(video_path):
    """Process video file and extract pose sequences"""
    if not os.path.exists(video_path):
        logger.error(f"Video file does not exist: {video_path}")
        return None
        
    cap = cv2.VideoCapture(video_path)
    landmarks_sequence = []
    
    with mp_pose.Pose(
        static_image_mode=False,
        model_complexity=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5
    ) as pose:
        while cap.isOpened():
            success, frame = cap.read()
            if not success:
                break
                
            try:
                results = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                if results.pose_landmarks:
                    landmarks = [[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark]
                    landmarks_sequence.append(landmarks)
            except Exception as e:
                logger.error(f"Error processing frame: {e}")
                continue
                
    cap.release()
    return np.array(landmarks_sequence) if landmarks_sequence else None