#!/usr/bin/env python3
"""
Model Research Analysis & Accuracy Tracking Script
=================================================
This script provides comprehensive model analysis for the Perfect Pose CNN-LSTM model,
including accuracy logging, parameter analysis, architecture visualization, and 
training progress tracking with matplotlib.

Features:
- Current model accuracy evaluation
- Model architecture & parameter analysis  
- Training history visualization
- Accuracy tracking over time
- Model improvement recommendations
- Research-grade logging and metrics

Usage:
    python model_research_analysis.py [--retrain] [--visualize] [--analyze]
"""

import argparse
import json
import logging
import os
import pickle
import sys
import warnings
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import tensorflow as tf
from sklearn.metrics import (accuracy_score, classification_report,
                             confusion_matrix, precision_recall_fscore_support)
from sklearn.model_selection import train_test_split
from tensorflow import keras

# Suppress warnings for cleaner output
warnings.filterwarnings('ignore')
tf.get_logger().setLevel('ERROR')

# Add current directory to path
sys.path.append('.')

from models.cnn_lstm import PoseModelTrainer
from utils.process_img import extract_pose_landmarks, normalize_landmarks

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('research_logs.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class ModelAnalyzer:
    """Comprehensive model analysis and research utilities"""
    
    def __init__(self, model_path: str = 'models/models/saved/pose_model.keras'):
        self.model_path = model_path
        self.categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        self.processed_dir = Path('models/data/process')
        self.results_dir = Path('research_results')
        self.results_dir.mkdir(exist_ok=True)
        
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
    
    def analyze_model_architecture(self) -> Dict:
        """Analyze and log detailed model architecture"""
        if not self.model:
            return {"error": "No model loaded"}
        
        logger.info("🔍 Analyzing Model Architecture...")
        
        # Basic model info
        analysis = {
            "timestamp": datetime.now().isoformat(),
            "total_params": self.model.count_params(),
            "trainable_params": sum([tf.keras.backend.count_params(w) for w in self.model.trainable_weights]),
            "non_trainable_params": sum([tf.keras.backend.count_params(w) for w in self.model.non_trainable_weights]),
            "layers": [],
            "input_shape": str(self.model.input_shape),
            "output_shape": str(self.model.output_shape)
        }
        
        # Detailed layer analysis
        conv_layers = 0
        lstm_layers = 0
        dense_layers = 0
        
        for i, layer in enumerate(self.model.layers):
            layer_info = {
                "index": i,
                "name": layer.name,
                "type": type(layer).__name__,
                "output_shape": str(layer.output_shape),
                "params": layer.count_params()
            }
            
            # Count layer types
            if 'Conv' in type(layer).__name__:
                conv_layers += 1
                if hasattr(layer, 'filters'):
                    layer_info["filters"] = layer.filters
                if hasattr(layer, 'kernel_size'):
                    layer_info["kernel_size"] = layer.kernel_size
            elif 'LSTM' in type(layer).__name__:
                lstm_layers += 1
                if hasattr(layer, 'units'):
                    layer_info["units"] = layer.units
                if hasattr(layer, 'return_sequences'):
                    layer_info["return_sequences"] = layer.return_sequences
            elif 'Dense' in type(layer).__name__:
                dense_layers += 1
                if hasattr(layer, 'units'):
                    layer_info["units"] = layer.units
                    
            analysis["layers"].append(layer_info)
        
        # Summary counts
        analysis["layer_counts"] = {
            "conv1d_layers": conv_layers,
            "lstm_layers": lstm_layers, 
            "dense_layers": dense_layers,
            "total_layers": len(self.model.layers)
        }
        
        # Print architecture summary
        print("\n" + "="*80)
        print("🏗️ MODEL ARCHITECTURE ANALYSIS")
        print("="*80)
        print(f"📊 Total Parameters: {analysis['total_params']:,}")
        print(f"🔧 Trainable Parameters: {analysis['trainable_params']:,}")
        print(f"🔒 Non-trainable Parameters: {analysis['non_trainable_params']:,}")
        print(f"📥 Input Shape: {analysis['input_shape']}")
        print(f"📤 Output Shape: {analysis['output_shape']}")
        print(f"\n🏗️ Layer Composition:")
        print(f"   🧮 Conv1D Layers: {conv_layers}")
        print(f"   🔄 LSTM Layers: {lstm_layers}")
        print(f"   🎯 Dense Layers: {dense_layers}")
        print(f"   📚 Total Layers: {len(self.model.layers)}")
        
        # Save architecture analysis
        with open(self.results_dir / f"architecture_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json", 'w') as f:
            json.dump(analysis, f, indent=2)
        
        return analysis
    
    def load_dataset(self) -> Tuple[np.ndarray, np.ndarray]:
        """Load and prepare dataset for evaluation"""
        logger.info("📂 Loading dataset...")
        
        X_data = []
        y_data = []
        
        for i, category in enumerate(self.categories):
            category_files = list(self.processed_dir.glob(f'{category}/*.npy'))
            logger.info(f"📁 Found {len(category_files)} {category} files")
            
            for file_path in category_files:
                try:
                    landmarks = np.load(file_path)
                    if landmarks.shape == (51,):  # 17 landmarks * 3 coords
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
    
    def evaluate_current_accuracy(self) -> Dict:
        """Comprehensive accuracy evaluation of current model"""
        if not self.model:
            return {"error": "No model loaded"}
        
        logger.info("🎯 Evaluating Current Model Accuracy...")
        
        X, y = self.load_dataset()
        if X is None:
            return {"error": "No dataset loaded"}
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y
        )
        
        # Reshape for CNN-LSTM (add sequence dimension for single timestep)
        X_test_seq = X_test.reshape(X_test.shape[0], 1, X_test.shape[1])
        
        # Make predictions
        y_pred_proba = self.model.predict(X_test_seq, verbose=0)
        y_pred = np.argmax(y_pred_proba, axis=1)
        
        # Calculate metrics
        accuracy = accuracy_score(y_test, y_pred)
        precision, recall, f1, support = precision_recall_fscore_support(y_test, y_pred, average=None)
        
        # Detailed classification report
        class_report = classification_report(y_test, y_pred, target_names=self.categories, output_dict=True)
        
        # Confusion matrix
        cm = confusion_matrix(y_test, y_pred)
        
        results = {
            "timestamp": datetime.now().isoformat(),
            "overall_accuracy": float(accuracy),
            "total_samples": len(X),
            "train_samples": len(X_train),
            "test_samples": len(X_test),
            "class_metrics": {
                self.categories[i]: {
                    "precision": float(precision[i]),
                    "recall": float(recall[i]),
                    "f1_score": float(f1[i]),
                    "support": int(support[i])
                } for i in range(len(self.categories))
            },
            "classification_report": class_report,
            "confusion_matrix": cm.tolist(),
            "predictions_sample": {
                "true_labels": y_test[:10].tolist(),
                "predicted_labels": y_pred[:10].tolist(),
                "prediction_probabilities": y_pred_proba[:10].tolist()
            }
        }
        
        # Print results
        print("\n" + "="*80)
        print("🎯 CURRENT MODEL ACCURACY ANALYSIS")
        print("="*80)
        print(f"📊 Overall Accuracy: {accuracy:.1%}")
        print(f"📈 Training Samples: {len(X_train)}")
        print(f"🧪 Test Samples: {len(X_test)}")
        print(f"🎪 Total Dataset Size: {len(X)}")
        
        print(f"\n📋 Per-Class Performance:")
        for category in self.categories:
            metrics = results["class_metrics"][category]
            print(f"   {category:>12}: P={metrics['precision']:.2f} R={metrics['recall']:.2f} F1={metrics['f1_score']:.2f} ({metrics['support']} samples)")
        
        # Save results
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        with open(self.results_dir / f"accuracy_evaluation_{timestamp}.json", 'w') as f:
            json.dump(results, f, indent=2)
        
        return results
    
    def create_accuracy_visualization(self, results: Dict) -> None:
        """Create comprehensive accuracy visualizations"""
        logger.info("📊 Creating accuracy visualizations...")
        
        # Set up the plotting style
        plt.style.use('seaborn-v0_8-darkgrid')
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle('Perfect Pose Model - Accuracy Analysis', fontsize=16, fontweight='bold')
        
        # 1. Confusion Matrix Heatmap
        cm = np.array(results["confusion_matrix"])
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                   xticklabels=self.categories, yticklabels=self.categories,
                   ax=axes[0,0])
        axes[0,0].set_title('Confusion Matrix')
        axes[0,0].set_xlabel('Predicted')
        axes[0,0].set_ylabel('Actual')
        
        # 2. Per-Class Performance Metrics
        categories = list(results["class_metrics"].keys())
        precision = [results["class_metrics"][cat]["precision"] for cat in categories]
        recall = [results["class_metrics"][cat]["recall"] for cat in categories]
        f1 = [results["class_metrics"][cat]["f1_score"] for cat in categories]
        
        x = np.arange(len(categories))
        width = 0.25
        
        axes[0,1].bar(x - width, precision, width, label='Precision', alpha=0.8)
        axes[0,1].bar(x, recall, width, label='Recall', alpha=0.8)
        axes[0,1].bar(x + width, f1, width, label='F1-Score', alpha=0.8)
        
        axes[0,1].set_xlabel('Exercise Categories')
        axes[0,1].set_ylabel('Score')
        axes[0,1].set_title('Per-Class Performance Metrics')
        axes[0,1].set_xticks(x)
        axes[0,1].set_xticklabels(categories, rotation=45)
        axes[0,1].legend()
        axes[0,1].set_ylim(0, 1.1)
        
        # 3. Sample Distribution
        support = [results["class_metrics"][cat]["support"] for cat in categories]
        colors = plt.cm.Set3(np.linspace(0, 1, len(categories)))
        axes[1,0].pie(support, labels=categories, autopct='%1.1f%%', colors=colors)
        axes[1,0].set_title('Test Sample Distribution')
        
        # 4. Overall Accuracy Gauge
        accuracy = results["overall_accuracy"]
        axes[1,1].pie([accuracy, 1-accuracy], labels=['Correct', 'Incorrect'], 
                     autopct='%1.1f%%', colors=['#2ecc71', '#e74c3c'], startangle=90)
        axes[1,1].set_title(f'Overall Accuracy: {accuracy:.1%}')
        
        plt.tight_layout()
        
        # Save visualization
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        plt.savefig(self.results_dir / f"accuracy_analysis_{timestamp}.png", dpi=300, bbox_inches='tight')
        plt.show()
        
        logger.info(f"📊 Visualization saved to {self.results_dir}")

