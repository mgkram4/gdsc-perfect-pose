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
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Avatar image or fallback icon
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.055,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
              child: profilePicUrl == null
                  ? Icon(Icons.account_circle_outlined,
                      size: 35, color: Colors.grey[600])
                  : null,
            ),
          ),

          // Center: Page title
          Text(
            centerText,
            style: TextStyle(
              fontSize: getDynamicFontSize(context, 24),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),

          // Right: Gear icon for settings
          IconButton(
            iconSize: 26,
            icon:
                Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
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
