import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/challenges_page.dart';
import 'package:perfect_pose/pages/history_page.dart';
import 'package:perfect_pose/pages/home_page.dart';
import 'package:perfect_pose/pages/login_page.dart';
import 'package:perfect_pose/pages/post_page.dart';
import 'package:perfect_pose/pages/profile_page.dart';
import 'package:perfect_pose/pages/stats_page.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, return authenticated app structure
          return const AuthenticatedApp();
        } else {
          // User is not signed in, return LoginPage without bottom bar
          return const LoginPage();
        }
      },
    );
  }
}

class AuthenticatedApp extends StatefulWidget {
  const AuthenticatedApp({super.key});

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        HomePage(onNavigateToPage: _onItemTapped),
        const PostPage(),
        const StatsPage(),
        const HistoryPage(),
        const ChallengesPage(),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: BottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
