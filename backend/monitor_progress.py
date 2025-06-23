#!/usr/bin/env python3
"""
Monitor Processing Progress
==========================
Real-time monitoring of dataset processing progress
"""

import os
import time
from datetime import datetime
from pathlib import Path


def count_processed_samples():
    """Count processed samples in each category"""
    processed_dir = Path('models/data/process')
    
    categories = ['yoga', 'bodyweight', 'functional', 'lifting']
    counts = {}
    
    for category in categories:
        category_dir = processed_dir / category
        if category_dir.exists():
            counts[category] = len(list(category_dir.glob('*.npy')))
        else:
            counts[category] = 0
    
    return counts

def check_processing_status():
    """Check if processing scripts are still running"""
    try:
        # Check for yoga processing
        yoga_running = os.system("ps aux | grep 'process_existing_yoga' | grep -v grep > /dev/null") == 0
        
        # Check for massive data processing
        massive_running = os.system("ps aux | grep 'process_all_new_data' | grep -v grep > /dev/null") == 0
        
        return yoga_running, massive_running
    except:
        return False, False

def display_progress():
    """Display current progress"""
    counts = count_processed_samples()
    yoga_running, massive_running = check_processing_status()
    
    total_samples = sum(counts.values())
    
    print(f"\n🚀 DATASET PROCESSING PROGRESS")
    print(f"{'='*50}")
    print(f"⏰ Time: {datetime.now().strftime('%H:%M:%S')}")
    print(f"")
    
    print(f"📊 CURRENT SAMPLE COUNTS:")
    for category, count in counts.items():
        status = ""
        if category == 'yoga' and yoga_running:
            status = " (🔄 processing...)"
        elif category in ['bodyweight', 'functional', 'lifting'] and massive_running:
            status = " (🔄 processing...)"
        
        print(f"  {category.upper():>12}: {count:,} samples{status}")
    
    print(f"")
    print(f"🎯 TOTAL SAMPLES: {total_samples:,}")
    
    # Calculate readiness
    ready_categories = sum(1 for count in counts.values() if count >= 500)
    sufficient_data = total_samples >= 4000
    ready_for_training = ready_categories >= 3 and sufficient_data
    
    print(f"")
    print(f"✅ READINESS CHECK:")
    print(f"  📊 Total samples (4000+ target): {total_samples:,} {'✅' if sufficient_data else '❌'}")
    print(f"  🎯 Strong categories (3+ with 500+): {ready_categories}/4 {'✅' if ready_categories >= 3 else '❌'}")
    print(f"  🚀 Ready for 80% training: {'YES' if ready_for_training else 'NO'}")
    
    print(f"")
    print(f"⚙️ PROCESSING STATUS:")
    print(f"  🧘 Yoga processing: {'RUNNING' if yoga_running else 'COMPLETE'}")
    print(f"  🏋️ Massive data processing: {'RUNNING' if massive_running else 'COMPLETE'}")
    
    if ready_for_training:
        print(f"\n🎉 DATASET IS READY FOR 80% ACCURACY TRAINING!")
        print(f"   Run: python backend/train_advanced_80_percent.py")
    elif not yoga_running and not massive_running:
        print(f"\n⏳ Processing complete - checking final status...")
    else:
        print(f"\n⏳ Processing in progress... Check again in a few minutes")
    
    return ready_for_training

def main():
    """Main monitoring function"""
    print("🔍 MONITORING DATASET PROCESSING")
    print("Press Ctrl+C to exit")
    
    try:
        while True:
            ready = display_progress()
            
            if ready:
                print(f"\n🚀 READY TO START TRAINING!")
                break
            
            # Check if both processes are done
            yoga_running, massive_running = check_processing_status()
            if not yoga_running and not massive_running:
                print(f"\n✅ All processing complete!")
                break
            
            time.sleep(30)  # Check every 30 seconds
            
    except KeyboardInterrupt:
        print(f"\n👋 Monitoring stopped by user")

if __name__ == "__main__":
    main() 