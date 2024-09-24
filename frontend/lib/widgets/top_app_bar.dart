import 'package:flutter/material.dart';

//example to use it -> appBar: top_app_bar(centerText: 'name')
//use other parameters if possible, or they will be simply null
class top_app_bar extends StatelessWidget implements PreferredSizeWidget {
  final String centerText;
  final String? profilePicUrl;
  final Scaffold? secondRoute;
  const top_app_bar({super.key, required this.centerText, this.profilePicUrl, this.secondRoute});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Left: Avatar image or fallback icon
          profilePicUrl != null && profilePicUrl!.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(profilePicUrl!),
                  radius: 20,
                )
              : const Icon(Icons.account_circle_outlined, size: 40),

          // Center: Page title
          Text(
            centerText,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),

          // Right: Gear icon for navigating to profile page
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.settings), 
            onPressed: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => 
                secondRoute ?? const BlankPage() 
                )
              ); 
            },
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BlankPage extends StatelessWidget {
  const BlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Blank page", 
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)
          ),
        )
      ),
    );
  }
}