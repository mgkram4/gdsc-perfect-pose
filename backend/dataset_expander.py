#!/usr/bin/env python3
"""
Dataset Expansion & Real-World Validation
=========================================
This script helps find, download, and integrate real pose datasets to properly
validate our model and identify overfitting issues.

Current Problem: Model went from 30% to 100% accuracy - likely overfitting!
Solution: Get diverse, real datasets for proper validation.
"""

import json
import logging
import os
import sys
from pathlib import Path
from typing import Dict, List

import requests

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatasetFinder:
    """Find and recommend pose datasets for download"""
    
    def __init__(self):
        self.results_dir = Path('research_results')
        self.results_dir.mkdir(exist_ok=True)
        
    def analyze_overfitting_risk(self):
        """Analyze current dataset for overfitting indicators"""
        print("\n" + "="*70)
        print("🚨 OVERFITTING ANALYSIS")
        print("="*70)
        
        categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        overfitting_indicators = []
        
        for category in categories:
            processed_dir = Path(f'models/data/process/{category}')
            if not processed_dir.exists():
                continue
                
            files = list(processed_dir.glob('*.npy'))
            original_files = [f for f in files if 'aug' not in f.name]
            augmented_files = [f for f in files if 'aug' in f.name]
            
            ratio = len(augmented_files) / max(len(original_files), 1)
            
            print(f"{category:>12}: {len(original_files):2d} original, {len(augmented_files):2d} augmented (ratio: {ratio:.1f}x)")
            
            if len(original_files) < 20:
                overfitting_indicators.append(f"❌ {category}: Too few original samples ({len(original_files)})")
            if ratio > 3:
                overfitting_indicators.append(f"❌ {category}: Too much augmentation ({ratio:.1f}x)")
        
        print(f"\n🔍 OVERFITTING RISK ASSESSMENT:")
        if overfitting_indicators:
            print("   🚨 HIGH RISK - Model likely memorizing training data:")
            for indicator in overfitting_indicators:
                print(f"   {indicator}")
        else:
            print("   ✅ LOW RISK - Dataset appears diverse")
            
        print(f"\n💡 RECOMMENDATION:")
        print(f"   📊 Need 500+ diverse samples per category for reliable accuracy")
        print(f"   🎯 Current 100% accuracy is likely FALSE - model memorized {len(original_files)} people")
        
    def get_recommended_datasets(self) -> Dict[str, List[Dict]]:
        """Get list of recommended free pose datasets"""
        
        datasets = {
            "yoga": [
                {
                    "name": "Yoga-82 Dataset",
                    "url": "https://sites.google.com/view/yoga-82/home",
                    "description": "82 yoga poses, 28K+ images",
                    "size": "Large",
                    "format": "Images + Annotations",
                    "download_method": "Manual download required"
                },
                {
                    "name": "Yoga Poses Dataset (Kaggle)",
                    "url": "https://www.kaggle.com/datasets/tr1gg3rtrash/yoga-posture-dataset",
                    "description": "5,994 images, 107 yoga poses",
                    "size": "Medium",
                    "format": "Images",
                    "download_method": "kaggle datasets download -d tr1gg3rtrash/yoga-posture-dataset"
                },
                {
                    "name": "Yoga Pose Classification",
                    "url": "https://www.kaggle.com/datasets/ujjwalchowdhury/yoga-pose-classification",
                    "description": "Multiple yoga poses with classifications",
                    "size": "Medium",
                    "format": "Images",
                    "download_method": "kaggle datasets download -d ujjwalchowdhury/yoga-pose-classification"
                }
            ],
            "exercise": [
                {
                    "name": "Exercise Dataset (Kaggle)",
                    "url": "https://www.kaggle.com/datasets/hasyimabdillah/exercise-dataset",
                    "description": "Multiple exercise types including bodyweight",
                    "size": "Medium",
                    "format": "Images",
                    "download_method": "kaggle datasets download -d hasyimabdillah/exercise-dataset"
                },
                {
                    "name": "Workout Pose Classification",
                    "url": "https://www.kaggle.com/datasets/souravbera/workout-pose-classification-dataset",
                    "description": "Push-ups, squats, lunges, planks",
                    "size": "Small-Medium",
                    "format": "Images",
                    "download_method": "kaggle datasets download -d souravbera/workout-pose-classification-dataset"
                },
                {
                    "name": "Fitness Pose Detection",
                    "url": "https://universe.roboflow.com/searchterm/fitness-pose-detection",
                    "description": "Various fitness exercises with pose annotations",
                    "size": "Variable",
                    "format": "Images + YOLO annotations",
                    "download_method": "Roboflow API or manual"
                }
            ],
            "general_pose": [
                {
                    "name": "COCO Pose Dataset",
                    "url": "https://cocodataset.org/#keypoints-2017",
                    "description": "200K+ images with human pose keypoints",
                    "size": "Very Large",
                    "format": "Images + Keypoint annotations",
                    "download_method": "wget http://images.cocodataset.org/zips/train2017.zip"
                },
                {
                    "name": "Human3.6M",
                    "url": "http://vision.imar.ro/human3.6m/description.php",
                    "description": "3.6M+ human poses in controlled environment",
                    "size": "Very Large",
                    "format": "Videos + 3D poses",
                    "download_method": "Registration required"
                },
                {
                    "name": "LSP (Leeds Sports Pose)",
                    "url": "https://sam.johnson.io/research/lsp.html",
                    "description": "Sports poses dataset",
                    "size": "Small",
                    "format": "Images + Joint annotations",
                    "download_method": "Direct download"
                }
            ]
        }
        
        return datasets
    
    def print_dataset_recommendations(self):
        """Print formatted dataset recommendations"""
        datasets = self.get_recommended_datasets()
        
        print("\n" + "="*70)
        print("📊 RECOMMENDED FREE POSE DATASETS")
        print("="*70)
        
        for category, dataset_list in datasets.items():
            print(f"\n🎯 {category.upper().replace('_', ' ')} DATASETS:")
            
            for i, dataset in enumerate(dataset_list, 1):
                print(f"\n   {i}. {dataset['name']}")
                print(f"      📝 {dataset['description']}")
                print(f"      📏 Size: {dataset['size']}")
                print(f"      📁 Format: {dataset['format']}")
                print(f"      🌐 URL: {dataset['url']}")
                if 'kaggle' in dataset['download_method']:
                    print(f"      💻 Download: {dataset['download_method']}")
                else:
                    print(f"      💻 Download: {dataset['download_method']}")
    
    def create_download_script(self):
        """Create a script to download the easiest datasets"""
        
        script_content = '''#!/bin/bash
# Dataset Download Script for Perfect Pose
# Run this script to download the most accessible datasets

echo "🚀 Perfect Pose Dataset Downloader"
echo "=================================="

# Check if kaggle is installed
if ! command -v kaggle &> /dev/null; then
    echo "❌ Kaggle CLI not found. Installing..."
    pip install kaggle
    echo "📝 Please set up Kaggle API credentials:"
    echo "   1. Go to https://www.kaggle.com/settings"
    echo "   2. Create new API token"
    echo "   3. Save kaggle.json to ~/.kaggle/"
    echo "   4. Run: chmod 600 ~/.kaggle/kaggle.json"
    exit 1
fi

# Create datasets directory
mkdir -p ../datasets/downloaded

cd ../datasets/downloaded

echo "📊 Downloading Yoga Poses Dataset..."
kaggle datasets download -d tr1gg3rtrash/yoga-posture-dataset
unzip -q yoga-posture-dataset.zip -d yoga_poses/
rm yoga-posture-dataset.zip

echo "🏋️ Downloading Exercise Dataset..."
kaggle datasets download -d hasyimabdillah/exercise-dataset
unzip -q exercise-dataset.zip -d exercise_poses/
rm exercise-dataset.zip

echo "💪 Downloading Workout Pose Classification..."
kaggle datasets download -d souravbera/workout-pose-classification-dataset
unzip -q workout-pose-classification-dataset.zip -d workout_poses/
rm workout-pose-classification-dataset.zip

echo "✅ Download complete! Check ../datasets/downloaded/"
echo "📁 Next steps:"
echo "   1. Run: python dataset_processor.py to process new data"
echo "   2. Run: python model_accuracy_tracker.py to test real accuracy"
'''

        script_path = Path('download_datasets.sh')
        with open(script_path, 'w') as f:
            f.write(script_content)
        
        # Make executable
        os.chmod(script_path, 0o755)
        
        print(f"\n💾 Created download script: {script_path}")
        print(f"📝 To use: chmod +x download_datasets.sh && ./download_datasets.sh")

