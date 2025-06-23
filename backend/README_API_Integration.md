# Perfect Pose API Integration Guide

## 🎯 Overview

This guide explains how to set up and use the Perfect Pose API with your Flutter frontend. The API provides pose analysis endpoints that integrate your improved ML model with real-time feedback.

## 🚀 Quick Start

### 1. Start the API Server
```bash
cd backend
python start_server.py
```

### 2. Test the Endpoints
```bash
python test_endpoints.py
```

### 3. Use from Flutter Frontend
Your Flutter app (`frontend/lib/pages/post_page.dart`) is already configured to use these endpoints!

## 📡 API Endpoints

### Base URL
```
http://127.0.0.1:5000
```

### Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/analyze_pose_yoga` | POST | Analyze yoga poses |
| `/analyze_pose_bodyweight` | POST | Analyze bodyweight exercises |
| `/analyze_pose_lifting` | POST | Analyze weightlifting exercises |
| `/analyze_pose_functional` | POST | Analyze functional movements |

### Request Format

**Content-Type**: `multipart/form-data`

**Parameters**:
- `file`: Image file (JPG, PNG) - required
- `pose_name`: Name of the pose to analyze - required

**Example using curl**:
```bash
curl -X POST \
  http://127.0.0.1:5000/analyze_pose_yoga \
  -F "file=@/path/to/your/image.jpg" \
  -F "pose_name=Downward Dog"
```

### Response Format

**Success Response (200)**:
```json
{
  "category": "yoga",
  "pose": "Downward Dog",
  "similarity_score": 0.85,
  "geometric_score": 0.75,
  "model_score": 0.90,
  "angle_differences": {
    "left_elbow": -5.2,
    "right_knee": 8.1,
    "hip_angle": -3.4
  },
  "suggestions": [
    "decrease left elbow angle by about 5.2 degrees",
    "increase right knee angle by about 8.1 degrees"
  ]
}
```

**Error Response (400/500)**:
```json
{
  "error": "Error message description"
}
```

## 🧠 Model Integration

### How It Works

1. **Dual Analysis**: The API uses both geometric pose analysis and your improved ML model
2. **Smart Scoring**: Final score combines:
   - 30% geometric similarity (traditional pose matching)
   - 70% ML model prediction (your improved model)
3. **Angle Analysis**: Provides specific joint angle differences
4. **Smart Suggestions**: Generates actionable feedback based on detected issues

### Model Loading

The analyzer automatically tries to load your model from these locations:
- `models/saved/pose_model.keras`
- `../models/models/saved/advanced_80_percent_model_20250622_160937.keras`
- `../../models/models/saved/advanced_80_percent_model_20250622_160937.keras`

If no model is found, it falls back to geometric analysis only.

## 📱 Frontend Integration

### Your Flutter App is Ready!

Your `post_page.dart` already includes:

```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('http://127.0.0.1:5000/analyze_pose_${_selectedExerciseType!.toLowerCase()}'),
);
request.files.add(multipartFile);
request.fields['pose_name'] = _selectedPose!;
```

### Response Handling

The Flutter app expects and uses:
- `similarity_score`: Main score displayed to user (0.0 to 1.0)
- `suggestions`: Array of improvement tips
- `category` and `pose`: Confirmation of analyzed exercise

### Score Display

In your Flutter UI, the score is displayed as:
```dart
Text('${(result.similarityScore * 100).toStringAsFixed(1)}%')
```

## 🔧 Development & Testing

### Local Testing

1. **Start Server**:
   ```bash
   cd backend
   python main.py
   ```

2. **Test Endpoints**:
   ```bash
   python test_endpoints.py
   ```

3. **Run Flutter App**:
   ```bash
   cd frontend
   flutter run
   ```

### Production Deployment

For production, you'll need to:

1. **Update Frontend URLs**: Change `127.0.0.1:5000` to your production API URL
2. **Deploy API**: Use platforms like:
   - Heroku
   - Google Cloud Run
   - AWS Lambda
   - Digital Ocean

3. **Environment Variables**: Set proper CORS origins for your Flutter app

## 🐛 Troubleshooting

### Common Issues

**"Connection refused"**:
- Ensure the Flask server is running on port 5000
- Check if another process is using port 5000

**"No pose database found"**:
- Ensure all pose database files exist:
  - `models/yoga.py`
  - `models/bodyweight.py`
  - `models/lifting.py`
  - `models/functional.py`

**"Model not found"**:
- The API will work with geometric analysis only
- To use ML predictions, ensure your trained model is in the correct location

**Low accuracy scores**:
- This is expected with diverse datasets (better than fake 100% accuracy!)
- The 80% accuracy model should give realistic scores

### Debug Logging

The API includes comprehensive logging. Check the console output for:
- Model loading status
- Request processing details
- Error messages with stack traces

## 📊 Expected Performance

### Realistic Accuracy Expectations

- **Good poses**: 70-90% similarity score
- **Average poses**: 50-70% similarity score  
- **Poor poses**: 20-50% similarity score

This is much more realistic than the previous "100% accuracy" which was overfitting!

### Response Times

- **With ML model**: ~1-3 seconds per analysis
- **Geometric only**: ~0.5-1 second per analysis

## 🎉 Success!

Your API integration is complete! The Flask backend now:

✅ Loads your improved 80% accuracy model  
✅ Provides realistic pose analysis scores  
✅ Integrates seamlessly with your Flutter frontend  
✅ Offers actionable improvement suggestions  
✅ Handles errors gracefully  
✅ Includes comprehensive logging  

Your users will now get honest, helpful feedback instead of misleading perfect scores! 