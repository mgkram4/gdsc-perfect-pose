#!/usr/bin/env python3
"""
Dataset Setup & Download Script
===============================
This script helps set up Kaggle credentials and downloads pose datasets.
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def check_kaggle_setup():
    """Check if Kaggle is properly set up"""
    kaggle_dir = Path.home() / '.kaggle'
    kaggle_json = kaggle_dir / 'kaggle.json'
    
    if kaggle_json.exists():
        print("✅ Kaggle credentials found!")
        return True
    else:
        print("❌ Kaggle credentials not found")
        return False

def setup_kaggle_credentials():
    """Help user set up Kaggle credentials"""
    print("\n" + "="*60)
    print("🔑 KAGGLE CREDENTIALS SETUP")
    print("="*60)
    
    # Check if kaggle.json is in Downloads
    downloads_path = Path.home() / 'Downloads' / 'kaggle.json'
    
    if downloads_path.exists():
        print("✅ Found kaggle.json in Downloads folder!")
        
        # Create .kaggle directory
        kaggle_dir = Path.home() / '.kaggle'
        kaggle_dir.mkdir(exist_ok=True)
        
        # Copy kaggle.json
        kaggle_json_path = kaggle_dir / 'kaggle.json'
        shutil.copy2(downloads_path, kaggle_json_path)
        
        # Set correct permissions
        os.chmod(kaggle_json_path, 0o600)
        
        print("✅ Kaggle credentials installed successfully!")
        return True
    
    else:
        print("📝 Please follow these steps:")
        print("1. Go to: https://www.kaggle.com/settings")
        print("2. Scroll to 'API' section")
        print("3. Click 'Create New Token'")
        print("4. This downloads 'kaggle.json' to your Downloads")
        print("5. Run this script again")
        return False

def test_kaggle_connection():
    """Test if Kaggle API works"""
    try:
        result = subprocess.run(['kaggle', 'datasets', 'list', '--max-size', '1'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("✅ Kaggle API connection successful!")
            return True
        else:
            print(f"❌ Kaggle API error: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Kaggle API test failed: {e}")
        return False

def download_yoga_dataset():
    """Download yoga pose dataset"""
    print("\n📊 Downloading Yoga Poses Dataset (5,994 images)...")
    
    # Create datasets directory
    datasets_dir = Path('../datasets/downloaded/yoga')
    datasets_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        # Download dataset
        cmd = ['kaggle', 'datasets', 'download', '-d', 'tr1gg3rtrash/yoga-posture-dataset', '-p', str(datasets_dir)]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ Yoga dataset downloaded!")
            
            # Unzip the dataset
            zip_file = datasets_dir / 'yoga-posture-dataset.zip'
            if zip_file.exists():
                print("📦 Extracting dataset...")
                subprocess.run(['unzip', '-q', str(zip_file), '-d', str(datasets_dir)])
                zip_file.unlink()  # Remove zip file
                print("✅ Yoga dataset extracted!")
                return True
            else:
                print("❌ Zip file not found")
                return False
        else:
            print(f"❌ Download failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error downloading yoga dataset: {e}")
        return False

def download_exercise_dataset():
    """Download exercise/bodyweight dataset"""
    print("\n🏋️ Downloading Exercise Dataset...")
    
    datasets_dir = Path('../datasets/downloaded/exercise')
    datasets_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        cmd = ['kaggle', 'datasets', 'download', '-d', 'hasyimabdillah/exercise-dataset', '-p', str(datasets_dir)]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ Exercise dataset downloaded!")
            
            zip_file = datasets_dir / 'exercise-dataset.zip'
            if zip_file.exists():
                print("📦 Extracting dataset...")
                subprocess.run(['unzip', '-q', str(zip_file), '-d', str(datasets_dir)])
                zip_file.unlink()
                print("✅ Exercise dataset extracted!")
                return True
        else:
            print(f"❌ Download failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error downloading exercise dataset: {e}")
        return False

def download_workout_poses():
    """Download workout pose classification dataset"""
    print("\n💪 Downloading Workout Pose Classification...")
    
    datasets_dir = Path('../datasets/downloaded/workout')
    datasets_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        cmd = ['kaggle', 'datasets', 'download', '-d', 'souravbera/workout-pose-classification-dataset', '-p', str(datasets_dir)]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ Workout dataset downloaded!")
            
            zip_file = datasets_dir / 'workout-pose-classification-dataset.zip'
            if zip_file.exists():
                print("📦 Extracting dataset...")
                subprocess.run(['unzip', '-q', str(zip_file), '-d', str(datasets_dir)])
                zip_file.unlink()
                print("✅ Workout dataset extracted!")
                return True
        else:
            print(f"❌ Download failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error downloading workout dataset: {e}")
        return False

def analyze_downloaded_data():
    """Analyze what we downloaded"""
    print("\n📊 ANALYZING DOWNLOADED DATASETS:")
    print("="*50)
    
    datasets_base = Path('../datasets/downloaded')
    if not datasets_base.exists():
        print("❌ No datasets downloaded yet")
        return
    
    total_images = 0
    
    for dataset_dir in datasets_base.iterdir():
        if dataset_dir.is_dir():
            # Count images recursively
            image_count = 0
            for ext in ['*.jpg', '*.jpeg', '*.png', '*.JPG', '*.JPEG', '*.PNG']:
                image_count += len(list(dataset_dir.rglob(ext)))
            
            print(f"{dataset_dir.name:>10}: {image_count:,} images")
            total_images += image_count
    
    print(f"{'TOTAL':>10}: {total_images:,} images")
    
    if total_images > 1000:
        print("✅ Excellent! You now have sufficient data for real training")
    elif total_images > 100:
        print("⚠️ Good start, but more data would be better")
    else:
        print("❌ Still not enough data for reliable training")

def main():
    """Main setup function"""
    print("\n" + "="*60)
    print("🚀 PERFECT POSE - DATASET SETUP")
    print("="*60)
    
    # Step 1: Check/Setup Kaggle credentials
    if not check_kaggle_setup():
        if not setup_kaggle_credentials():
            print("\n❌ Please set up Kaggle credentials first!")
            print("📝 Run this script again after downloading kaggle.json")
            return
    
    # Step 2: Test Kaggle connection
    if not test_kaggle_connection():
        print("❌ Kaggle API not working. Check your credentials.")
        return
    
    # Step 3: Download datasets
    print("\n🎯 Starting dataset downloads...")
    
    success_count = 0
    
    # Download yoga dataset (highest priority)
    if download_yoga_dataset():
        success_count += 1
    
    # Download exercise dataset
    if download_exercise_dataset():
        success_count += 1
    
    # Download workout poses
    if download_workout_poses():
        success_count += 1
    
    # Step 4: Analyze results
    analyze_downloaded_data()
    
    # Step 5: Next steps
    print("\n" + "="*60)
    print("🎯 NEXT STEPS:")
    print("="*60)
    
    if success_count > 0:
        print("✅ Datasets downloaded successfully!")
        print("📁 Location: ../datasets/downloaded/")
        print("🔄 Next: Process the data and retrain your model")
        print("💻 Run: python process_new_datasets.py")
        print("🧪 Then: python model_accuracy_tracker.py --retrain")
    else:
        print("❌ No datasets downloaded successfully")
        print("🔧 Check your internet connection and Kaggle credentials")

if __name__ == "__main__":
    main() 