import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: 'User Profile',
        onSettingsTap: () => showSettingsModal(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Column(
              children: [
                // Profile Settings Container
                Container(
                  height: screenHeight * 0.14,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Username Text
                          const Text(
                            'John Smith',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Logout Button
                          GestureDetector(
                            onTap: () {
                              // Add logout functionality here
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red[300],
                                fontSize: 25,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.red[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Change Profile Picture Button
                          GestureDetector(
                            onTap: () {
                              // Add change profile picture functionality here
                            },
                            child: const Text(
                              'Change PFP',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                decorationColor: Colors.grey,
                              ),
                            ),
                          ),

                          // Reset Password Button
                          GestureDetector(
                            onTap: () {
                              // Add reset password functionality here
                            },
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                decorationColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Recent Activities Header
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Create Recent Activities Containers
                _buildHistoryContainer(context, "Downward Dog", "9/13/2024", 67),
                _buildHistoryContainer(context, "Plank", "9/14/2024", 78),

                // Delete Account Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add delete account functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[300],
                      elevation: 5,
                    ),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red[300],
                        color: Colors.red[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const bottom_bar(),
    );
  }
}

// Helper method to create exercise containers with dynamic font sizing
Widget _buildHistoryContainer(
  BuildContext context, String exerciseName, String date, int score) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double fontSizeExercise = screenWidth * 0.0675;
  double fontSizeDate = screenWidth * 0.05;
  double fontSizeScore = screenWidth * 0.0515;
  double fontSizeViewDetails = screenWidth * 0.045;

  return Container(
    height: screenHeight * 0.18,
    margin: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.01,
      vertical: screenHeight * 0.01,
    ),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 5,
            color: const Color.fromARGB(255, 98, 97, 97).withOpacity(0.3),
          ),
        ]),
    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exerciseName,
              style: TextStyle(
                  fontSize: fontSizeExercise, fontWeight: FontWeight.bold),
            ),
            // The date
            Text(date,
                style: TextStyle(
                    fontSize: fontSizeDate,
                    color: const Color.fromARGB(255, 141, 141, 141))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Form score: $score/100",
              style: TextStyle(fontSize: fontSizeScore),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "View Details",
              style: TextStyle(
                  fontSize: fontSizeViewDetails,
                  color: const Color.fromARGB(255, 3, 123, 244)), //20
            ),
          ],
        ),
      ],
    ),
  );
}