#!/usr/bin/env python3
"""
Simple Model Accuracy Tracker
=============================
A lightweight script to track model accuracy and improvements over time.

Features:
- Current model accuracy evaluation
- Model parameter analysis
- Training progress visualization with matplotlib
- CSV logging for research tracking

Usage:
    python model_accuracy_tracker.py [--retrain] [--plot]
"""

import argparse
import csv
import json
import logging
import os
import sys
import warnings
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import tensorflow as tf
from sklearn.metrics import (accuracy_score, classification_report,
                             confusion_matrix)
from sklearn.model_selection import train_test_split

# Suppress TensorFlow warnings
warnings.filterwarnings('ignore')
tf.get_logger().setLevel('ERROR')

# Add current directory to path
sys.path.append('.')

from models.cnn_lstm import PoseModelTrainer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class SimpleModelTracker:
    """Simple model accuracy tracking and analysis"""
    
    def __init__(self, model_path: str = 'models/models/saved/pose_model.keras'):
        self.model_path = model_path
        self.categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        self.processed_dir = Path('models/data/process')
        self.results_dir = Path('research_results')
        self.results_dir.mkdir(exist_ok=True)
        
        # CSV file for tracking results
        self.results_csv = self.results_dir / 'accuracy_tracking.csv'
        self.init_csv()
        
        # Load model if exists
        self.model = None
        if os.path.exists(model_path):
            try:
                self.model = tf.keras.models.load_model(model_path)
                logger.info(f"✅ Loaded model from {model_path}")
            except Exception as e:
                logger.error(f"❌ Failed to load model: {e}")
        else:
            logger.warning(f"⚠️ Model not found at {model_path}")
    
    def init_csv(self):
        """Initialize CSV file for tracking results"""
        if not self.results_csv.exists():
            with open(self.results_csv, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow([
                    'timestamp', 'accuracy', 'total_params', 'trainable_params',
                    'total_samples', 'test_samples', 'yoga_f1', 'bodyweight_f1',
                    'functional_f1', 'lifting_f1', 'notes'
                ])
    
    def analyze_model_info(self) -> Dict:
        """Get basic model information"""
        if not self.model:
            return {"error": "No model loaded"}
        
        info = {
            "total_params": self.model.count_params(),
            "trainable_params": sum([tf.keras.backend.count_params(w) for w in self.model.trainable_weights]),
            "layers": len(self.model.layers),
            "input_shape": str(self.model.input_shape),
            "output_shape": str(self.model.output_shape)
        }
        
        # Count layer types
        conv_layers = sum(1 for layer in self.model.layers if 'Conv' in type(layer).__name__)
        lstm_layers = sum(1 for layer in self.model.layers if 'LSTM' in type(layer).__name__)
        dense_layers = sum(1 for layer in self.model.layers if 'Dense' in type(layer).__name__)
        
        info.update({
            "conv_layers": conv_layers,
            "lstm_layers": lstm_layers,
            "dense_layers": dense_layers
        })
        
        return info
    
    def load_dataset(self) -> Tuple[np.ndarray, np.ndarray]:
        """Load processed dataset"""
        logger.info("📂 Loading dataset...")
        
        X_data = []
        y_data = []
        
        for i, category in enumerate(self.categories):
            category_files = list(self.processed_dir.glob(f'{category}/*.npy'))
            logger.info(f"📁 Found {len(category_files)} {category} files")
            
            for file_path in category_files:
                try:
                    landmarks = np.load(file_path)
                    # Handle both sequence data (30, 51) and single frame data (51,)
                    if landmarks.shape == (30, 51) or landmarks.shape == (51,):
                        X_data.append(landmarks)
                        y_data.append(i)
                except Exception as e:
                    logger.warning(f"⚠️ Failed to load {file_path}: {e}")
        
        if len(X_data) == 0:
            logger.error("❌ No valid training data found!")
            return None, None
        
        X = np.array(X_data)
        y = np.array(y_data)
        
        logger.info(f"✅ Loaded {len(X)} samples with shape {X.shape}")
        return X, y
    
    def evaluate_model(self) -> Dict:
        """Evaluate current model accuracy"""
        if not self.model:
            return {"error": "No model loaded"}
        
        logger.info("🎯 Evaluating model accuracy...")
        
        X, y = self.load_dataset()
        if X is None:
            return {"error": "No dataset loaded"}
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y
        )
        
        # Reshape for CNN-LSTM based on input shape
        if len(X_test.shape) == 2 and X_test.shape[1] == 51:
            # Single frame data - add sequence dimension
            X_test_seq = X_test.reshape(X_test.shape[0], 1, X_test.shape[1])
        elif len(X_test.shape) == 3 and X_test.shape[1:] == (30, 51):
            # Already sequence data
            X_test_seq = X_test
        else:
            # Try to reshape to expected format
            X_test_seq = X_test.reshape(X_test.shape[0], -1, 51)
        
        # Make predictions
        y_pred_proba = self.model.predict(X_test_seq, verbose=0)
        y_pred = np.argmax(y_pred_proba, axis=1)
        
        # Calculate metrics
        accuracy = accuracy_score(y_test, y_pred)
        
        # Get detailed report
        report = classification_report(y_test, y_pred, target_names=self.categories, output_dict=True)
        
        # Get model info
        model_info = self.analyze_model_info()
        
        results = {
            "timestamp": datetime.now().isoformat(),
            "accuracy": float(accuracy),
            "total_samples": len(X),
            "train_samples": len(X_train),
            "test_samples": len(X_test),
            "model_info": model_info,
            "per_class_f1": {cat: report[cat]['f1-score'] for cat in self.categories},
            "confusion_matrix": confusion_matrix(y_test, y_pred).tolist()
        }
        
        # Print results
        print("\n" + "="*60)
        print("🎯 CURRENT MODEL PERFORMANCE")
        print("="*60)
        print(f"📊 Overall Accuracy: {accuracy:.1%}")
        print(f"📈 Total Parameters: {model_info['total_params']:,}")
        print(f"🔧 Trainable Parameters: {model_info['trainable_params']:,}")
        print(f"🏗️ Architecture: {model_info['conv_layers']} Conv1D + {model_info['lstm_layers']} LSTM + {model_info['dense_layers']} Dense")
        print(f"📊 Dataset: {len(X_train)} train / {len(X_test)} test samples")
        
        print(f"\n📋 Per-Class F1 Scores:")
        for category in self.categories:
            f1 = report[category]['f1-score']
            print(f"   {category:>12}: {f1:.3f}")
        
        return results
    
    def log_results_to_csv(self, results: Dict, notes: str = ""):
        """Log results to CSV file"""
        with open(self.results_csv, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                results['timestamp'],
                results['accuracy'],
                results['model_info']['total_params'],
                results['model_info']['trainable_params'],
                results['total_samples'],
                results['test_samples'],
                results['per_class_f1']['yoga'],
                results['per_class_f1']['bodyweight'],
                results['per_class_f1']['functional'],
                results['per_class_f1']['lifting'],
                notes
            ])
        logger.info(f"📝 Results logged to {self.results_csv}")
    
    def plot_accuracy_history(self):
        """Plot accuracy history from CSV"""
        try:
            import matplotlib.pyplot as plt
            import pandas as pd
        except ImportError:
            logger.error("❌ matplotlib or pandas not available for plotting")
            return
        
        if not self.results_csv.exists():
            logger.warning("⚠️ No results file found")
            return
        
        # Read CSV data
        df = pd.read_csv(self.results_csv)
        if len(df) == 0:
            logger.warning("⚠️ No data in results file")
            return
        
        # Convert timestamp
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        
        # Create plot
        plt.figure(figsize=(12, 8))
        
        # Main accuracy plot
        plt.subplot(2, 2, 1)
        plt.plot(df['timestamp'], df['accuracy'] * 100, 'o-', linewidth=2, markersize=6)
        plt.title('Model Accuracy Over Time')
        plt.xlabel('Date')
        plt.ylabel('Accuracy (%)')
        plt.grid(True, alpha=0.3)
        plt.xticks(rotation=45)
        
        # Per-class F1 scores
        plt.subplot(2, 2, 2)
        for category in self.categories:
            if f'{category}_f1' in df.columns:
                plt.plot(df['timestamp'], df[f'{category}_f1'], 'o-', label=category, linewidth=2)
        plt.title('Per-Class F1 Scores')
        plt.xlabel('Date')
        plt.ylabel('F1 Score')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.xticks(rotation=45)
        
        # Dataset size
        plt.subplot(2, 2, 3)
        plt.plot(df['timestamp'], df['total_samples'], 'o-', color='green', linewidth=2)
        plt.title('Dataset Size Over Time')
        plt.xlabel('Date')
        plt.ylabel('Total Samples')
        plt.grid(True, alpha=0.3)
        plt.xticks(rotation=45)
        
        # Model parameters
        plt.subplot(2, 2, 4)
        plt.plot(df['timestamp'], df['total_params'], 'o-', color='red', linewidth=2)
        plt.title('Model Parameters')
        plt.xlabel('Date')
        plt.ylabel('Total Parameters')
        plt.grid(True, alpha=0.3)
        plt.xticks(rotation=45)
        
        plt.tight_layout()
        
        # Save plot
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        plot_path = self.results_dir / f"accuracy_history_{timestamp}.png"
        plt.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.show()
        
        logger.info(f"📊 Plot saved to {plot_path}")
    
    def retrain_and_evaluate(self, epochs: int = 20, batch_size: int = 16):
        """Retrain model and evaluate"""
        logger.info("🔄 Starting model retraining...")
        
        # Get baseline accuracy
        baseline_results = self.evaluate_model()
        baseline_accuracy = baseline_results.get("accuracy", 0)
        
        # Initialize trainer
        trainer = PoseModelTrainer(processed_dir='models/data/process')
        
        # Train model
        history = trainer.train_model(epochs=epochs, batch_size=batch_size)
        
        # Save new model with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        new_model_path = f'models/models/saved/pose_model_retrained_{timestamp}.keras'
        trainer.save_model(new_model_path)
        
        # Load and evaluate new model
        self.model = tf.keras.models.load_model(new_model_path)
        new_results = self.evaluate_model()
        new_accuracy = new_results.get("accuracy", 0)
        
        # Log results
        improvement = new_accuracy - baseline_accuracy
        notes = f"Retrained {epochs} epochs, improvement: {improvement:+.1%}"
        self.log_results_to_csv(new_results, notes)
        
        print(f"\n🎯 RETRAINING RESULTS:")
        print(f"📊 Baseline Accuracy: {baseline_accuracy:.1%}")
        print(f"📈 New Accuracy: {new_accuracy:.1%}")
        print(f"🚀 Improvement: {improvement:+.1%}")
        
        return new_results

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Model Accuracy Tracker')
    parser.add_argument('--retrain', action='store_true', help='Retrain the model')
    parser.add_argument('--plot', action='store_true', help='Plot accuracy history')
    parser.add_argument('--epochs', type=int, default=20, help='Training epochs')
    parser.add_argument('--batch-size', type=int, default=16, help='Batch size')
    
    args = parser.parse_args()
    
    print("\n" + "="*60)
    print("🔬 PERFECT POSE - MODEL ACCURACY TRACKER")
    print("="*60)
    
    tracker = SimpleModelTracker()
    
    if args.retrain:
        results = tracker.retrain_and_evaluate(epochs=args.epochs, batch_size=args.batch_size)
    else:
        results = tracker.evaluate_model()
        if results and "error" not in results:
            tracker.log_results_to_csv(results, "Manual evaluation")
    
    if args.plot:
        tracker.plot_accuracy_history()
    
    print("\n✅ Analysis complete!")
    print(f"📁 Results saved to: {tracker.results_dir}")

if __name__ == "__main__":
    main() 