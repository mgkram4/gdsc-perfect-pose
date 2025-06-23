import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perfect_pose/services/firestore_service.dart';

class PoseAnalysisResult {
  final String category;
  final String pose;
  final double similarityScore;
  final Map<String, double> angleDifferences;
  final List<String> suggestions;

  PoseAnalysisResult({
    required this.category,
    required this.pose,
    required this.similarityScore,
    required this.angleDifferences,
    required this.suggestions,
  });

  factory PoseAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PoseAnalysisResult(
      category: json['category'],
      pose: json['pose'],
      similarityScore: json['similarity_score'].toDouble(),
      angleDifferences: Map<String, double>.from(json['angle_differences']),
      suggestions: List<String>.from(json['suggestions']),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
  String? _selectedExerciseType;
  String? _selectedPose;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isAnalyzing = false;
  PoseAnalysisResult? _analysisResult;

  // Modern fitness colors
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color coralRed = Color(0xFFFF5C5C);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  final List<String> _exerciseTypes = [
    'Bodyweight',
    'Functional',
    'Lifting',
    'Yoga'
  ];

  final Map<String, List<String>> _exercisePoses = {
    'Bodyweight': ['Burpee', 'Plank', 'Push-up'],
    'Functional': ['Lunge', 'Mountain Climber'],
    'Lifting': ['Bench', 'Deadlift', 'Squat'],
    'Yoga': ['Dog', 'Tree Pose', 'Warrior I'],
  };

  List<String> _poses = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null ||
        _selectedExerciseType == null ||
        _selectedPose == null) {
      _showSnackBar('Please select exercise type, pose, and upload an image');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulate API call for pose analysis
      await Future.delayed(const Duration(seconds: 2));

      // Mock analysis result - in production, this would come from your backend
      final mockResult = PoseAnalysisResult(
        category: _selectedExerciseType!,
        pose: _selectedPose!,
        similarityScore: 75.0 +
            (DateTime.now().millisecond % 25), // Random score between 75-100
        angleDifferences: {
          'left_shoulder': 5.2,
          'right_shoulder': 3.8,
          'left_elbow': 2.1,
          'right_elbow': 1.9,
        },
        suggestions: [
          'Keep your shoulders aligned',
          'Maintain a straighter back',
          'Engage your core muscles',
        ],
      );

      setState(() {
        _analysisResult = mockResult;
        _isAnalyzing = false;
      });

      // Save workout activity to Firebase
      final score = mockResult.similarityScore.round();
      await _firestoreService.saveWorkoutActivity(
        exerciseType: _selectedPose!,
        category: _selectedExerciseType!.toLowerCase(),
        duration: 30, // Mock duration in seconds
        score: score,
        additionalData: {
          'angle_differences': mockResult.angleDifferences,
          'suggestions': mockResult.suggestions,
        },
      );

      _showSnackBar('Workout saved successfully! +$score XP');
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Error analyzing pose: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A1A1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0B), Color(0xFF1A1A1B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Glass App Bar
              _buildGlassAppBar(context),

              // Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            _buildHeaderSection(context),

                            SizedBox(height: screenHeight * 0.025),

                            // Exercise Type Selection
                            _buildDropdownSection(
                              'Exercise Type',
                              _selectedExerciseType,
                              _exerciseTypes,
                              primaryBlue,
                              Icons.fitness_center_rounded,
                              (String? newValue) {
                                setState(() {
                                  _selectedExerciseType = newValue;
                                  _selectedPose = null;
                                  _poses = _exercisePoses[newValue!] ?? [];
                                });
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Pose Selection
                            _buildDropdownSection(
                              'Pose',
                              _selectedPose,
                              _poses,
                              neonGreen,
                              Icons.accessibility_new_rounded,
                              _poses.isNotEmpty
                                  ? (String? newValue) {
                                      setState(() {
                                        _selectedPose = newValue;
                                      });
                                    }
                                  : null,
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Upload Section
                            _buildUploadSection(context),

                            SizedBox(height: screenHeight * 0.03),

                            // Analysis Result
                            if (_analysisResult != null)
                              _buildAnalysisResult(context),

                            SizedBox(height: screenHeight * 0.03),

                            // Add Exercise Button
                            _buildSubmitButton(context),

                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: glassPrimary,
            border: const Border(
              bottom: BorderSide(color: glassBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Pose Analysis',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: coralRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: coralRed,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfect Your Form',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your workout videos for AI-powered form analysis',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [coralRed, const Color(0xFFE54848)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    String label,
    String? value,
    List<String> items,
    Color color,
    IconData icon,
    ValueChanged<String?>? onChanged,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: glassPrimary,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: glassBorder, width: 1),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: value,
                      underline: Container(),
                      dropdownColor: const Color(0xFF1A1A1B),
                      iconEnabledColor: color,
                      icon:
                          Icon(Icons.keyboard_arrow_down_rounded, color: color),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      hint: Text(
                        'Select $label',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Upload Video/Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _showUploadModalBottomSheet(context),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: glassPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: glassBorder, width: 2),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: coralRed,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 40,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to Upload',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose from camera or gallery',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    bool isEnabled = _selectedExerciseType != null &&
        _selectedPose != null &&
        _selectedImage != null &&
        !_isAnalyzing;

    return GestureDetector(
      onTap: isEnabled ? () => _analyzeImage() : null,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [neonGreen, const Color(0xFF32E612)],
                )
              : LinearGradient(
                  colors: [glassBorder, glassBorder],
                ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: neonGreen.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _isAnalyzing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Analyzing...',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  _analysisResult != null ? 'Try Another Pose' : 'Analyze Form',
                  style: TextStyle(
                    color: isEnabled ? Colors.black : textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  void _showUploadModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: glassPrimary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                border: const Border(
                  top: BorderSide(color: glassBorder, width: 1),
                  left: BorderSide(color: glassBorder, width: 1),
                  right: BorderSide(color: glassBorder, width: 1),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Choose Upload Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildUploadOption(
                      context,
                      'Take Photo/Video',
                      Icons.camera_alt_rounded,
                      primaryBlue,
                      () {
                        Navigator.pop(context);
                        _handleImageSelection(ImageSource.camera);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildUploadOption(
                      context,
                      'Upload from Gallery',
                      Icons.photo_library_rounded,
                      neonGreen,
                      () {
                        Navigator.pop(context);
                        _handleImageSelection(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: glassPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    if (_selectedExerciseType == null || _selectedPose == null) {
      _showErrorSnackBar('Please select exercise type and pose first');
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Widget _buildAnalysisResult(BuildContext context) {
    if (_analysisResult == null) return const SizedBox();

    final result = _analysisResult!;
    final scoreColor = result.similarityScore >= 80
        ? neonGreen
        : result.similarityScore >= 60
            ? Colors.orange
            : coralRed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: scoreColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Analysis Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Score Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Form Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${result.similarityScore.round()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Suggestions
              Text(
                'Suggestions for improvement:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...result.suggestions
                  .map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: textSecondary)),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: const TextStyle(color: textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: coralRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