class TrainingTracker:
    """Track training progress and accuracy over time"""
    
    def __init__(self, results_dir: Path = Path('research_results')):
        self.results_dir = results_dir
        self.results_dir.mkdir(exist_ok=True)
        self.history_file = self.results_dir / 'training_history.pkl'
        self.training_history = self.load_training_history()
    
    def load_training_history(self) -> List[Dict]:
        """Load existing training history"""
        if self.history_file.exists():
            try:
                with open(self.history_file, 'rb') as f:
                    return pickle.load(f)
            except Exception as e:
                logger.warning(f"⚠️ Could not load training history: {e}")
        return []
    
    def save_training_history(self) -> None:
        """Save training history to file"""
        with open(self.history_file, 'wb') as f:
            pickle.dump(self.training_history, f)
    
    def log_training_session(self, accuracy: float, model_params: Dict, 
                           training_config: Dict = None) -> None:
        """Log a training session result"""
        session = {
            "timestamp": datetime.now().isoformat(),
            "accuracy": accuracy,
            "model_params": model_params,
            "training_config": training_config or {}
        }
        
        self.training_history.append(session)
        self.save_training_history()
        
        logger.info(f"📝 Logged training session - Accuracy: {accuracy:.1%}")
    
    def plot_accuracy_over_time(self) -> None:
        """Plot accuracy improvements over time"""
        if not self.training_history:
            logger.warning("⚠️ No training history to plot")
            return
        
        # Extract data
        timestamps = [datetime.fromisoformat(session["timestamp"]) for session in self.training_history]
        accuracies = [session["accuracy"] for session in self.training_history]
        
        # Create plot
        plt.figure(figsize=(12, 6))
        plt.plot(timestamps, accuracies, 'o-', linewidth=2, markersize=8, 
                color='#3498db', markerfacecolor='#2980b9')
        
        # Add trend line
        if len(accuracies) > 1:
            z = np.polyfit(range(len(accuracies)), accuracies, 1)
            p = np.poly1d(z)
            plt.plot(timestamps, p(range(len(accuracies))), "--", 
                    alpha=0.7, color='#e74c3c', label='Trend')
        
        plt.title('Model Accuracy Over Time', fontsize=14, fontweight='bold')
        plt.xlabel('Training Session Date')
        plt.ylabel('Accuracy')
        plt.grid(True, alpha=0.3)
        plt.legend()
        
        # Format y-axis as percentage
        plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda y, _: '{:.0%}'.format(y)))
        
        # Rotate x-axis labels
        plt.xticks(rotation=45)
        
        # Add annotations for best accuracy
        if accuracies:
            best_idx = np.argmax(accuracies)
            best_accuracy = accuracies[best_idx]
            best_time = timestamps[best_idx]
            plt.annotate(f'Best: {best_accuracy:.1%}', 
                        xy=(best_time, best_accuracy), 
                        xytext=(10, 10), textcoords='offset points',
                        bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7),
                        arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0'))
        
        plt.tight_layout()
        
        # Save plot
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        plt.savefig(self.results_dir / f"accuracy_over_time_{timestamp}.png", dpi=300, bbox_inches='tight')
        plt.show()
        
        logger.info(f"📈 Accuracy timeline saved to {self.results_dir}")

