import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/history_page.dart';
import 'package:perfect_pose/pages/home_page.dart';
import 'package:perfect_pose/pages/login_page.dart';
import 'package:perfect_pose/pages/register_page.dart';
import 'package:perfect_pose/services/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // DEFINED ROUTES
  static const String home = "/home";
  static const String login = "/login";
  static const String register = "/register";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        home: (context) => const HomePage(),
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
      },
      home: const HistoryPage(),
    );
  }
}
