import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/auth_service.dart';
import 'package:perfect_pose/services/firestore_service.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  // Modern fitness colors (matching the app theme)
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color coralRed = Color(0xFFFF5C5C);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassSecondary = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _firestoreService.getUserProfile(user.uid);
        final activities =
            await _firestoreService.getUserActivities(user.uid, limit: 5);

        setState(() {
          _userProfile = profile;
          _recentActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: top_app_bar(
        centerText: 'User Profile',
        onSettingsTap: () => showSettingsModal(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0B), Color(0xFF1A1A1B)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(neonGreen),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Column(
                      children: [
                        // Profile Settings Container
                        _buildProfileHeader(context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.02),

                        // Stats Container
                        _buildStatsContainer(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.02),

                        // Recent Activities Container
                        _buildRecentActivitiesContainer(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.02),

                        // Action Buttons
                        _buildActionButtons(context, screenWidth, screenHeight),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, double screenWidth, double screenHeight) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _userProfile?['displayName'] ??
        user?.displayName ??
        'Fitness Enthusiast';
    final email = user?.email ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  border: Border.all(color: neonGreen, width: 3),
                ),
                child: user?.photoURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                        child: Image.network(
                          user!.photoURL!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.fitness_center,
                        size: screenWidth * 0.1,
                        color: neonGreen,
                      ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // User Info
              Text(
                displayName,
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              SizedBox(height: screenHeight * 0.005),

              Text(
                email,
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 14),
                  color: textSecondary,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Edit Profile',
                    primaryBlue,
                    () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  _buildActionButton(
                    'Logout',
                    coralRed,
                    () async {
                      try {
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to log out: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: getDynamicFontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContainer(
      BuildContext context, double screenWidth, double screenHeight) {
    final level = _userProfile?['level'] ?? 1;
    final totalWorkouts = _userProfile?['totalWorkouts'] ?? 0;
    final streak = _userProfile?['streak'] ?? 0;
    final experience = _userProfile?['experience'] ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Level', level.toString(), neonGreen),
                  _buildStatItem(
                      'Workouts', totalWorkouts.toString(), primaryBlue),
                  _buildStatItem('Streak', '$streak days', coralRed),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              // Experience Bar
              Column(
                children: [
                  Text(
                    'Experience: $experience XP',
                    style: TextStyle(
                      fontSize: getDynamicFontSize(context, 14),
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  LinearProgressIndicator(
                    value: (experience % 100) / 100,
                    backgroundColor: glassBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(neonGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 12),
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesContainer(
      BuildContext context, double screenWidth, double screenHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _recentActivities.isEmpty
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: Text(
                        'No activities yet. Start your first workout!',
                        style: TextStyle(
                          fontSize: getDynamicFontSize(context, 14),
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: _recentActivities.map((activity) {
                        return _buildActivityItem(
                            activity, screenWidth, screenHeight);
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      Map<String, dynamic> activity, double screenWidth, double screenHeight) {
    final exerciseType = activity['exerciseType'] ?? 'Unknown Exercise';
    final score = activity['score'] ?? 0;
    final timestamp = activity['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? '${timestamp.toDate().month}/${timestamp.toDate().day}/${timestamp.toDate().year}'
        : 'Unknown Date';

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: glassSecondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: glassBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exerciseType,
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 12),
                  color: textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: neonGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: neonGreen, width: 1),
            ),
            child: Text(
              '$score pts',
              style: TextStyle(
                fontSize: getDynamicFontSize(context, 12),
                color: neonGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      children: [
        // Delete Account Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: ElevatedButton(
            onPressed: () => _showDeleteAccountDialog(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              backgroundColor: coralRed.withOpacity(0.1),
              foregroundColor: coralRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: coralRed, width: 1),
              ),
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: getDynamicFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1B),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: primaryBlue),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await _firestoreService.deleteUserAccount(user.uid);
                    await user.delete();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: coralRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
