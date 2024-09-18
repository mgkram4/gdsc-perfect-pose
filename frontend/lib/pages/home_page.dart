import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Welcome to Home Page')),
      bottomNavigationBar: bottom_bar(),
    );
  }
}
