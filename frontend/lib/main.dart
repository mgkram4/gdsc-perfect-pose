import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/home_page.dart';
import 'package:perfect_pose/services/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Defined Routes
  static const String home = "/home";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        home: (context) => const HomePage(),
      },
      home: const AuthWrapper(),
    );
  }
}