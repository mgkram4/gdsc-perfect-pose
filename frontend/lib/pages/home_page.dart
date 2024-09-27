import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: 'Dashboard',
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
                // Daily Challenges Card
                Card(
                  elevation: 5,
                  color: Colors.yellow[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Challenges',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getDynamicFontSize(context, 24), 
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), 
                        Text(
                          'Challenge Yourself Daily, Improve Constantly',
                          style: TextStyle(
                            fontSize: getDynamicFontSize(context, 14), 
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to upload page
                            Navigator.pushNamed(context, '/uploadPage');
                          },
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: getDynamicFontSize(context, 16), 
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 5, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), 

                // Two Cards: Unlock the Power and Perfect Your Craft
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 5,
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlock the Power of Perfect Form',
                                style: TextStyle(
                                  fontSize: getDynamicFontSize(context, 13), 
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        elevation: 5,
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04), 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perfect your Craft\nPractice with a Pro',
                                style: TextStyle(
                                  fontSize: getDynamicFontSize(context, 13), 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02), 

                // Jump Back In Section
                Center(
                  child: Text(
                    'Jump Back In',
                    style: TextStyle(
                      fontSize: getDynamicFontSize(context, 22), 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Category Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton('Weight Lifting', screenWidth, context, '/uploadPage'),
                    _buildCategoryButton('Yoga', screenWidth, context, '/uploadPage'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton('Body weight', screenWidth, context, '/uploadPage'),
                    _buildCategoryButton('Functional', screenWidth, context, '/uploadPage'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025), 

                // History and User Stats Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('History', Colors.green, Icons.bookmark, screenWidth, context, '/historyPage'),
                    _buildActionButton('User Stats', Colors.red, Icons.person, screenWidth, context, '/userStatsPage'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create category buttons with dynamic font size and navigation
  Widget _buildCategoryButton(String label, double screenWidth, BuildContext context, String route) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the respective route
        Navigator.pushNamed(context, route);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: getDynamicFontSize(context, 14),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        minimumSize: Size(screenWidth * 0.4, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 3, // Add shadow
      ),
    );
  }

  // Helper method to create action buttons (History, User Stats) with dynamic font size and navigation
  Widget _buildActionButton(String label, Color color, IconData icon, double screenWidth, BuildContext context, String route) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to the respective route
        Navigator.pushNamed(context, route);
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: getDynamicFontSize(context, 15), 
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(screenWidth * 0.4, 50), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
      ),
    );
  }
}