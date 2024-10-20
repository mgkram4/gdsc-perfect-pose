import 'package:flutter/material.dart';

class top_app_bar extends StatelessWidget implements PreferredSizeWidget {
  final String centerText;
  final String? profilePicUrl;
  final VoidCallback onSettingsTap;

  const top_app_bar({
    Key? key,
    required this.centerText,
    this.profilePicUrl,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Avatar image or fallback icon
          GestureDetector(
            onTap: () {
              // Navigate to profile page
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.065,
              backgroundImage:
                  profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
              child: profilePicUrl == null
                  ? const Icon(Icons.account_circle_outlined, size: 40)
                  : null,
            ),
          ),

          // Center: Page title
          Text(
            centerText,
            style: TextStyle(
              fontSize: getDynamicFontSize(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),

          // Right: Gear icon for settings
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}
