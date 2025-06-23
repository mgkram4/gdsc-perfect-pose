#!/bin/bash
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
