#!/usr/bin/env python3
"""
Process Existing Yoga Dataset
============================
Process the 2,760 yoga images we already have to create training data
"""

import logging
import os
from datetime import datetime
from pathlib import Path

import cv2
import mediapipe as mp
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class YogaDatasetProcessor:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=True,
            model_complexity=2,
            enable_segmentation=False,
            min_detection_confidence=0.7
        )
        
        self.processed_dir = Path('models/data/process')
        self.processed_dir.mkdir(parents=True, exist_ok=True)
        
        # Create category directories
        for category in ['yoga', 'bodyweight', 'functional', 'lifting']:
            (self.processed_dir / category).mkdir(exist_ok=True)
    
    def extract_pose_landmarks(self, image_path):
        """Extract pose landmarks from image"""
        try:
            image = cv2.imread(str(image_path))
            if image is None:
                return None
            
            # Convert BGR to RGB
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = self.pose.process(image_rgb)
            
            if results.pose_landmarks:
                landmarks = []
                for landmark in results.pose_landmarks.landmark:
                    landmarks.extend([landmark.x, landmark.y, landmark.visibility])
                
                landmarks_array = np.array(landmarks)
                
                # Quality check: ensure landmarks are visible enough
                visibility_scores = landmarks_array[2::3]
                if np.mean(visibility_scores) > 0.6:
                    return landmarks_array
            
        except Exception as e:
            logger.warning(f"Failed to process {image_path}: {e}")
        
        return None
    
    def process_yoga_dataset(self):
        """Process all yoga images from the downloaded dataset"""
        logger.info("🧘 Processing existing yoga dataset (2,760 images)")
        
        yoga_source_dir = Path('datasets/downloaded/yoga')
        if not yoga_source_dir.exists():
            logger.error("❌ Yoga dataset not found!")
            return 0
        
        processed_count = 0
        existing_count = len(list((self.processed_dir / 'yoga').glob('*.npy')))
        
        # Start numbering from existing files
        file_counter = existing_count
        
        # Process all yoga pose directories
        for pose_dir in yoga_source_dir.iterdir():
            if pose_dir.is_dir() and pose_dir.name != 'yoga-posture-dataset.zip':
                logger.info(f"📂 Processing {pose_dir.name}...")
                
                for image_file in pose_dir.glob('*'):
                    if image_file.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                        landmarks = self.extract_pose_landmarks(image_file)
                        
                        if landmarks is not None and len(landmarks) == 99:
                            # Save processed landmarks
                            output_path = self.processed_dir / 'yoga' / f"{file_counter:06d}.npy"
                            np.save(output_path, landmarks)
                            processed_count += 1
                            file_counter += 1
                            
                            if processed_count % 100 == 0:
                                logger.info(f"  ✅ Processed {processed_count} yoga images")
        
        total_count = existing_count + processed_count
        logger.info(f"🎉 YOGA PROCESSING COMPLETE:")
        logger.info(f"   📥 New processed: {processed_count}")
        logger.info(f"   📚 Previously existing: {existing_count}")
        logger.info(f"   🎯 Total yoga samples: {total_count}")
        
        return processed_count
    
    def generate_dataset_report(self):
        """Generate a report of the current dataset"""
        categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        
        report = f"""
CURRENT DATASET REPORT
=====================
Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

SAMPLES PER CATEGORY:
"""
        
        total_samples = 0
        category_counts = {}
        
        for category in categories:
            count = len(list((self.processed_dir / category).glob('*.npy')))
            category_counts[category] = count
            total_samples += count
            report += f"  {category.upper():>12}: {count:,} samples\n"
        
        min_samples = min(category_counts.values())
        max_samples = max(category_counts.values())
        
        report += f"""
DATASET STATISTICS:
  📊 Total samples: {total_samples:,}
  📉 Minimum per category: {min_samples:,}
  📈 Maximum per category: {max_samples:,}
  ⚖️ Balance ratio: {max_samples/min_samples if min_samples > 0 else 'N/A'}

READINESS FOR TRAINING:
  ✅ Has yoga data: {'YES' if category_counts['yoga'] > 0 else 'NO'}
  ⚠️ Needs more bodyweight data: {'YES' if category_counts['bodyweight'] < 100 else 'NO'}
  ⚠️ Needs more functional data: {'YES' if category_counts['functional'] < 100 else 'NO'}
  ⚠️ Needs more lifting data: {'YES' if category_counts['lifting'] < 100 else 'NO'}

NEXT STEPS:
  1. Download additional datasets for underrepresented categories
  2. Train model with current data (yoga-heavy)
  3. Gradually balance dataset for 80% accuracy
"""
        
        print(report)
        
        with open('datasets/current_dataset_report.txt', 'w') as f:
            f.write(report)
        
        logger.info("📄 Report saved: datasets/current_dataset_report.txt")
        
        return category_counts

def main():
    """Main processing function"""
    processor = YogaDatasetProcessor()
    
    print("\n🧘 PROCESSING EXISTING YOGA DATASET")
    print("🎯 Goal: Create training data from 2,760 yoga images")
    print("⏱️ This may take 5-15 minutes")
    
    # Process yoga images
    processed_count = processor.process_yoga_dataset()
    
    # Generate report
    category_counts = processor.generate_dataset_report()
    
    print(f"\n🎉 PROCESSING COMPLETED!")
    print(f"📊 New yoga samples processed: {processed_count:,}")
    print(f"🧘 Total yoga samples: {category_counts['yoga']:,}")
    print(f"📋 See report: datasets/current_dataset_report.txt")
    
    if category_counts['yoga'] >= 500:
        print(f"\n🚀 READY FOR INITIAL TRAINING!")
        print(f"   Run: python backend/train_advanced_80_percent.py")
        print(f"   Note: Will be yoga-heavy initially, but can still train")
    else:
        print(f"\n⚠️ Need more data processing or downloads")

if __name__ == "__main__":
    main() 