def retrain_and_track_model(epochs: int = 50, batch_size: int = 32) -> None:
    """Retrain model and track performance"""
    logger.info("🔄 Starting model retraining...")
    
    # Initialize components
    trainer = PoseModelTrainer(processed_dir='models/data/process')
    tracker = TrainingTracker()
    analyzer = ModelAnalyzer()
    
    # Get current accuracy for comparison
    current_results = analyzer.evaluate_current_accuracy()
    current_accuracy = current_results.get("overall_accuracy", 0)
    
    logger.info(f"📊 Current model accuracy: {current_accuracy:.1%}")
    
    # Train model
    history = trainer.train_model(epochs=epochs, batch_size=batch_size)
    
    # Save new model
    model_path = f'models/models/saved/pose_model_retrained_{datetime.now().strftime("%Y%m%d_%H%M%S")}.keras'
    trainer.save_model(model_path)
    
    # Evaluate new model
    analyzer_new = ModelAnalyzer(model_path)
    new_results = analyzer_new.evaluate_current_accuracy()
    new_accuracy = new_results.get("overall_accuracy", 0)
    
    # Log training session
    model_info = analyzer_new.analyze_model_architecture()
    training_config = {
        "epochs": epochs,
        "batch_size": batch_size,
        "validation_split": 0.2
    }
    
    tracker.log_training_session(new_accuracy, model_info, training_config)
    
    # Show improvement
    improvement = new_accuracy - current_accuracy
    logger.info(f"📈 New model accuracy: {new_accuracy:.1%}")
    logger.info(f"🎯 Improvement: {improvement:+.1%}")
    
    # Create visualizations
    analyzer_new.create_accuracy_visualization(new_results)
    tracker.plot_accuracy_over_time()

