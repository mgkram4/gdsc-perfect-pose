import 'package:flutter/material.dart';

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String typeOfChallenge;
  final double progress; // Added for the progress bar
  final bool done;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.typeOfChallenge,
    this.progress = 0.0, // Default progress is 0
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Positioned Checkmark in the top left corner
            Positioned(
              top: 0,
              left: 0,
              child: Icon(
                Icons.check_circle_outline,
                color: done ? Colors.green : Colors.black,
                size: getDynamicFontSize(context, 24),
              ),
            ),
            // Centered Column for the rest of the content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Type of challenge in the center
                Text(
                  typeOfChallenge,
                  style: TextStyle(
                    color: Colors.green, // Change to blue if needed
                    fontWeight: FontWeight.bold,
                    fontSize: getDynamicFontSize(context, 20),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // Title of the challenge (Bold) centered
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 30),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                // Description of the challenge centered
                Text(
                  description,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12, // Adjust the height of the progress bar
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
