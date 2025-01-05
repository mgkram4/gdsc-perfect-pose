# backend/ML/cnn_lstm.py

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers import LSTM, Dense, Dropout, Conv1D, MaxPooling1D, Input, BatchNormalization
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PoseModelTrainer:
    def __init__(self, processed_dir=None, sequence_length=30, num_features=51):
        self.processed_dir = processed_dir if processed_dir else 'data/processed'
        self.sequence_length = sequence_length
        self.num_features = num_features
        self.categories = ['yoga', 'bodyweight', 'functional', 'lifting']
        self.model = self._build_enhanced_model()
        
    def _build_enhanced_model(self):
        model = Sequential([
            Input(shape=(self.sequence_length, self.num_features)),
            
            Conv1D(filters=64, kernel_size=3, activation='relu'),
            BatchNormalization(),
            MaxPooling1D(pool_size=2),
            Dropout(0.2),
            
            Conv1D(filters=128, kernel_size=3, activation='relu'),
            BatchNormalization(),
            MaxPooling1D(pool_size=2),
            Dropout(0.2),
            
            LSTM(128, return_sequences=True),
            BatchNormalization(),
            Dropout(0.3),
            
            LSTM(64),
            BatchNormalization(),
            Dropout(0.3),
            
            Dense(64, activation='relu'),
            BatchNormalization(),
            Dropout(0.3),
            
            Dense(32, activation='relu'),
            BatchNormalization(),
            
            Dense(len(self.categories), activation='softmax')
        ])
        
        model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def load_training_data(self):
        X = []
        y = []
        
        for idx, category in enumerate(self.categories):
            category_dir = os.path.join(self.processed_dir, category)
            if os.path.exists(category_dir):
                files = [f for f in os.listdir(category_dir) if f.endswith('.npy')]
                logger.info(f"Found {len(files)} sequences for {category}")
                
                for file in files:
                    try:
                        sequence = np.load(os.path.join(category_dir, file))
                        if sequence.shape[0] != self.sequence_length:
                            sequence = self._pad_or_truncate_sequence(sequence)
                        X.append(sequence)
                        category_vector = np.zeros(len(self.categories))
                        category_vector[idx] = 1
                        y.append(category_vector)
                    except Exception as e:
                        logger.error(f"Error loading {file}: {str(e)}")
        
        return np.array(X), np.array(y)
    
    def _pad_or_truncate_sequence(self, sequence):
        if len(sequence) > self.sequence_length:
            return sequence[:self.sequence_length]
        elif len(sequence) < self.sequence_length:
            padding = np.zeros((self.sequence_length - len(sequence), sequence.shape[1]))
            return np.vstack([sequence, padding])
        return sequence
    
    def train_model(self, epochs=50, batch_size=32, validation_split=0.2):
        X, y = self.load_training_data()
        logger.info(f"Training with {len(X)} sequences")
        
        history = self.model.fit(
            X, y,
            epochs=epochs,
            batch_size=batch_size,
            validation_split=validation_split,
            verbose=1
        )
        
        return history
    
    def save_model(self, filepath='pose_model.keras'):
        self.model.save(filepath)
        logger.info(f"Model saved to {filepath}")