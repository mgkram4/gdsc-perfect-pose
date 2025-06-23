#!/usr/bin/env python3

import json
import os
from pathlib import Path

import requests


def test_pose_endpoint(category, pose_name, image_path):
    """Test a specific pose analysis endpoint"""
    
    if not os.path.exists(image_path):
        print(f"❌ Test image not found: {image_path}")
        return False
    
    url = f'http://127.0.0.1:5000/analyze_pose_{category}'
    
    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            data = {'pose_name': pose_name}
            
            print(f"🔄 Testing {category} endpoint with {pose_name}...")
            response = requests.post(url, files=files, data=data, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Success! Response:")
                print(f"   Category: {result.get('category')}")
                print(f"   Pose: {result.get('pose')}")
                print(f"   Similarity Score: {result.get('similarity_score', 0):.1%}")
                print(f"   Geometric Score: {result.get('geometric_score', 0):.1%}")
                print(f"   Model Score: {result.get('model_score')}")
                print(f"   Suggestions: {len(result.get('suggestions', []))} suggestions")
                return True
            else:
                print(f"❌ Failed with status {response.status_code}: {response.text}")
                return False
                
    except requests.exceptions.ConnectionError:
        print(f"❌ Connection failed. Is the Flask server running on port 5000?")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def find_test_images():
    """Find available test images in the dataset"""
    test_paths = [
        "datasets/downloaded/yoga",
        "datasets/massive_collection/bodyweight",
        "datasets/massive_collection/lifting",
        "datasets/massive_collection/functional"
    ]
    
    available_images = {}
    
    for path in test_paths:
        if os.path.exists(path):
            for item in os.listdir(path):
                item_path = os.path.join(path, item)
                if os.path.isdir(item_path):
                    # Look for images in subdirectories
                    for file in os.listdir(item_path):
                        if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                            category = path.split('/')[-1]
                            if category == 'downloaded':
                                category = path.split('/')[-2]
                            if category not in available_images:
                                available_images[category] = []
                            available_images[category].append({
                                'pose': item,
                                'path': os.path.join(item_path, file)
                            })
                            break  # Just need one image per pose
    
    return available_images

def main():
    print("🚀 Testing Perfect Pose API Endpoints")
    print("=" * 50)
    
    # Check if server is running
    try:
        response = requests.get('http://127.0.0.1:5000/', timeout=5)
        print(f"✅ Server is running: {response.json().get('message')}")
    except:
        print("❌ Server is not running. Please start with: python backend/main.py")
        return
    
    print("\n🔍 Looking for test images...")
    available_images = find_test_images()
    
    if not available_images:
        print("❌ No test images found. Please ensure datasets are downloaded.")
        return
    
    # Test each category with available images
    success_count = 0
    total_tests = 0
    
    test_mapping = {
        'yoga': 'yoga',
        'bodyweight': 'bodyweight', 
        'lifting': 'lifting',
        'functional': 'functional'
    }
    
    for category, endpoint_category in test_mapping.items():
        if category in available_images:
            print(f"\n📋 Testing {category.upper()} category:")
            print("-" * 30)
            
            # Test first available pose in this category
            pose_data = available_images[category][0]
            pose_name = pose_data['pose']
            image_path = pose_data['path']
            
            success = test_pose_endpoint(endpoint_category, pose_name, image_path)
            if success:
                success_count += 1
            total_tests += 1
            
            # Test with a simplified pose name (some poses might need mapping)
            if not success and len(available_images[category]) > 1:
                pose_data = available_images[category][1]
                simplified_pose = pose_data['pose'].split()[0]  # Take first word
                success = test_pose_endpoint(endpoint_category, simplified_pose, pose_data['path'])
                if success:
                    success_count += 1
        else:
            print(f"⚠️  No test images found for {category}")
    
    print(f"\n📊 Test Results: {success_count}/{total_tests} endpoints working")
    
    if success_count == total_tests:
        print("🎉 All endpoints are working correctly!")
        print("\n💡 Frontend Integration Notes:")
        print("   - Endpoints expect 'file' and 'pose_name' parameters")
        print("   - Response includes 'similarity_score' for frontend compatibility")
        print("   - Additional scores available: 'geometric_score', 'model_score'")
        print("   - 'suggestions' array provides improvement tips")
    else:
        print("⚠️  Some endpoints need attention. Check server logs for details.")

if __name__ == "__main__":
    main() 