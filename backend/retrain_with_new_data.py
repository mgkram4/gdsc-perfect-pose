#!/usr/bin/env python3
"""
Perfect Pose - Retrain with New Data
Retrains the model using all available data including new integrated samples
"""

import logging
import os
from datetime import datetime
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_all_data():
    """Load ALL available processed data"""
    process_dir = Path("models/data/process")
    categories = ['yoga', 'bodyweight', 'functional', 'lifting']
    
    X, y, labels = [], [], []
    
    print("📊 Loading ALL available data...")
    total_samples = 0
    
    for cat_idx, category in enumerate(categories):
        cat_dir = process_dir / category
        if not cat_dir.exists():
            print(f"❌ {category} directory not found")
            continue
            
        # Get all .npy files (both old and new)
        npy_files = list(cat_dir.glob("*.npy"))
        print(f"📁 {category}: {len(npy_files)} files found")
        
        for npy_file in npy_files:
            try:
                data = np.load(npy_file)
                
                # Handle different data shapes and ensure consistent dimensions
                if len(data.shape) == 1:
                    # Single timestep, expand to sequence of 30x51
                    if len(data) == 51:  # Expected keypoint size
                        data = np.tile(data.reshape(1, -1), (30, 1))
                    else:
                        logger.warning(f"Unexpected data shape {data.shape} in {npy_file}")
                        continue
                elif len(data.shape) == 2:
                    # Ensure we have exactly 30 timesteps and 51 features
                    if data.shape[1] != 51:
                        logger.warning(f"Unexpected feature size {data.shape[1]} in {npy_file}")
                        continue
                    
                    if data.shape[0] > 30:
                        # Too many timesteps, take first 30
                        data = data[:30]
                    elif data.shape[0] < 30:
                        # Too few timesteps, repeat last frame
                        last_frame = data[-1:] 
                        repeats = 30 - data.shape[0]
                        padding = np.tile(last_frame, (repeats, 1))
                        data = np.vstack([data, padding])
                else:
                    logger.warning(f"Unexpected data dimensions {data.shape} in {npy_file}")
                    continue
                
                # Final validation
                if data.shape != (30, 51):
                    logger.warning(f"Data shape {data.shape} not (30, 51) in {npy_file}")
                    continue
                
                X.append(data)
                y.append(cat_idx)
                labels.append(category)
                total_samples += 1
                
            except Exception as e:
                logger.warning(f"Failed to load {npy_file}: {e}")
    
    print(f"✅ Loaded {total_samples} total samples!")
    
    # Convert to numpy arrays
    X = np.array(X)
    y = np.array(y)
    
    print(f"📊 Dataset shape: {X.shape}")
    
    # Print per-category counts
    for cat_idx, category in enumerate(categories):
        count = np.sum(y == cat_idx)
        print(f"   {category}: {count} samples")
    
    return X, y, categories

def create_model(input_shape, num_classes):
    """Create improved model architecture"""
    model = tf.keras.Sequential([
        # Conv1D layers for feature extraction
        tf.keras.layers.Conv1D(64, 3, activation='relu', input_shape=input_shape),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        tf.keras.layers.Conv1D(128, 3, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        tf.keras.layers.Conv1D(64, 3, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.GlobalMaxPooling1D(),
        
        # Dense classification layers
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dropout(0.5),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

def train_model():
    """Train model with all available data"""
    print("\n" + "="*60)
    print("🚀 PERFECT POSE - RETRAINING WITH NEW DATA")
    print("="*60)
    
    # Load all data
    X, y, categories = load_all_data()
    
    if len(X) < 10:
        print("❌ Not enough data to train!")
        return
    
    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"📊 Training set: {len(X_train)} samples")
    print(f"📊 Test set: {len(X_test)} samples")
    
    # Calculate class weights for balanced training
    class_weights = compute_class_weight(
        'balanced', 
        classes=np.unique(y_train), 
        y=y_train
    )
    class_weight_dict = dict(enumerate(class_weights))
    print(f"📊 Class weights: {class_weight_dict}")
    
    # Create model
    model = create_model((X.shape[1], X.shape[2]), len(categories))
    
    # Compile with appropriate settings
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    print(f"🏗️ Model architecture:")
    model.summary()
    
    # Train model
    print("\n🔥 Starting training...")
    
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=10,
            restore_best_weights=True
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-6
        )
    ]
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=50,
        batch_size=16,
        class_weight=class_weight_dict,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate final performance
    train_loss, train_acc = model.evaluate(X_train, y_train, verbose=0)
    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    
    print(f"\n" + "="*60)
    print("🎯 FINAL RESULTS")
    print("="*60)
    print(f"📊 Training Accuracy: {train_acc:.1%}")
    print(f"📊 Test Accuracy: {test_acc:.1%}")
    print(f"📊 Training samples: {len(X_train)}")
    print(f"📊 Test samples: {len(X_test)}")
    
    # Save model
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    model_path = f"models/models/saved/pose_model_retrained_large_{timestamp}.keras"
    model.save(model_path)
    print(f"💾 Model saved: {model_path}")
    
    # Plot training history
    plt.figure(figsize=(12, 4))
    
    plt.subplot(1, 2, 1)
    plt.plot(history.history['accuracy'], label='Training')
    plt.plot(history.history['val_accuracy'], label='Validation')
    plt.title('Model Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.grid(True)
    
    plt.subplot(1, 2, 2)
    plt.plot(history.history['loss'], label='Training')
    plt.plot(history.history['val_loss'], label='Validation')
    plt.title('Model Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    plt.grid(True)
    
    plt.tight_layout()
    plot_path = f"research_results/training_history_large_{timestamp}.png"
    plt.savefig(plot_path, dpi=300, bbox_inches='tight')
    print(f"📊 Training plots saved: {plot_path}")
    
    return test_acc, len(X_train) + len(X_test)

if __name__ == "__main__":
    train_model() 