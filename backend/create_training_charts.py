#!/usr/bin/env python3
"""
Perfect Pose - Training Progress Charts
Creates comprehensive visualizations of training progress over time
"""

import os
from datetime import datetime

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def create_training_progress_charts():
    """Create comprehensive training progress visualizations"""
    print("\n" + "="*60)
    print("📊 PERFECT POSE - TRAINING PROGRESS CHARTS")
    print("="*60)
    
    # Load accuracy tracking data
    csv_path = "research_results/accuracy_tracking.csv"
    if not os.path.exists(csv_path):
        print("❌ No tracking data found!")
        return
    
    # Read CSV data
    try:
        df = pd.read_csv(csv_path)  # Use header row
        print(f"📊 Loaded {len(df)} training sessions")
        print(f"📊 Columns: {list(df.columns)}")
    except Exception as e:
        print(f"❌ Error loading data: {e}")
        return
    
    # Convert timestamp and sort
    df['timestamp'] = pd.to_datetime(df['timestamp'], format='mixed')
    df = df.sort_values('timestamp')
    
    # Rename columns to match expected names
    column_mapping = {
        'total_samples': 'train_samples',  # Fix if needed
    }
    df = df.rename(columns=column_mapping)
    
    # Create figure with subplots
    fig = plt.figure(figsize=(16, 12))
    
    # 1. Accuracy over time
    plt.subplot(2, 3, 1)
    plt.plot(range(len(df)), df['accuracy'] * 100, 'bo-', linewidth=2, markersize=8)
    plt.title('🎯 Model Accuracy Over Time', fontsize=14, fontweight='bold')
    plt.xlabel('Training Session')
    plt.ylabel('Accuracy (%)')
    plt.grid(True, alpha=0.3)
    plt.ylim(0, 105)
    
    # Add annotations for key points
    for i, (idx, row) in enumerate(df.iterrows()):
        if row['accuracy'] >= 0.95:  # High accuracy points
            plt.annotate(f"{row['accuracy']:.1%}", 
                        (i, row['accuracy'] * 100), 
                        xytext=(5, 5), textcoords='offset points',
                        fontsize=9, ha='left')
    
    # 2. Model size efficiency
    plt.subplot(2, 3, 2)
    sizes = df['total_params'] / 1000  # Convert to thousands
    accuracies = df['accuracy'] * 100
    scatter = plt.scatter(sizes, accuracies, c=range(len(df)), 
                         cmap='viridis', s=100, alpha=0.7)
    plt.colorbar(scatter, label='Training Session')
    plt.title('⚡ Model Efficiency\n(Accuracy vs Parameters)', fontsize=14, fontweight='bold')
    plt.xlabel('Parameters (thousands)')
    plt.ylabel('Accuracy (%)')
    plt.grid(True, alpha=0.3)
    
    # 3. F1 Scores by category
    plt.subplot(2, 3, 3)
    categories = ['yoga_f1', 'bodyweight_f1', 'functional_f1', 'lifting_f1']
    category_names = ['Yoga', 'Bodyweight', 'Functional', 'Lifting']
    
    # Get latest F1 scores
    latest_scores = [df[cat].iloc[-1] for cat in categories]
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']
    
    bars = plt.bar(category_names, latest_scores, color=colors, alpha=0.8)
    plt.title('📊 Latest F1 Scores by Category', fontsize=14, fontweight='bold')
    plt.ylabel('F1 Score')
    plt.ylim(0, 1.1)
    plt.grid(True, axis='y', alpha=0.3)
    
    # Add value labels on bars
    for bar, score in zip(bars, latest_scores):
        plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
                f'{score:.3f}', ha='center', va='bottom', fontweight='bold')
    
    # 4. Training data size over time
    plt.subplot(2, 3, 4)
    # Use correct column names from CSV
    train_col = 'train_samples' if 'train_samples' in df.columns else 'total_samples'
    total_samples = df[train_col] + df['test_samples']
    plt.bar(range(len(df)), total_samples, color='lightblue', alpha=0.7)
    plt.title('📈 Dataset Size Growth', fontsize=14, fontweight='bold')
    plt.xlabel('Training Session')
    plt.ylabel('Total Samples')
    plt.grid(True, axis='y', alpha=0.3)
    
    # 5. Parameter reduction over time
    plt.subplot(2, 3, 5)
    param_reduction = (df['total_params'].iloc[0] - df['total_params']) / df['total_params'].iloc[0] * 100
    plt.plot(range(len(df)), param_reduction, 'ro-', linewidth=2, markersize=6)
    plt.title('🏗️ Model Size Reduction', fontsize=14, fontweight='bold')
    plt.xlabel('Training Session')
    plt.ylabel('Parameter Reduction (%)')
    plt.grid(True, alpha=0.3)
    plt.axhline(y=0, color='black', linestyle='--', alpha=0.5)
    
    # 6. Training summary timeline
    plt.subplot(2, 3, 6)
    # Create a timeline view
    session_types = []
    for note in df['notes']:
        if 'data_augmentation' in str(note).lower():
            session_types.append('Data Aug')
        elif 'architecture' in str(note).lower():
            session_types.append('Architecture')
        elif 'retrain' in str(note).lower():
            session_types.append('Retrain')
        else:
            session_types.append('Baseline')
    
    type_colors = {'Data Aug': 'red', 'Architecture': 'blue', 'Retrain': 'green', 'Baseline': 'gray'}
    colors = [type_colors.get(t, 'gray') for t in session_types]
    
    plt.scatter(range(len(df)), df['accuracy'] * 100, c=colors, s=100, alpha=0.7)
    plt.title('🚀 Training Strategy Timeline', fontsize=14, fontweight='bold')
    plt.xlabel('Training Session')
    plt.ylabel('Accuracy (%)')
    plt.grid(True, alpha=0.3)
    
    # Add legend
    unique_types = list(set(session_types))
    legend_colors = [type_colors.get(t, 'gray') for t in unique_types]
    plt.scatter([], [], c=legend_colors[0], label=unique_types[0] if unique_types else 'Unknown')
    for i, t in enumerate(unique_types[1:], 1):
        if i < len(legend_colors):
            plt.scatter([], [], c=legend_colors[i], label=t)
    plt.legend()
    
    plt.tight_layout()
    
    # Save the plot
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    plot_path = f"research_results/training_progress_charts_{timestamp}.png"
    plt.savefig(plot_path, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"📊 Training progress charts saved: {plot_path}")
    
    # Print summary statistics
    print(f"\n🎯 TRAINING SUMMARY:")
    print(f"   📈 Sessions: {len(df)}")
    print(f"   🚀 Best Accuracy: {df['accuracy'].max():.1%}")
    print(f"   📊 Latest Accuracy: {df['accuracy'].iloc[-1]:.1%}")
    print(f"   🏗️ Parameter Reduction: {param_reduction.iloc[-1]:.1f}%")
    print(f"   📁 Largest Dataset: {total_samples.max()} samples")
    
    plt.show()
    return plot_path

if __name__ == "__main__":
    create_training_progress_charts() 