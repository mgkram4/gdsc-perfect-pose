import 'package:flutter/material.dart';

void showSettingsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // This allows the modal to be larger
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), // Padding to move the content up
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                onTap: () {
                  // Add Edit Profile action
                  Navigator.pop(context); // Dismiss modal when tapped
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Add Settings action
                  Navigator.pop(context); // Dismiss modal when tapped
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
