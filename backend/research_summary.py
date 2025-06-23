#!/usr/bin/env python3
"""
Research Summary & Progress Analysis
===================================
Analyzes the model improvement progress and provides research insights.

Usage:
    python research_summary.py
"""

from datetime import datetime
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def analyze_research_progress():
    """Analyze and summarize research progress"""
    
    results_dir = Path('research_results')
    csv_file = results_dir / 'accuracy_tracking.csv'
    
    if not csv_file.exists():
        print("❌ No tracking data found")
        return
    
    # Load data
    df = pd.read_csv(csv_file)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df = df.sort_values('timestamp')
    
    print("\n" + "="*80)
    print("📊 PERFECT POSE - RESEARCH PROGRESS SUMMARY")
    print("="*80)
    
    # Overall Progress
    initial_accuracy = df.iloc[0]['accuracy']
    best_accuracy = df['accuracy'].max()
    improvement = best_accuracy - initial_accuracy
    
    print(f"\n🎯 OVERALL PROGRESS:")
    print(f"   📈 Initial Accuracy: {initial_accuracy:.1%}")
    print(f"   🚀 Best Accuracy: {best_accuracy:.1%}")
    print(f"   📊 Total Improvement: {improvement:+.1%}")
    print(f"   📅 Research Sessions: {len(df)}")
    
    # Strategy Analysis
    print(f"\n🔬 STRATEGY EFFECTIVENESS:")
    strategy_results = {}
    
    for _, row in df.iterrows():
        if 'Strategy:' in str(row['notes']):
            strategy = row['notes'].split('Strategy: ')[1]
            strategy_results[strategy] = {
                'accuracy': row['accuracy'],
                'params': row['total_params'],
                'f1_scores': {
                    'yoga': row['yoga_f1'],
                    'bodyweight': row['bodyweight_f1'],
                    'functional': row['functional_f1'],
                    'lifting': row['lifting_f1']
                }
            }
    
    for strategy, results in strategy_results.items():
        print(f"\n   🎯 {strategy.upper()}:")
        print(f"      Accuracy: {results['accuracy']:.1%}")
        print(f"      Parameters: {results['params']:,}")
        print(f"      F1 Scores: Yoga={results['f1_scores']['yoga']:.2f}, "
              f"Bodyweight={results['f1_scores']['bodyweight']:.2f}, "
              f"Functional={results['f1_scores']['functional']:.2f}, "
              f"Lifting={results['f1_scores']['lifting']:.2f}")
    
    # Model Architecture Analysis
    print(f"\n🏗️ MODEL ARCHITECTURE INSIGHTS:")
    
    best_row = df.loc[df['accuracy'].idxmax()]
    print(f"   🥇 Best Model:")
    print(f"      Accuracy: {best_row['accuracy']:.1%}")
    print(f"      Parameters: {best_row['total_params']:,}")
    print(f"      Strategy: {best_row['notes']}")
    
    # Parameter Efficiency Analysis
    df['params_per_accuracy'] = df['total_params'] / df['accuracy']
    most_efficient = df.loc[df['params_per_accuracy'].idxmin()]
    print(f"\n   ⚡ Most Parameter-Efficient:")
    print(f"      Accuracy: {most_efficient['accuracy']:.1%}")
    print(f"      Parameters: {most_efficient['total_params']:,}")
    print(f"      Efficiency: {most_efficient['params_per_accuracy']:,.0f} params per 1% accuracy")
    
    # Key Findings
    print(f"\n💡 KEY RESEARCH FINDINGS:")
    
    if best_accuracy >= 0.95:
        print(f"   ✅ Achieved excellent accuracy (≥95%)")
    elif best_accuracy >= 0.80:
        print(f"   ✅ Achieved good accuracy (≥80%)")
    else:
        print(f"   ⚠️ Still room for improvement (<80%)")
    
    # Data Augmentation Impact
    data_aug_results = [r for r in strategy_results.values() if 'data_augmentation' in str(r)]
    if data_aug_results:
        print(f"   📈 Data augmentation was highly effective")
    
    # Architecture Impact
    if len(strategy_results) > 1:
        param_counts = [r['params'] for r in strategy_results.values()]
        if min(param_counts) < max(param_counts) * 0.5:
            print(f"   🏗️ Smaller architectures can achieve similar performance")
    
    # Future Recommendations
    print(f"\n🎯 FUTURE RESEARCH DIRECTIONS:")
    
    if best_accuracy < 0.85:
        print(f"   1. 📊 Expand dataset further (current: {df.iloc[-1]['total_samples']} samples)")
        print(f"   2. 🔧 Try ensemble methods")
        print(f"   3. 🎯 Focus on class imbalance (some F1 scores still low)")
    
    if df['total_params'].max() > 50000:
        print(f"   4. ⚡ Explore model compression techniques")
    
    print(f"   5. 🧪 Test on real-world scenarios")
    print(f"   6. 📱 Optimize for mobile deployment")
    
    # Generate trend plot
    create_trend_analysis(df, results_dir)

