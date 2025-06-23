#!/usr/bin/env python3
"""
Model Improvement Pipeline
=========================
Systematic approach to improve pose classification model accuracy.

Current Issues Identified:
- Very small dataset (78 samples)
- Poor performance on functional/lifting (0.0 F1)
- Potential overfitting with current architecture

Improvement Strategy:
1. Data augmentation & expansion
2. Architecture optimization
3. Training strategy improvements
4. Regularization techniques
5. Hyperparameter tuning

Usage:
    python model_improvement_pipeline.py --strategy <strategy_name>
"""

import argparse
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
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau

# Suppress warnings
warnings.filterwarnings('ignore')
tf.get_logger().setLevel('ERROR')

# Add current directory to path
sys.path.append('.')

from model_accuracy_tracker import SimpleModelTracker
from models.cnn_lstm import PoseModelTrainer

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class ModelImprover:
    """Systematic model improvement pipeline"""
    
    def __init__(self):
        self.categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        self.processed_dir = Path('models/data/process')
        self.results_dir = Path('research_results')
        self.results_dir.mkdir(exist_ok=True)
        self.tracker = SimpleModelTracker()
        
        # Load current dataset
        self.X, self.y = self.tracker.load_dataset()
        if self.X is not None:
            logger.info(f"✅ Loaded dataset: {self.X.shape}")
        else:
            logger.error("❌ Failed to load dataset")
    
    def strategy_1_data_augmentation(self) -> str:
        """Strategy 1: Increase dataset size through data augmentation"""
        logger.info("🔄 Strategy 1: Data Augmentation")
        
        if self.X is None:
            return "Failed - No dataset"
        
        # Create augmented sequences by adding noise and variations
        augmented_X = []
        augmented_y = []
        
        for i, (sequence, label) in enumerate(zip(self.X, self.y)):
            # Original data
            augmented_X.append(sequence)
            augmented_y.append(label)
            
            # Augmentation 1: Add small random noise
            noise = np.random.normal(0, 0.01, sequence.shape)
            augmented_X.append(sequence + noise)
            augmented_y.append(label)
            
            # Augmentation 2: Scale coordinates slightly
            scale_factor = np.random.uniform(0.95, 1.05)
            augmented_X.append(sequence * scale_factor)
            augmented_y.append(label)
            
            # Augmentation 3: Time shift (circular shift)
            shift = np.random.randint(1, 5)
            shifted_sequence = np.roll(sequence, shift, axis=0)
            augmented_X.append(shifted_sequence)
            augmented_y.append(label)
        
        # Convert to numpy arrays
        X_augmented = np.array(augmented_X)
        y_augmented = np.array(augmented_y)
        
        logger.info(f"📈 Dataset expanded from {len(self.X)} to {len(X_augmented)} samples")
        
        # Train model with augmented data
        model = self._create_improved_model_v1()
        history = self._train_model_with_improvements(model, X_augmented, y_augmented, "data_augmentation")
        
        return f"Completed - Dataset expanded to {len(X_augmented)} samples"
    
    def strategy_2_architecture_optimization(self) -> str:
        """Strategy 2: Optimize model architecture for small dataset"""
        logger.info("🏗️ Strategy 2: Architecture Optimization")
        
        if self.X is None:
            return "Failed - No dataset"
        
        # Create a more suitable architecture for small dataset
        model = self._create_improved_model_v2()
        history = self._train_model_with_improvements(model, self.X, self.y, "architecture_v2")
        
        return "Completed - Optimized architecture for small dataset"
    
    def strategy_3_regularization_dropout(self) -> str:
        """Strategy 3: Add regularization and dropout to prevent overfitting"""
        logger.info("🛡️ Strategy 3: Regularization & Dropout")
        
        if self.X is None:
            return "Failed - No dataset"
        
        model = self._create_improved_model_v3()
        history = self._train_model_with_improvements(model, self.X, self.y, "regularized_v3")
        
        return "Completed - Added regularization and dropout"
    
    def strategy_4_class_balancing(self) -> str:
        """Strategy 4: Address class imbalance with weighted training"""
        logger.info("⚖️ Strategy 4: Class Balancing")
        
        if self.X is None:
            return "Failed - No dataset"
        
        # Calculate class weights to handle imbalance
        class_weights = compute_class_weight('balanced', classes=np.unique(self.y), y=self.y)
        class_weight_dict = {i: weight for i, weight in enumerate(class_weights)}
        
        logger.info(f"📊 Class weights: {class_weight_dict}")
        
        model = self._create_improved_model_v2()  # Use optimized architecture
        history = self._train_model_with_improvements(
            model, self.X, self.y, "class_balanced", class_weights=class_weight_dict
        )
        
        return f"Completed - Applied class weights: {class_weight_dict}"
    
    def strategy_5_ensemble_approach(self) -> str:
        """Strategy 5: Simple ensemble of multiple models"""
        logger.info("🎭 Strategy 5: Ensemble Approach")
        
        if self.X is None:
            return "Failed - No dataset"
        
        # Train 3 different models with different architectures
        models = []
        
        # Model 1: Optimized architecture
        model1 = self._create_improved_model_v2()
        self._train_model_with_improvements(model1, self.X, self.y, "ensemble_model1")
        models.append(model1)
        
        # Model 2: Regularized architecture
        model2 = self._create_improved_model_v3()
        self._train_model_with_improvements(model2, self.X, self.y, "ensemble_model2")
        models.append(model2)
        
        # Model 3: Different architecture
        model3 = self._create_alternative_model()
        self._train_model_with_improvements(model3, self.X, self.y, "ensemble_model3")
        models.append(model3)
        
        # Evaluate ensemble
        accuracy = self._evaluate_ensemble(models)
        
        # Log ensemble results
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.tracker.log_results_to_csv({
            'timestamp': datetime.now().isoformat(),
            'accuracy': accuracy,
            'model_info': {'total_params': sum(m.count_params() for m in models)},
            'total_samples': len(self.X),
            'test_samples': int(len(self.X) * 0.3),
            'per_class_f1': {'yoga': 0, 'bodyweight': 0, 'functional': 0, 'lifting': 0}
        }, f"Ensemble of 3 models")
        
        return f"Completed - Ensemble accuracy: {accuracy:.1%}"
    
    def _create_improved_model_v1(self):
        """Improved model v1: Better for small datasets"""
        model = keras.Sequential([
            layers.Input(shape=(30, 51)),
            
            # Simplified conv layers
            layers.Conv1D(32, 3, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.3),
            
            layers.Conv1D(64, 3, activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling1D(2),
            layers.Dropout(0.3),
            
            # Single LSTM
            layers.LSTM(64, return_sequences=False),
            layers.BatchNormalization(),
            layers.Dropout(0.4),
            
            # Simplified dense layers
            layers.Dense(32, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.3),
            
            layers.Dense(len(self.categories), activation='softmax')
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def _create_improved_model_v2(self):
        """Improved model v2: Optimized for pose sequences"""
        model = keras.Sequential([
            layers.Input(shape=(30, 51)),
            
            # Feature extraction
            layers.Conv1D(16, 5, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.2),
            
            layers.Conv1D(32, 3, activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling1D(2),
            layers.Dropout(0.2),
            
            # Temporal modeling
            layers.LSTM(32, return_sequences=True),
            layers.Dropout(0.3),
            layers.LSTM(16),
            layers.Dropout(0.3),
            
            # Classification
            layers.Dense(16, activation='relu'),
            layers.Dropout(0.3),
            layers.Dense(len(self.categories), activation='softmax')
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.0005),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def _create_improved_model_v3(self):
        """Improved model v3: Heavy regularization"""
        model = keras.Sequential([
            layers.Input(shape=(30, 51)),
            
            layers.Conv1D(32, 3, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)),
            layers.BatchNormalization(),
            layers.Dropout(0.4),
            
            layers.Conv1D(64, 3, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)),
            layers.BatchNormalization(),
            layers.MaxPooling1D(2),
            layers.Dropout(0.4),
            
            layers.LSTM(64, return_sequences=False, dropout=0.3, recurrent_dropout=0.3),
            layers.BatchNormalization(),
            
            layers.Dense(32, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)),
            layers.Dropout(0.5),
            
            layers.Dense(len(self.categories), activation='softmax')
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.0003),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def _create_alternative_model(self):
        """Alternative architecture: CNN-only approach"""
        model = keras.Sequential([
            layers.Input(shape=(30, 51)),
            
            layers.Conv1D(64, 5, activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling1D(2),
            layers.Dropout(0.3),
            
            layers.Conv1D(128, 3, activation='relu'),
            layers.BatchNormalization(),
            layers.MaxPooling1D(2),
            layers.Dropout(0.3),
            
            layers.Conv1D(64, 3, activation='relu'),
            layers.BatchNormalization(),
            layers.GlobalAveragePooling1D(),
            layers.Dropout(0.4),
            
            layers.Dense(32, activation='relu'),
            layers.Dropout(0.3),
            layers.Dense(len(self.categories), activation='softmax')
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def _train_model_with_improvements(self, model, X, y, strategy_name, class_weights=None):
        """Train model with improved training strategy"""
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y
        )
        
        # Callbacks for better training
        callbacks = [
            EarlyStopping(
                monitor='val_loss',
                patience=10,
                restore_best_weights=True
            ),
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,
                min_lr=1e-7
            )
        ]
        
        # Train model
        history = model.fit(
            X_train, y_train,
            epochs=100,  # More epochs with early stopping
            batch_size=8,  # Smaller batch size for small dataset
            validation_data=(X_test, y_test),
            callbacks=callbacks,
            class_weight=class_weights,
            verbose=1
        )
        
        # Evaluate and save model
        test_accuracy = model.evaluate(X_test, y_test, verbose=0)[1]
        
        # Save model
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        model_path = f'models/models/saved/pose_model_{strategy_name}_{timestamp}.keras'
        model.save(model_path)
        
        logger.info(f"💾 Saved {strategy_name} model: {model_path}")
        logger.info(f"🎯 Test accuracy: {test_accuracy:.1%}")
        
        # Log results using tracker
        self.tracker.model = model  # Update tracker's model
        results = self.tracker.evaluate_model()
        if results and "error" not in results:
            self.tracker.log_results_to_csv(results, f"Strategy: {strategy_name}")
        
        return history
    
    def _evaluate_ensemble(self, models):
        """Evaluate ensemble of models"""
        if self.X is None:
            return 0
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            self.X, self.y, test_size=0.3, random_state=42, stratify=self.y
        )
        
        # Get predictions from all models
        predictions = []
        for model in models:
            pred = model.predict(X_test, verbose=0)
            predictions.append(pred)
        
        # Average predictions
        ensemble_pred = np.mean(predictions, axis=0)
        ensemble_classes = np.argmax(ensemble_pred, axis=1)
        
        # Calculate accuracy
        accuracy = np.mean(ensemble_classes == y_test)
        
        return accuracy

def main():
    """Main improvement pipeline"""
    parser = argparse.ArgumentParser(description='Model Improvement Pipeline')
    parser.add_argument('--strategy', type=str, choices=[
        'data_augmentation', 'architecture', 'regularization', 
        'class_balancing', 'ensemble', 'all'
    ], default='all', help='Improvement strategy to apply')
    
    args = parser.parse_args()
    
    print("\n" + "="*70)
    print("🚀 PERFECT POSE - MODEL IMPROVEMENT PIPELINE")
    print("="*70)
    
    improver = ModelImprover()
    
    # Get baseline accuracy
    print("\n📊 BASELINE ACCURACY:")
    baseline_results = improver.tracker.evaluate_model()
    baseline_accuracy = baseline_results.get("accuracy", 0) if baseline_results else 0
    print(f"🎯 Current Accuracy: {baseline_accuracy:.1%}")
    
    strategies = {
        'data_augmentation': improver.strategy_1_data_augmentation,
        'architecture': improver.strategy_2_architecture_optimization,
        'regularization': improver.strategy_3_regularization_dropout,
        'class_balancing': improver.strategy_4_class_balancing,
        'ensemble': improver.strategy_5_ensemble_approach
    }
    
    if args.strategy == 'all':
        print("\n🔄 Running all improvement strategies...")
        for strategy_name, strategy_func in strategies.items():
            print(f"\n--- {strategy_name.upper()} ---")
            result = strategy_func()
            print(f"✅ {result}")
    else:
        print(f"\n🔄 Running {args.strategy} strategy...")
        result = strategies[args.strategy]()
        print(f"✅ {result}")
    
    # Generate final comparison plot
    improver.tracker.plot_accuracy_history()
    
    print("\n🎉 Model improvement pipeline completed!")
    print(f"📁 Results saved to: {improver.results_dir}")

if __name__ == "__main__":
    main() 