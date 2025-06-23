#!/usr/bin/env python3
"""
Process All New Exercise Data
============================
Process 13,486+ exercise images for 80% accuracy training
"""

import logging
import os
import time
from datetime import datetime
from pathlib import Path

import cv2
import mediapipe as mp
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MassiveDataProcessor:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=True,
            model_complexity=1,  # Balance speed and accuracy
            enable_segmentation=False,
            min_detection_confidence=0.5
        )
        
        # Output directories
        self.processed_dir = Path('models/data/process')
        self.processed_dir.mkdir(parents=True, exist_ok=True)
        
        # Create category directories
        for category in ['yoga', 'bodyweight', 'functional', 'lifting']:
            (self.processed_dir / category).mkdir(exist_ok=True)
        
        # Source directories
        self.source_dir = Path('datasets/massive_collection')
        
        # Statistics
        self.stats = {
            'bodyweight': {'processed': 0, 'failed': 0, 'existing': 0},
            'functional': {'processed': 0, 'failed': 0, 'existing': 0},
            'lifting': {'processed': 0, 'failed': 0, 'existing': 0}
        }
    
    def extract_pose_landmarks(self, image_path):
        """Extract pose landmarks from image"""
        try:
            image = cv2.imread(str(image_path))
            if image is None:
                return None
            
            # Resize if image is too large (for speed)
            height, width = image.shape[:2]
            if max(height, width) > 800:
                scale = 800 / max(height, width)
                new_width = int(width * scale)
                new_height = int(height * scale)
                image = cv2.resize(image, (new_width, new_height))
            
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
                if np.mean(visibility_scores) > 0.5:  # Lower threshold for diverse data
                    return landmarks_array
            
        except Exception as e:
            logger.debug(f"Failed to process {image_path}: {e}")
        
        return None
    
    def process_category(self, category):
        """Process all images in a category"""
        logger.info(f"🏋️ Processing {category.upper()} category...")
        
        source_path = self.source_dir / category
        if not source_path.exists():
            logger.warning(f"❌ Source directory not found: {source_path}")
            return
        
        # Count existing processed files
        existing_count = len(list((self.processed_dir / category).glob('*.npy')))
        self.stats[category]['existing'] = existing_count
        
        # Start file counter from existing count
        file_counter = existing_count
        
        # Get all image files
        image_extensions = ['.jpg', '.jpeg', '.png', '.bmp', '.gif']
        image_files = []
        
        for ext in image_extensions:
            image_files.extend(source_path.glob(f'*{ext}'))
            image_files.extend(source_path.glob(f'*{ext.upper()}'))
        
        total_images = len(image_files)
        logger.info(f"📊 Found {total_images:,} {category} images to process")
        
        if total_images == 0:
            logger.warning(f"⚠️ No images found in {source_path}")
            return
        
        # Process images
        start_time = time.time()
        processed_count = 0
        failed_count = 0
        
        for i, image_file in enumerate(image_files):
            if i % 100 == 0 and i > 0:
                elapsed = time.time() - start_time
                rate = i / elapsed
                eta = (total_images - i) / rate if rate > 0 else 0
                logger.info(f"  📈 Progress: {i:,}/{total_images:,} ({i/total_images:.1%}) - "
                          f"Rate: {rate:.1f} imgs/sec - ETA: {eta/60:.1f}min")
            
            landmarks = self.extract_pose_landmarks(image_file)
            
            if landmarks is not None and len(landmarks) == 99:
                # Save processed landmarks
                output_path = self.processed_dir / category / f"{file_counter:06d}.npy"
                np.save(output_path, landmarks)
                processed_count += 1
                file_counter += 1
            else:
                failed_count += 1
        
        # Update statistics
        self.stats[category]['processed'] = processed_count
        self.stats[category]['failed'] = failed_count
        
        success_rate = processed_count / total_images if total_images > 0 else 0
        total_count = existing_count + processed_count
        
        logger.info(f"🎉 {category.upper()} PROCESSING COMPLETE:")
        logger.info(f"   ✅ Successfully processed: {processed_count:,}")
        logger.info(f"   ❌ Failed to process: {failed_count:,}")
        logger.info(f"   📊 Success rate: {success_rate:.1%}")
        logger.info(f"   📚 Previously existing: {existing_count:,}")
        logger.info(f"   🎯 Total {category} samples: {total_count:,}")
    
    def generate_comprehensive_report(self):
        """Generate a comprehensive dataset report"""
        categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        
        report = f"""
COMPREHENSIVE DATASET REPORT - 80% ACCURACY PROJECT
==================================================
Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

PROCESSING RESULTS:
"""
        
        total_processed = 0
        total_samples = 0
        category_counts = {}
        
        for category in categories:
            count = len(list((self.processed_dir / category).glob('*.npy')))
            category_counts[category] = count
            total_samples += count
            
            if category in self.stats:
                processed = self.stats[category]['processed']
                failed = self.stats[category]['failed']
                existing = self.stats[category]['existing']
                total_processed += processed
                
                success_rate = processed / (processed + failed) if (processed + failed) > 0 else 0
                
                report += f"""
  {category.upper():>12}:
    📥 New processed:     {processed:,}
    ❌ Failed:            {failed:,}
    📚 Previously had:    {existing:,}
    🎯 Total samples:     {count:,}
    ✅ Success rate:      {success_rate:.1%}
"""
            else:
                report += f"""
  {category.upper():>12}:
    🎯 Total samples:     {count:,}
"""
        
        # Calculate statistics
        min_samples = min(category_counts.values()) if category_counts.values() else 0
        max_samples = max(category_counts.values()) if category_counts.values() else 0
        balance_ratio = max_samples / min_samples if min_samples > 0 else float('inf')
        
        # Check readiness for 80% accuracy training
        ready_categories = sum(1 for count in category_counts.values() if count >= 500)
        balanced_dataset = balance_ratio < 5  # Allow some imbalance
        sufficient_data = total_samples >= 4000
        
        ready_for_80_percent = ready_categories >= 3 and sufficient_data
        
        report += f"""

DATASET STATISTICS:
  📊 Total samples:           {total_samples:,}
  📈 Largest category:        {max_samples:,} samples
  📉 Smallest category:       {min_samples:,} samples
  ⚖️ Balance ratio:           {balance_ratio:.1f}:1
  🎯 Categories with 500+:    {ready_categories}/4
  
READINESS ASSESSMENT:
  ✅ Sufficient total data (4000+):     {'YES' if sufficient_data else 'NO'} ({total_samples:,})
  ✅ Multiple strong categories:        {'YES' if ready_categories >= 3 else 'NO'} ({ready_categories}/4)
  ✅ Reasonable balance (<5:1):         {'YES' if balanced_dataset else 'NO'} ({balance_ratio:.1f}:1)
  
  🚀 READY FOR 80% ACCURACY TRAINING:   {'YES' if ready_for_80_percent else 'NO'}

NEXT STEPS:
"""
        
        if ready_for_80_percent:
            report += """  1. ✅ DATASET IS READY!
  2. 🚀 Run: python backend/train_advanced_80_percent.py
  3. 🎯 Expected accuracy: 70-85% (excellent for diverse data)
  4. 📊 Monitor training with research tracking
"""
        else:
            report += f"""  1. ⚠️ Need more processing or balancing
  2. 🔄 Current status: {total_samples:,} samples, {ready_categories}/4 strong categories
  3. 🎯 Target: 4,000+ samples with 3+ categories having 500+ samples each
"""
        
        print(report)
        
        # Save report
        with open('datasets/comprehensive_dataset_report.txt', 'w') as f:
            f.write(report)
        
        logger.info("📄 Report saved: datasets/comprehensive_dataset_report.txt")
        
        return ready_for_80_percent, category_counts

