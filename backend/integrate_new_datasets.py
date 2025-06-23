#!/usr/bin/env python3
"""
Perfect Pose - New Dataset Integration
Processes newly downloaded Kaggle datasets into pose keypoints
"""

import logging
import os
from pathlib import Path

import cv2
import mediapipe as mp
import numpy as np


def extract_pose_keypoints(landmarks):
    """Extract pose keypoints from MediaPipe landmarks"""
    keypoints = []
    for landmark in landmarks:
        keypoints.extend([landmark.x, landmark.y, landmark.z])
    return np.array(keypoints)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def integrate_new_datasets():
    """Quick integration of new yoga dataset"""
    print("\n" + "="*60)
    print("🚀 PERFECT POSE - DATASET INTEGRATION")
    print("="*60)
    
    # Initialize MediaPipe
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(
        static_image_mode=True,
        model_complexity=1,
        enable_segmentation=False,
        min_detection_confidence=0.5
    )
    
    # Paths
    new_yoga_path = Path("../datasets/downloaded/yoga")
    output_path = Path("models/data/process/yoga")
    output_path.mkdir(parents=True, exist_ok=True)
    
    if not new_yoga_path.exists():
        print("❌ No yoga data found!")
        return
    
    # Count available poses
    pose_dirs = [d for d in new_yoga_path.iterdir() if d.is_dir()]
    print(f"📊 Found {len(pose_dirs)} yoga pose types")
    
    processed_count = 0
    max_per_pose = 20  # Limit per pose type for now
    
    for pose_dir in pose_dirs[:10]:  # Process first 10 pose types
        pose_name = pose_dir.name.replace(' ', '_')
        print(f"🔄 Processing {pose_name}...")
        
        # Get image files
        image_files = []
        for ext in ['*.jpg', '*.jpeg', '*.png']:
            image_files.extend(pose_dir.glob(ext))
        
        # Process limited number of images
        for i, img_path in enumerate(image_files[:max_per_pose]):
            try:
                # Read and process image
                image = cv2.imread(str(img_path))
                if image is None:
                    continue
                    
                image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                results = pose.process(image_rgb)
                
                if results.pose_landmarks:
                    # Extract keypoints
                    keypoints = extract_pose_keypoints(results.pose_landmarks.landmark)
                    
                    # Create sequence (30 timesteps like existing data)
                    sequence = np.tile(keypoints, (30, 1))
                    
                    # Save
                    output_name = f"{pose_name}_{img_path.stem}_new.npy"
                    np.save(output_path / output_name, sequence)
                    processed_count += 1
                    
            except Exception as e:
                logger.warning(f"Error processing {img_path}: {e}")
                continue
        
        print(f"  ✅ {pose_name}: {min(len(image_files), max_per_pose)} images processed")
    
    print(f"\n🎉 Integration complete!")
    print(f"📊 Total processed: {processed_count} new yoga samples")
    print(f"📁 Saved to: {output_path}")
    
    return processed_count

if __name__ == "__main__":
    integrate_new_datasets() 