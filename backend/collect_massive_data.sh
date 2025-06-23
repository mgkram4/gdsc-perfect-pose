#!/bin/bash
echo "🚀 MASSIVE DATA COLLECTION FOR 80% ACCURACY"
echo "==========================================="

# Activate virtual environment
source backend/venv/bin/activate

# Create directories
mkdir -p datasets/massive_collection/{bodyweight,functional,lifting,yoga_additional}
cd datasets/massive_collection

echo "📥 1. Bodyweight Exercise Datasets..."
kaggle datasets download -d ranchita28/pushup-pose-classification --unzip -p bodyweight/ || echo "Skipped"
kaggle datasets download -d niharika41298/gym-exercise-data --unzip -p bodyweight/ || echo "Skipped"

echo "📥 2. Functional Fitness Datasets..."  
kaggle datasets download -d hasyimabdillah/gym-exercise-dataset --unzip -p functional/ || echo "Skipped"
kaggle datasets download -d poojakubendiran/human-pose-estimation-dataset --unzip -p functional/ || echo "Skipped"

echo "📥 3. Weight Lifting Datasets..."
kaggle datasets download -d hasyimabdillah/gym-exercise-dataset --unzip -p lifting/ || echo "Skipped"

echo "📥 4. Additional Yoga Datasets..."
kaggle datasets download -d tr1gg3rtrash/yoga-pose-classification --unzip -p yoga_additional/ || echo "Skipped"

echo "✅ DATA COLLECTION COMPLETED!"
echo "🔄 Processing downloaded data..."

cd ../..
python backend/process_massive_dataset.py

echo "🎉 READY FOR 80% ACCURACY TRAINING!"
