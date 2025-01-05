import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';

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

class _PostPageState extends State<PostPage> {
  String? _selectedExerciseType;
  String? _selectedPose;
  final ImagePicker _picker = ImagePicker();

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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: 'Exercise',
        onSettingsTap: () => showSettingsModal(context),
      ),
      bottomNavigationBar: const bottom_bar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.01),

                // Exercise Type Selection Dropdown
                _buildDropdown(
                  label: 'Exercise Type',
                  value: _selectedExerciseType,
                  items: _exerciseTypes,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedExerciseType = newValue;
                      _selectedPose = null;
                      _poses = _exercisePoses[newValue!] ?? [];
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.01),

                // Pose Selection Dropdown
                _buildDropdown(
                  label: 'Pose',
                  value: _selectedPose,
                  items: _poses,
                  onChanged: _poses.isNotEmpty
                      ? (String? newValue) {
                          setState(() {
                            _selectedPose = newValue;
                          });
                        }
                      : null,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Form Rating Section
                const Text('How was your Form?',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  height: screenHeight * 0.05,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Upload Video/Photo Section
                const Text('Upload Video/Photo',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.01),
                GestureDetector(
                  onTap: () {
                    _showUploadModalBottomSheet(context);
                  },
                  child: Container(
                    height: screenHeight * 0.20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 60, color: Colors.grey),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Add Exercise Button
                ElevatedButton(
                  onPressed: () {
                    // Add Exercise logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, screenHeight * 0.07),
                  ),
                  child: const Text('Add Exercise',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 5),
        ButtonTheme(
          alignedDropdown: true,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.white,
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              ),
              hint: Text('Select $label'),
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showUploadModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo/Video'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    if (_selectedExerciseType == null || _selectedPose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select exercise type and pose first')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      await _analyzeImage(File(image.path));
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://127.0.0.1:5000/analyze_pose_${_selectedExerciseType!.toLowerCase().replaceAll(' ', '_')}'),
      );

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
      request.fields['pose_name'] = _selectedPose!;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context); // Hide loading dialog

      if (response.statusCode == 200) {
        var result = PoseAnalysisResult.fromJson(json.decode(response.body));
        _showAnalysisResults(result, imageFile);
      } else {
        throw Exception('Failed to analyze pose: ${response.body}');
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing pose: $e')),
      );
    }
  }

  void _showAnalysisResults(PoseAnalysisResult result, File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analysis Results',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${(result.similarityScore * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Suggestions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: result.suggestions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index == result.suggestions.length - 1
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(result.suggestions[index]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
