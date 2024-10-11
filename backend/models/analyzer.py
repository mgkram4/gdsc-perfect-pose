import logging

import numpy as np
from utils.process_img import extract_pose_landmarks
from scipy.spatial.distance import cosine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PoseAnalyzer:
    def __init__(self):
        self.pose_databases = {
            'yoga': {},
            'lifting': {},
            'bodyweight': {},
            'functional': {}
        }

    def add_pose(self, category, pose_name, landmarks):
        if category not in self.pose_databases:
            raise ValueError(f"Invalid category: {category}")
        if landmarks is None:
            logger.warning(f"No landmarks detected for {pose_name} in {category}")
            return
        self.pose_databases[category][pose_name] = landmarks
        logger.info(f"Added {pose_name} to {category}")

    def calculate_similarity(self, user_landmarks, category, pose_name):
        if category not in self.pose_databases or pose_name not in self.pose_databases[category]:
            raise ValueError(f"Pose {pose_name} not found in category {category}")
        
        user_landmarks = np.asarray(user_landmarks).flatten()
        pro_landmarks = np.asarray(self.pose_databases[category][pose_name]).flatten()
        
        similarity = 1 - cosine(user_landmarks, pro_landmarks)
        return similarity

    def get_angle_differences(self, user_landmarks, category, pose_name):
        pro_landmarks = self.pose_databases[category][pose_name]
        user_landmarks = np.asarray(user_landmarks).reshape(-1, 3)
        pro_landmarks = np.asarray(pro_landmarks).reshape(-1, 3)

        angle_diffs = {}
        key_joints = [
            ("Right Elbow", 13, 11, 15),
            ("Left Elbow", 14, 12, 16),
            ("Right Shoulder", 11, 13, 23),
            ("Left Shoulder", 12, 14, 24),
            ("Right Hip", 23, 25, 11),
            ("Left Hip", 24, 26, 12),
            ("Right Knee", 25, 23, 27),
            ("Left Knee", 26, 24, 28),
            ("Right Ankle", 27, 25, 31),
            ("Left Ankle", 28, 26, 32),
            ("Neck", 11, 12, 0),
            ("Right Wrist", 15, 13, 17),
            ("Left Wrist", 16, 14, 18),
            ("Spine", 23, 24, 7),
        ]

        for joint_name, p1, p2, p3 in key_joints:
            user_angle = self.calculate_angle(user_landmarks[p1], user_landmarks[p2], user_landmarks[p3])
            pro_angle = self.calculate_angle(pro_landmarks[p1], pro_landmarks[p2], pro_landmarks[p3])
            angle_diffs[joint_name] = pro_angle - user_angle

        return angle_diffs

    def calculate_angle(self, p1, p2, p3):
        v1 = p1 - p2
        v2 = p3 - p2
        angle = np.arccos(np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2)))
        return np.degrees(angle)

    def analyze_user_pose(self, image_path, category, pose_name):
        user_landmarks = extract_pose_landmarks(image_path)
        if user_landmarks is None:
            return {"error": "Failed to extract pose landmarks from the image"}

        similarity_score = self.calculate_similarity(user_landmarks, category, pose_name)
        angle_differences = self.get_angle_differences(user_landmarks, category, pose_name)

        suggestions = self.generate_suggestions(angle_differences)

        return {
            "category": category,
            "pose": pose_name,
            "similarity_score": similarity_score,
            "angle_differences": angle_differences,
            "suggestions": suggestions
        }

    def generate_suggestions(self, angle_differences):
        suggestions = []
        for joint, diff in angle_differences.items():
            if abs(diff) > 10:  # Threshold for suggesting adjustments
                direction = "increase" if diff > 0 else "decrease"
                suggestions.append(f"{direction} {joint.lower()} angle by about {abs(diff):.1f} degrees")
        return suggestions

    def load_pose_database(self, category, filename):
        self.pose_databases[category] = np.load(filename, allow_pickle=True).item()

    def save_pose_database(self, category, filename):
        np.save(filename, self.pose_databases[category])