def main():
    """Main research analysis function"""
    parser = argparse.ArgumentParser(description='Model Research Analysis Tool')
    parser.add_argument('--retrain', action='store_true', help='Retrain the model')
    parser.add_argument('--visualize', action='store_true', help='Create accuracy visualizations')
    parser.add_argument('--analyze', action='store_true', help='Analyze model architecture')
    parser.add_argument('--epochs', type=int, default=50, help='Training epochs (if retraining)')
    parser.add_argument('--batch-size', type=int, default=32, help='Batch size (if retraining)')
    
    args = parser.parse_args()
    
    # Default to full analysis if no specific action specified
    if not any([args.retrain, args.visualize, args.analyze]):
        args.analyze = True
        args.visualize = True
    
    print("\n" + "="*80)
    print("🔬 PERFECT POSE - MODEL RESEARCH ANALYSIS")
    print("="*80)
    
    analyzer = ModelAnalyzer()
    tracker = TrainingTracker()
    
    if args.analyze:
        # Analyze current model
        architecture_analysis = analyzer.analyze_model_architecture()
        accuracy_results = analyzer.evaluate_current_accuracy()
        
        # Log current session if we have results
        if accuracy_results and "overall_accuracy" in accuracy_results:
            tracker.log_training_session(
                accuracy_results["overall_accuracy"], 
                architecture_analysis
            )
    
    if args.visualize:
        # Create visualizations
        if args.analyze:
            analyzer.create_accuracy_visualization(accuracy_results)
        tracker.plot_accuracy_over_time()
    
    if args.retrain:
        # Retrain model and track progress
        retrain_and_track_model(epochs=args.epochs, batch_size=args.batch_size)
    
    print("\n✅ Research analysis complete!")
    print(f"📁 Results saved to: {analyzer.results_dir}")

if __name__ == "__main__":
    main() 