def test_model_on_new_image():
    """Test current model on a new image to check real accuracy"""
    print("\n" + "="*70)
    print("🧪 REAL-WORLD MODEL TESTING")
    print("="*70)
    
    print("📱 To test the model's REAL accuracy:")
    print("   1. Take a photo/video of yourself doing a yoga pose")
    print("   2. Place it in: models/data/images/test_images/")
    print("   3. Run the following test script...")
    
    # Create a quick test script
    test_script = '''#!/usr/bin/env python3
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
        print(f"\\n📸 Testing: {img_file}")
        
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
'''
    
    with open('test_real_accuracy.py', 'w') as f:
        f.write(test_script)
    
    print("\n💾 Created test script: test_real_accuracy.py")
    print("📸 Add test images to models/data/images/test_images/ and run it!")

def main():
    """Main function"""
    print("\n" + "="*70)
    print("🔍 DATASET EXPANSION & OVERFITTING DETECTION")
    print("="*70)
    
    finder = DatasetFinder()
    
    # Analyze current overfitting
    finder.analyze_overfitting_risk()
    
    # Show dataset recommendations
    finder.print_dataset_recommendations()
    
    # Create download tools
    finder.create_download_script()
    
    # Create testing tools
    test_model_on_new_image()
    
    print("\n" + "="*70)
    print("🎯 NEXT STEPS TO GET REAL ACCURACY:")
    print("="*70)
    print("1. 📊 Download diverse datasets using the script above")
    print("2. 🧪 Test current model on NEW images (will likely fail)")
    print("3. 📈 Retrain with diverse data for true accuracy")
    print("4. 🎯 Aim for 70-85% on diverse data (realistic goal)")
    print("\n💡 Remember: 100% accuracy on small data = overfitting!")

if __name__ == "__main__":
    main() 