def main():
    """Main processing function"""
    processor = MassiveDataProcessor()
    
    print(f"\n🚀 PROCESSING MASSIVE EXERCISE DATASET")
    print(f"🎯 Goal: Process 13,486+ images for 80% accuracy")
    print(f"⏱️ Estimated time: 15-45 minutes")
    print(f"📊 Categories: Bodyweight, Functional, Lifting")
    
    start_time = time.time()
    
    # Process each category
    categories_to_process = ['bodyweight', 'functional', 'lifting']
    
    for category in categories_to_process:
        category_start = time.time()
        processor.process_category(category)
        category_time = time.time() - category_start
        logger.info(f"⏱️ {category.capitalize()} processing took {category_time/60:.1f} minutes")
    
    # Generate comprehensive report
    ready_for_training, category_counts = processor.generate_comprehensive_report()
    
    total_time = time.time() - start_time
    
    print(f"\n🎉 MASSIVE PROCESSING COMPLETED!")
    print(f"⏱️ Total processing time: {total_time/60:.1f} minutes")
    print(f"📊 Final dataset size: {sum(category_counts.values()):,} samples")
    print(f"📋 See full report: datasets/comprehensive_dataset_report.txt")
    
    if ready_for_training:
        print(f"\n🚀 DATASET READY FOR 80% ACCURACY TRAINING!")
        print(f"   Next: python backend/train_advanced_80_percent.py")
        print(f"   Expected: 70-85% accuracy on this diverse dataset")
    else:
        print(f"\n⚠️ Dataset needs more processing or balancing")
        print(f"   Current: {sum(category_counts.values()):,} samples")
        print(f"   Target: 4,000+ with balanced categories")

if __name__ == "__main__":
    main() 