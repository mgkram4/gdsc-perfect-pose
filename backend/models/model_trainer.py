# model_trainer.py
import logging
import os
from collections import defaultdict
from pathlib import Path

import cv2
import mediapipe as mp
import numpy as np
from models.cnn_lstm import PoseModelTrainer

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PoseDataPreprocessor:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose_detector = self.mp_pose.Pose(
            static_image_mode=True,
            model_complexity=2,
            min_detection_confidence=0.5
        )
        # Define the 17 key points we want to use
        self.keypoint_indices = [
            0,   # nose
            11,  # left shoulder
            12,  # right shoulder
            13,  # left elbow
            14,  # right elbow
            15,  # left wrist
            16,  # right wrist
            23,  # left hip
            24,  # right hip
            25,  # left knee
            26,  # right knee
            27,  # left ankle
            28,  # right ankle
            29,  # left heel
            30,  # right heel
            31,  # left foot index
            32   # right foot index
        ]
        
    def extract_pose_from_image(self, image):
        """Extract pose landmarks from a single image"""
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = self.pose_detector.process(rgb_image)
        
        if not results.pose_landmarks:
            return None
            
        # Extract only the 17 key landmarks we want (51 features total)
        landmarks = []
        for idx in self.keypoint_indices:
            landmark = results.pose_landmarks.landmark[idx]
            landmarks.extend([landmark.x, landmark.y, landmark.z])
        
        landmarks_array = np.array(landmarks)
        if landmarks_array.shape[0] != 51:  # Validation check
            logger.error(f"Incorrect number of features: {landmarks_array.shape[0]}")
            return None
            
        return landmarks_array

    def process_video(self, video_path, sequence_length=30):
        """Extract pose landmarks from video"""
        cap = cv2.VideoCapture(str(video_path))
        landmarks_sequence = []
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            landmarks = self.extract_pose_from_image(frame)
            if landmarks is not None:
                landmarks_sequence.append(landmarks)
                frame_count += 1
                
            if frame_count >= sequence_length:
                break  # Stop once we have enough frames
                
        cap.release()
        
        if len(landmarks_sequence) == 0:
            return None
            
        # Handle sequence length
        if len(landmarks_sequence) < sequence_length:
            padding = [landmarks_sequence[-1]] * (sequence_length - len(landmarks_sequence))
            landmarks_sequence.extend(padding)
        elif len(landmarks_sequence) > sequence_length:
            landmarks_sequence = landmarks_sequence[:sequence_length]
            
        sequence = np.array(landmarks_sequence)
        if sequence.shape != (sequence_length, 51):  # Validation check
            logger.error(f"Incorrect sequence shape: {sequence.shape}")
            return None
            
        return sequence

