import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:perfect_pose/services/auth_service.dart';

void showSettingsModal(BuildContext context) {
  final AuthService authService = AuthService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    builder: (BuildContext context) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xE6000000),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile option
                    _buildSettingsOption(
                      context,
                      Icons.person_outline,
                      'Edit Profile',
                      'Manage your profile information',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),

                    // Settings option
                    _buildSettingsOption(
                      context,
                      Icons.settings_outlined,
                      'App Settings',
                      'Preferences and configurations',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),

                    // Logout option
                    _buildSettingsOption(
                      context,
                      Icons.logout_outlined,
                      'Sign Out',
                      'Sign out of your account',
                      () async {
                        Navigator.pop(context);
                        await _handleSignOut(context, authService);
                      },
                      isDestructive: true,
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildSettingsOption(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap, {
  bool isDestructive = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF5F87D4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF5F87D4),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}

Future<void> _handleSignOut(
    BuildContext context, AuthService authService) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Sign out
    await authService.signOut();

    // Pop loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Navigate to login page - the AuthWrapper will handle this automatically
    // No need to manually navigate as the StreamBuilder will detect the auth state change
  } catch (e) {
    // Pop loading indicator
    if (context.mounted) {
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