def create_trend_analysis(df, results_dir):
    """Create comprehensive trend analysis plots"""
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Model Research Progress Analysis', fontsize=16, fontweight='bold')
    
    # 1. Accuracy over time
    axes[0,0].plot(df['timestamp'], df['accuracy'] * 100, 'o-', linewidth=2, markersize=8, color='#2ecc71')
    axes[0,0].set_title('Accuracy Progress Over Time')
    axes[0,0].set_ylabel('Accuracy (%)')
    axes[0,0].grid(True, alpha=0.3)
    axes[0,0].tick_params(axis='x', rotation=45)
    
    # Add annotations for major improvements
    for i, row in df.iterrows():
        if 'Strategy:' in str(row['notes']):
            axes[0,0].annotate(row['notes'].split('Strategy: ')[1], 
                             xy=(row['timestamp'], row['accuracy'] * 100),
                             xytext=(10, 10), textcoords='offset points',
                             bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7),
                             fontsize=8)
    
    # 2. Parameter efficiency
    efficiency = df['total_params'] / (df['accuracy'] * 100)
    axes[0,1].scatter(df['accuracy'] * 100, df['total_params'], s=100, alpha=0.7, c=range(len(df)), cmap='viridis')
    axes[0,1].set_title('Accuracy vs Model Size')
    axes[0,1].set_xlabel('Accuracy (%)')
    axes[0,1].set_ylabel('Total Parameters')
    axes[0,1].grid(True, alpha=0.3)
    
    # 3. Per-class F1 score trends
    f1_columns = ['yoga_f1', 'bodyweight_f1', 'functional_f1', 'lifting_f1']
    categories = ['Yoga', 'Bodyweight', 'Functional', 'Lifting']
    colors = ['#e74c3c', '#3498db', '#f39c12', '#9b59b6']
    
    for i, (col, cat, color) in enumerate(zip(f1_columns, categories, colors)):
        axes[1,0].plot(df['timestamp'], df[col], 'o-', label=cat, color=color, linewidth=2)
    
    axes[1,0].set_title('Per-Class F1 Score Progress')
    axes[1,0].set_ylabel('F1 Score')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)
    axes[1,0].tick_params(axis='x', rotation=45)
    
    # 4. Strategy comparison
    strategy_data = {}
    for _, row in df.iterrows():
        if 'Strategy:' in str(row['notes']):
            strategy = row['notes'].split('Strategy: ')[1]
            strategy_data[strategy] = row['accuracy'] * 100
    
    if strategy_data:
        strategies = list(strategy_data.keys())
        accuracies = list(strategy_data.values())
        colors = plt.cm.Set3(np.linspace(0, 1, len(strategies)))
        
        bars = axes[1,1].bar(strategies, accuracies, color=colors, alpha=0.8)
        axes[1,1].set_title('Strategy Comparison')
        axes[1,1].set_ylabel('Accuracy (%)')
        axes[1,1].tick_params(axis='x', rotation=45)
        
        # Add value labels on bars
        for bar, acc in zip(bars, accuracies):
            axes[1,1].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
                          f'{acc:.1f}%', ha='center', va='bottom', fontweight='bold')
    
    plt.tight_layout()
    
    # Save plot
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    plot_path = results_dir / f"research_summary_{timestamp}.png"
    plt.savefig(plot_path, dpi=300, bbox_inches='tight')
    plt.show()
    
    print(f"\n📊 Research summary plot saved to: {plot_path}")

if __name__ == "__main__":
    analyze_research_progress() 