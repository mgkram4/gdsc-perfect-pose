# backend/models/analyzer.py

import logging

import numpy as np
from scipy.spatial.distance import cosine
from tensorflow import keras
from utils.process_img import (extract_angles, extract_pose_landmarks,
                               normalize_landmarks)

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
        
        # Load enhanced model
        try:
            # Try both locations for the model
            model_paths = [
                'models/saved/pose_model.keras',
                '../models/models/saved/advanced_80_percent_model_20250622_160937.keras',
                '../../models/models/saved/advanced_80_percent_model_20250622_160937.keras'
            ]
            
            self.model = None
            for path in model_paths:
                try:
                    self.model = keras.models.load_model(path)
                    logger.info(f"Loaded enhanced pose model from: {path}")
                    break
                except:
                    continue
                    
            self.model_available = self.model is not None
            if not self.model_available:
                logger.warning("Could not load any enhanced model - using geometric analysis only")
        except Exception as e:
            logger.warning(f"Could not load enhanced model: {e}")
            self.model_available = False

    def analyze_user_pose(self, image_path, category, pose_name):
        """Analyze user's pose using both geometric and ML approaches"""
        user_landmarks = extract_pose_landmarks(image_path)
        if user_landmarks is None:
            return {"error": "Failed to extract pose landmarks from the image"}

        # Normalize landmarks
        normalized_landmarks = normalize_landmarks(user_landmarks)
        if normalized_landmarks is None:
            return {"error": "Failed to normalize landmarks"}

        # Get traditional similarity score
        similarity_score = self.calculate_similarity(user_landmarks, category, pose_name)
        
        # Get angle differences
        angle_differences = self.get_angle_differences(user_landmarks, category, pose_name)

        # Get model prediction if available
        model_prediction = None
        final_score = similarity_score  # Default to geometric similarity
        
        if self.model_available and self.model is not None:
            try:
                # Prepare input for model (assuming model expects flattened landmarks)
                model_input = normalized_landmarks.reshape(1, -1)  # Shape: (1, total_features)
                prediction = self.model.predict(model_input, verbose=0)
                
                # For classification model, get the probability for the correct category
                category_index = list(self.pose_databases.keys()).index(category)
                model_prediction = float(prediction[0][category_index])
                
                # Combine geometric and ML scores (weighted average)
                final_score = 0.3 * similarity_score + 0.7 * model_prediction
                logger.info(f"Combined score: geometric={similarity_score:.3f}, ml={model_prediction:.3f}, final={final_score:.3f}")
                
            except Exception as e:
                logger.error(f"Model prediction error: {e}")
                model_prediction = None

        # Generate suggestions
        suggestions = self.generate_suggestions(angle_differences)

        return {
            "category": category,
            "pose": pose_name,
            "similarity_score": final_score,  # Frontend expects this field
            "geometric_score": similarity_score,
            "model_score": model_prediction,
            "angle_differences": angle_differences,
            "suggestions": suggestions
        }

    def calculate_similarity(self, user_landmarks, category, pose_name):
        """Calculate geometric similarity between user pose and reference pose"""
        if category not in self.pose_databases or pose_name not in self.pose_databases[category]:
            return 0.0
            
        user_landmarks = np.array(user_landmarks).flatten()
        pro_landmarks = np.array(self.pose_databases[category][pose_name]).flatten()
        
        return 1 - cosine(user_landmarks, pro_landmarks)

    def get_angle_differences(self, user_landmarks, category, pose_name):
        """Calculate angle differences between user pose and reference pose"""
        if category not in self.pose_databases or pose_name not in self.pose_databases[category]:
            return {}
            
        user_angles = extract_angles(user_landmarks)
        pro_angles = extract_angles(self.pose_databases[category][pose_name])
        
        if not user_angles or not pro_angles:
            return {}
            
        return {
            joint: pro_angles[joint] - user_angles[joint]
            for joint in user_angles.keys()
        }

    def generate_suggestions(self, angle_differences):
        """Generate improvement suggestions based on angle differences"""
        suggestions = []
        for joint, diff in angle_differences.items():
            if abs(diff) > 15:  # Threshold for suggestions
                direction = "increase" if diff > 0 else "decrease"
                suggestions.append(f"{direction} {joint.replace('_', ' ')} angle by about {abs(diff):.1f} degrees")
        return suggestions

    def add_pose(self, category, pose_name, landmarks):
        """Add a reference pose to the database"""
        if category not in self.pose_databases:
            raise ValueError(f"Invalid category: {category}")
        if landmarks is None:
            logger.warning(f"No landmarks detected for {pose_name} in {category}")
            return
        self.pose_databases[category][pose_name] = landmarks
        logger.info(f"Added {pose_name} to {category}")