import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/edit_profile_page.dart';
import 'package:perfect_pose/pages/help_page.dart';
import 'package:perfect_pose/pages/login_page.dart';
import 'package:perfect_pose/pages/register_page.dart';
import 'package:perfect_pose/pages/settings_page.dart';
import 'package:perfect_pose/pages/terms_page.dart';
import 'package:perfect_pose/services/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // DEFINED ROUTES
  static const String home = "/home";
  static const String login = "/login";
  static const String register = "/register";
  static const String stats = "/stats";
  static const String history = "/history";
  static const String post = "/post";
  static const String challenge = "/challenge";
  static const String profile = "/profile";
  static const String editProfile = "/edit-profile";
  static const String settings = "/settings";
  static const String terms = "/terms";
  static const String help = "/help";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Pose',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF5F87D4),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      ),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        // Check if user is authenticated for protected routes
        final User? currentUser = FirebaseAuth.instance.currentUser;

        switch (settings.name) {
          case login:
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case register:
            return MaterialPageRoute(
                builder: (context) => const RegisterPage());
          case terms:
            return MaterialPageRoute(builder: (context) => const TermsPage());
          case help:
            return MaterialPageRoute(builder: (context) => const HelpPage());
          case MainApp.settings:
            // Settings page - only accessible when authenticated
            return MaterialPageRoute(
              builder: (context) => currentUser != null
                  ? const SettingsPage()
                  : const LoginPage(),
            );
          case MainApp.editProfile:
            // Edit Profile page - only accessible when authenticated
            return MaterialPageRoute(
              builder: (context) => currentUser != null
                  ? const EditProfilePage()
                  : const LoginPage(),
            );
          case home:
          case stats:
          case history:
          case post:
          case challenge:
          case profile:
            // For authenticated routes, always return AuthWrapper
            // AuthWrapper will handle showing the correct page with bottom bar if authenticated
            // or login page if not authenticated
            return MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            );
          default:
            return MaterialPageRoute(builder: (context) => const AuthWrapper());
        }
      },
    );
  }
}
