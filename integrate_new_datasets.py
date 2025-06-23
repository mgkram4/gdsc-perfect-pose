#!/usr/bin/env python3
"""
Perfect Pose - New Dataset Integration
Integrates newly downloaded Kaggle datasets with existing training pipeline
"""

import logging
import os
import shutil
from pathlib import Path

import cv2
import mediapipe as mp
import numpy as np
from utils.pose_utils import extract_pose_keypoints, process_video_sequence

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatasetIntegrator:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=True,
            model_complexity=1,
            enable_segmentation=False,
            min_detection_confidence=0.5
        )
        
        # Path configurations
        self.new_datasets_path = Path("../datasets/downloaded")
        self.processed_data_path = Path("models/data/process")
        self.images_path = Path("models/data/images")
        
        # Category mapping
        self.category_mapping = {
            'yoga': 'yoga',
            'exercise': 'bodyweight', 
            'workout': 'functional'
        }
        
    def count_available_data(self):
        """Count how much new data we have"""
        print("\n" + "="*60)
        print("📊 NEW DATASET ANALYSIS")
        print("="*60)
        
        total_files = 0
        for category in ['yoga', 'exercise', 'workout']:
            cat_path = self.new_datasets_path / category
            if cat_path.exists():
                files = sum([len(files) for r, d, files in os.walk(cat_path)])
                pose_types = len([d for d in cat_path.iterdir() if d.is_dir()])
                print(f"✅ {category.upper()}: {pose_types} pose types, {files} files")
                total_files += files
            else:
                print(f"❌ {category.upper()}: Not found")
        
        print(f"\n📊 TOTAL NEW DATA: {total_files} images")
        return total_files
    
    def process_image_to_keypoints(self, image_path, max_images_per_pose=50):
        """Process a single image to pose keypoints"""
        try:
            # Read image
            image = cv2.imread(str(image_path))
            if image is None:
                return None
                
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Process with MediaPipe
            results = self.pose.process(image_rgb)
            
            if results.pose_landmarks:
                # Extract keypoints
                keypoints = extract_pose_keypoints(results.pose_landmarks.landmark)
                
                # Convert to sequence format (repeat for 30 timesteps like existing data)
                sequence = np.tile(keypoints, (30, 1))
                return sequence
            
            return None
            
        except Exception as e:
            logger.warning(f"Failed to process {image_path}: {e}")
            return None
    
    def integrate_category(self, category, target_category, max_per_pose=50):
        """Integrate a specific category of new data"""
        cat_path = self.new_datasets_path / category
        if not cat_path.exists():
            logger.warning(f"Category {category} not found")
            return 0
            
        processed_count = 0
        target_process_path = self.processed_data_path / target_category
        target_process_path.mkdir(parents=True, exist_ok=True)
        
        print(f"\n🔄 Processing {category} -> {target_category}")
        
        # Process each pose type
        for pose_dir in cat_path.iterdir():
            if not pose_dir.is_dir():
                continue
                
            pose_name = pose_dir.name
            print(f"  📁 Processing {pose_name}...")
            
            # Get all images in this pose directory
            image_files = []
            for ext in ['*.jpg', '*.jpeg', '*.png']:
                image_files.extend(pose_dir.glob(ext))
            
            # Limit number of images per pose
            image_files = image_files[:max_per_pose]
            
            # Process each image
            for i, img_path in enumerate(image_files):
                if i >= max_per_pose:
                    break
                    
                keypoints = self.process_image_to_keypoints(img_path)
                if keypoints is not None:
                    # Save processed data
                    output_name = f"{pose_name}_{img_path.stem}_{category}_processed.npy"
                    output_path = target_process_path / output_name
                    np.save(output_path, keypoints)
                    processed_count += 1
                    
                if processed_count % 50 == 0:
                    print(f"    ✅ Processed {processed_count} images...")
        
        return processed_count
    
    def run_integration(self):
        """Run the full integration process"""
        print("\n" + "="*60)
        print("🚀 PERFECT POSE - DATASET INTEGRATION")
        print("="*60)
        
        # Count available data
        total_available = self.count_available_data()
        if total_available == 0:
            print("❌ No new datasets found!")
            return
        
        # Create processing directories
        self.processed_data_path.mkdir(parents=True, exist_ok=True)
        
        total_processed = 0
        
        # Integrate each category
        for new_cat, target_cat in self.category_mapping.items():
            processed = self.integrate_category(new_cat, target_cat, max_per_pose=100)
            total_processed += processed
            print(f"✅ {new_cat} -> {target_cat}: {processed} images processed")
        
        print(f"\n" + "="*60)
        print(f"🎉 INTEGRATION COMPLETE!")
        print(f"📊 Total processed: {total_processed} images")
        print(f"📁 Saved to: {self.processed_data_path}")
        print("="*60)
        
        return total_processed

if __name__ == "__main__":
    integrator = DatasetIntegrator()
    integrator.run_integration() 