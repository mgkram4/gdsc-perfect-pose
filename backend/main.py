import logging
import os
import tempfile

from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
from models.analyzer import PoseAnalyzer
from models.bodyweight import load_bodyweight_poses
from models.cnn_lstm import PoseModelTrainer
from models.functional import load_functional_poses
from models.lifting import load_lifting_poses
from models.model_trainer import PoseDataPreprocessor
from models.yoga import load_yoga_poses

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

pose_analyzer = PoseAnalyzer()

# Load pose databases
try:
    load_yoga_poses(pose_analyzer)
    load_bodyweight_poses(pose_analyzer)
    load_functional_poses(pose_analyzer)
    load_lifting_poses(pose_analyzer)
    logger.info("Successfully loaded all pose databases")
except Exception as e:
    logger.error(f"Error loading pose databases: {str(e)}")
    raise

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the Perfect Pose API"})

def analyze_pose(category):
    logger.info(f"Received {category} pose analysis request")
    
    if 'file' not in request.files:
        logger.warning("No file part in request")
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    pose_name = request.form.get('pose_name')
    
    if file.filename == '':
        logger.warning("Empty filename submitted")
        return jsonify({"error": "No selected file"}), 400
    
    if not pose_name:
        logger.warning("No pose name provided")
        return jsonify({"error": "Pose name is required"}), 400
    
    if file and pose_name:
        # Create temp directory
        temp_dir = tempfile.mkdtemp()
        filename = os.path.join(temp_dir, f"temp_{file.filename}")
        
        try:
            file.save(filename)
            logger.info(f"Saved temporary file: {filename}")
            
            result = pose_analyzer.analyze_user_pose(filename, category, pose_name)
            logger.info(f"Successfully analyzed {category} pose: {pose_name}")
            
            return jsonify(result), 200
            
        except Exception as e:
            logger.error(f"Error during pose analysis: {str(e)}")
            return jsonify({"error": str(e)}), 500
            
        finally:
            if os.path.exists(filename):
                os.remove(filename)
            if os.path.exists(temp_dir):
                os.rmdir(temp_dir)
            logger.info("Cleaned up temporary files")
    
    return jsonify({"error": "Invalid request"}), 400

@app.route('/analyze_pose_yoga', methods=['POST'])
def analyze_yoga():
    return analyze_pose('yoga')

@app.route('/analyze_pose_bodyweight', methods=['POST'])
def analyze_bodyweight():
    return analyze_pose('bodyweight')

@app.route('/analyze_pose_functional', methods=['POST'])
def analyze_functional():
    return analyze_pose('functional')

@app.route('/analyze_pose_lifting', methods=['POST'])
def analyze_lifting():
    return analyze_pose('lifting')

@app.route('/train_model', methods=['POST'])
def train_model_endpoint():
    try:
        logger.info("Starting model training process")
        history = process_and_train()
        logger.info("Model training completed successfully")
        return jsonify({
            'message': 'Model trained successfully',
            'history': str(history.history) if hasattr(history, 'history') else str(history)
        })
    except Exception as e:
        logger.error(f"Error training model: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found_error(error):
    logger.warning(f"404 error: {request.url}")
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"500 error: {str(error)}")
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(debug=True)