class ModelTrainer:
    def __init__(self, data_dir='data/poses', processed_dir='data/processed'):
        self.data_dir = Path(data_dir)
        self.processed_dir = Path(processed_dir)
        self.categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        self.preprocessor = PoseDataPreprocessor()
        self.pose_types = self._get_pose_types()
        
        # Create model trainer after ensuring directories
        self.model_trainer = PoseModelTrainer(
            processed_dir=processed_dir,
            sequence_length=30,
            num_features=51  # 17 landmarks × 3 coordinates
        )
        
        # Ensure model save directory exists
        Path('models/saved').mkdir(parents=True, exist_ok=True)
        
    def _get_pose_types(self):
        """Map each category to its pose types from the directory structure"""
        pose_types = defaultdict(list)
        
        # First, ensure all category directories exist
        for category in self.categories:
            category_dir = self.data_dir / category
            processed_dir = self.processed_dir / category
            
            # Create directories if they don't exist
            category_dir.mkdir(parents=True, exist_ok=True)
            processed_dir.mkdir(parents=True, exist_ok=True)
            
            # Get subdirectories as pose types
            subdirs = [d for d in category_dir.iterdir() if d.is_dir() and not d.name.startswith('.')]
            if not subdirs:
                logger.warning(f"No pose type subdirectories found in {category_dir}")
                pose_types[category] = []
            else:
                pose_types[category] = [d.name for d in subdirs]
                logger.info(f"Found poses for {category}: {pose_types[category]}")
        
        return dict(pose_types)

    def preprocess_data(self):
        """Preprocess both image and video data into pose sequences"""
        logger.info("Starting data preprocessing...")
        processed_count = 0
        
        for category in self.categories:
            category_source = self.data_dir / category
            category_processed = self.processed_dir / category
            
            if not category_source.exists():
                logger.warning(f"Source directory not found for category: {category}")
                continue
                
            if category not in self.pose_types or not self.pose_types[category]:
                logger.warning(f"No pose types found for category: {category}")
                continue
                
            for pose_type in self.pose_types[category]:
                pose_dir = category_source / pose_type
                if not pose_dir.exists():
                    logger.warning(f"Pose directory not found: {pose_dir}")
                    continue
                
                # Count files to process
                image_files = list(pose_dir.glob('*.[jp][pn][g]'))  # jpg, jpeg, png
                video_files = list(pose_dir.glob('*.mp4')) + list(pose_dir.glob('*.avi')) + list(pose_dir.glob('*.mov'))
                
                logger.info(f"Processing {len(image_files)} images and {len(video_files)} videos for {category}/{pose_type}")
                
                # Process images
                for file_path in image_files:
                    if self._process_image(file_path, category_processed, pose_type):
                        processed_count += 1
                
                # Process videos
                for file_path in video_files:
                    if self._process_video(file_path, category_processed, pose_type):
                        processed_count += 1
        
        logger.info(f"Preprocessing completed. Successfully processed {processed_count} files.")
        return processed_count > 0

    def _process_image(self, image_path, output_dir, pose_type):
        """Process single image and save pose data"""
        try:
            image = cv2.imread(str(image_path))
            if image is None:
                logger.error(f"Failed to load image: {image_path}")
                return False
                
            landmarks = self.preprocessor.extract_pose_from_image(image)
            if landmarks is not None:
                sequence = np.repeat(landmarks[np.newaxis, :], 30, axis=0)
                output_path = output_dir / f"{pose_type}_{image_path.stem}_static.npy"
                np.save(str(output_path), sequence)
                logger.info(f"Processed image: {image_path}")
                return True
            else:
                logger.warning(f"No pose detected in image: {image_path}")
                return False
        except Exception as e:
            logger.error(f"Error processing image {image_path}: {e}")
            return False

    def _process_video(self, video_path, output_dir, pose_type):
        """Process video and save pose sequence data"""
        try:
            sequence = self.preprocessor.process_video(video_path)
            if sequence is not None:
                output_path = output_dir / f"{pose_type}_{video_path.stem}_sequence.npy"
                np.save(str(output_path), sequence)
                logger.info(f"Processed video: {video_path}")
                return True
            else:
                logger.warning(f"No poses detected in video: {video_path}")
                return False
        except Exception as e:
            logger.error(f"Error processing video {video_path}: {e}")
            return False

    def train(self, epochs=50, batch_size=32, validation_split=0.2):
        """Run the full training pipeline"""
        # First preprocess all data
        if not self.preprocess_data():
            logger.error("No data was successfully preprocessed. Cannot proceed with training.")
            return None
        
        # Train using existing PoseModelTrainer
        logger.info("Starting model training...")
        try:
            history = self.model_trainer.train_model(
                epochs=epochs,
                batch_size=batch_size,
                validation_split=validation_split
            )
            
            # Save the trained model
            self.model_trainer.save_model('models/saved/pose_model.keras')
            logger.info("Model saved successfully!")
            
            return history
        except Exception as e:
            logger.error(f"Training failed: {str(e)}")
            return None

def main():
    """Main function to run the training pipeline"""
    trainer = ModelTrainer()
    
    try:
        history = trainer.train()
        if history is not None:
            logger.info("Training completed successfully!")
        else:
            logger.error("Training failed - no data to train on")
    except Exception as e:
        logger.error(f"Training failed: {str(e)}")
        raise

if __name__ == "__main__":
    main()