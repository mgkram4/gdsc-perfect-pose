import 'package:flutter/material.dart';

class bottom_bar extends StatelessWidget {
  const bottom_bar({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_a_photo_outlined),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.chrome_reader_mode_outlined),
            label: 'History',
          ),
        ],
      )
       );
  }
}
