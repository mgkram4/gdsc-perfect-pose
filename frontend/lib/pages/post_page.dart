import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String? _selectedExerciseType;
  String? _selectedPose;

  final List<String> _exerciseTypes = ['Weight Lifting', 'Yoga', 'Running', 'Cardio'];

  // Map exercise types to their corresponding poses
  final Map<String, List<String>> _exercisePoses = {
    'Weight Lifting': ['Deadlift'],
    'Yoga': ['Downward Dog'],
    'Cardio': ['Runner\'s Lunge'],
    'Running': ['Touch Toes'],
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
                SizedBox(height: screenHeight * 0.01), // Spacing after the top bar

                // Exercise Type Selection Dropdown
                _buildDropdown(
                  label: 'Exercise Type',
                  value: _selectedExerciseType,
                  items: _exerciseTypes,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedExerciseType = newValue;
                      _selectedPose = null; // Reset selected pose
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
                      : null, // Disable if no poses available
                ),
                SizedBox(height: screenHeight * 0.02),

                // Form Rating Section (Placeholder)
                const Text('How was your Form?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.01),
                // Responsive placeholder box
                Container(
                  height: screenHeight * 0.05, // Adjust the height as needed
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // You can add a placeholder text or image here if needed
                ),
                SizedBox(height: screenHeight * 0.02),

                // Upload Video/Photo Section
                const Text('Upload Video/Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    child: const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
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
                    minimumSize: Size(double.infinity, screenHeight * 0.07), // Full-width button
                  ),
                  child: const Text('Add Exercise', style: TextStyle(color: Colors.white, fontSize: 18)),
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
          alignedDropdown: true, // Align the dropdown menu with the field
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.white, // Set the dropdown menu color to white
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true, // Make the dropdown field fill the available width
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners when enabled
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners when focused
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
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


  // Show modal bottom sheet for uploading media
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
                  // Handle take photo/video action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload from Gallery'),
                onTap: () {
                  // Handle upload from gallery action
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
