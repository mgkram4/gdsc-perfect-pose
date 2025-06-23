#!/usr/bin/env python3
"""
Real-world model testing script
"""
import sys
sys.path.append('.')
from models.analyzer import PoseAnalyzer
import tempfile
import os

def test_real_accuracy():
    print("🧪 Testing model on new images...")
    
    analyzer = PoseAnalyzer()
    test_dir = "models/data/images/test_images"
    
    if not os.path.exists(test_dir):
        os.makedirs(test_dir)
        print(f"📁 Created {test_dir}")
        print("📱 Add your test images here and run again!")
        return
    
    test_files = [f for f in os.listdir(test_dir) 
                  if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    
    if not test_files:
        print("❌ No test images found!")
        print(f"📁 Add images to {test_dir}")
        return
    
    print(f"🔍 Found {len(test_files)} test images")
    
    for img_file in test_files:
        img_path = os.path.join(test_dir, img_file)
        print(f"\n📸 Testing: {img_file}")
        
        try:
            # Test with each category
            for category in ['yoga', 'bodyweight', 'functional', 'lifting']:
                for pose in ['test_pose']:  # Generic pose name
                    result = analyzer.analyze_user_pose(img_path, category, pose)
                    if result and 'similarity' in result:
                        print(f"   {category}: {result['similarity']:.1%} confidence")
        except Exception as e:
            print(f"   ❌ Error: {e}")

if __name__ == "__main__":
    test_real_accuracy()
