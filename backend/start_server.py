#!/usr/bin/env python3

import logging
import os
import subprocess
import sys
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_virtual_environment():
    """Check if we're in a virtual environment"""
    if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        logger.info("✅ Running in virtual environment")
        return True
    else:
        logger.warning("⚠️  Not running in virtual environment")
        return False

def install_dependencies():
    """Install required dependencies"""
    requirements_file = Path(__file__).parent / "requirements.txt"
    
    if requirements_file.exists():
        logger.info("📦 Installing/updating dependencies...")
        try:
            subprocess.run([sys.executable, "-m", "pip", "install", "-r", str(requirements_file)], 
                         check=True, capture_output=True, text=True)
            logger.info("✅ Dependencies installed successfully")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Failed to install dependencies: {e}")
            logger.error(f"Error output: {e.stderr}")
            return False
    else:
        logger.warning("⚠️  requirements.txt not found")
        return True

def check_model_availability():
    """Check if the trained model is available"""
    model_paths = [
        "models/saved/pose_model.keras",
        "../models/models/saved/advanced_80_percent_model_20250622_160937.keras",
        "../../models/models/saved/advanced_80_percent_model_20250622_160937.keras"
    ]
    
    for path in model_paths:
        if os.path.exists(path):
            logger.info(f"✅ Found model at: {path}")
            return True
    
    logger.warning("⚠️  No trained model found. The server will use geometric analysis only.")
    logger.info("💡 To train a model, run: python backend/train_advanced_80_percent.py")
    return False

def check_pose_databases():
    """Check if pose database files exist"""
    required_files = [
        "models/yoga.py",
        "models/bodyweight.py", 
        "models/lifting.py",
        "models/functional.py"
    ]
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    if missing_files:
        logger.error(f"❌ Missing pose database files: {missing_files}")
        return False
    else:
        logger.info("✅ All pose database files found")
        return True

def start_flask_server():
    """Start the Flask server"""
    logger.info("🚀 Starting Perfect Pose API server...")
    
    # Set environment variables
    os.environ['FLASK_APP'] = 'main.py'
    os.environ['FLASK_ENV'] = 'development'
    
    try:
        # Change to backend directory
        os.chdir(Path(__file__).parent)
        
        # Import and run the Flask app
        from main import app
        
        logger.info("✅ Flask app loaded successfully")
        logger.info("🌐 Server will be available at: http://127.0.0.1:5000")
        logger.info("📱 Frontend can now connect to the API endpoints")
        logger.info("\n🔗 Available endpoints:")
        logger.info("   - POST /analyze_pose_yoga")
        logger.info("   - POST /analyze_pose_bodyweight")
        logger.info("   - POST /analyze_pose_lifting")
        logger.info("   - POST /analyze_pose_functional")
        logger.info("\n🛑 Press Ctrl+C to stop the server")
        
        app.run(host='127.0.0.1', port=5000, debug=True)
        
    except ImportError as e:
        logger.error(f"❌ Failed to import Flask app: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Failed to start server: {e}")
        sys.exit(1)

def main():
    print("🎯 Perfect Pose API Server Startup")
    print("=" * 40)
    
    # Check virtual environment
    venv_ok = check_virtual_environment()
    
    # Install dependencies
    deps_ok = install_dependencies()
    if not deps_ok:
        sys.exit(1)
    
    # Check model availability
    model_ok = check_model_availability()
    
    # Check pose databases
    db_ok = check_pose_databases()
    if not db_ok:
        logger.error("❌ Cannot start server without pose database files")
        sys.exit(1)
    
    print("\n" + "=" * 40)
    logger.info("🎉 All checks passed! Starting server...")
    print("=" * 40)
    
    # Start the server
    start_flask_server()

if __name__ == "__main__":
    main() 