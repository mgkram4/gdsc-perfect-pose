import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/firestore_service.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}

class HomePage extends StatefulWidget {
  final Function(int)? onNavigateToPage;

  const HomePage({super.key, this.onNavigateToPage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _dailyChallenge;
  bool _isLoading = true;
  bool _hasCompletedChallenge = false;

  // Modern fitness colors
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color coralRed = Color(0xFFFF5C5C);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassSecondary = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  @override
  void initState() {
    super.initState();

    // Glow animation for interactive elements
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);

    _loadHomeData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final results = await Future.wait([
          _firestoreService.getUserProfile(user.uid),
          _firestoreService.getUserStats(user.uid),
          _firestoreService.getDailyChallenge(),
          _firestoreService.hasCompletedDailyChallenge(user.uid),
        ]);

        setState(() {
          _userProfile = results[0] as Map<String, dynamic>?;
          _userStats = results[1] as Map<String, dynamic>;
          _dailyChallenge = results[2] as Map<String, dynamic>?;
          _hasCompletedChallenge = results[3] as bool;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildGlassAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0B), Color(0xFF1A1A1B)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(neonGreen),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  backgroundColor: const Color(0xFF1A1A1B),
                  color: neonGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome section with stats
                        _buildWelcomeSection(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.025),

                        // Daily Challenge Glass Card
                        _buildDailyChallengeCard(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.025),

                        // Feature Cards Row
                        _buildFeatureCardsRow(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.025),

                        // Jump Back In Section
                        _buildJumpBackInSection(
                            context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.025),

                        // Category Grid
                        _buildCategoryGrid(context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.025),

                        // Action Buttons
                        _buildActionButtons(context, screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _userProfile?['displayName'] ??
        user?.displayName ??
        'Fitness Enthusiast';

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: glassPrimary,
              border: Border(
                bottom: BorderSide(color: glassBorder, width: 0.5),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    // User Avatar
                    GestureDetector(
                      onTap: () => widget.onNavigateToPage
                          ?.call(5), // Profile page index
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(22.5),
                          border: Border.all(
                            color: neonGreen,
                            width: 2,
                          ),
                        ),
                        child: user?.photoURL != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20.5),
                                child: Image.network(
                                  user!.photoURL!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.fitness_center,
                                size: 24,
                                color: neonGreen,
                              ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Welcome Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: getDynamicFontSize(context, 14),
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: getDynamicFontSize(context, 18),
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings Icon
                    IconButton(
                      onPressed: () => _showSettingsModal(context),
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: textPrimary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
      BuildContext context, double screenWidth, double screenHeight) {
    final totalWorkouts = _userStats?['totalWorkouts'] ?? 0;
    final currentStreak = _userStats?['currentStreak'] ?? 0;
    final weeklyWorkouts = _userStats?['weeklyWorkouts'] ?? 0;

    // Calculate accuracy based on recent activities
    final recentActivities = _userStats?['recentActivities'] as List? ?? [];
    final averageScore = recentActivities.isNotEmpty
        ? recentActivities.fold<double>(
                0, (sum, activity) => sum + (activity['score'] ?? 0)) /
            recentActivities.length
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 28),
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to crush your fitness goals today?',
                style: TextStyle(
                  fontSize: getDynamicFontSize(context, 16),
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem('$currentStreak', 'Day Streak', neonGreen),
                  const SizedBox(width: 20),
                  _buildStatItem('$totalWorkouts', 'Workouts', primaryBlue),
                  const SizedBox(width: 20),
                  _buildStatItem(
                      '${averageScore.toInt()}%', 'Avg Score', coralRed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 24),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 12),
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengeCard(
      BuildContext context, double screenWidth, double screenHeight) {
    final challengeTitle = _dailyChallenge?['title'] ?? 'Perfect Plank';
    final challengeDescription = _dailyChallenge?['description'] ??
        'Hold a plank for 60 seconds with perfect form';
    final challengeReward = _dailyChallenge?['reward'] ?? 50;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: glassPrimary,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                    color: _hasCompletedChallenge
                        ? primaryBlue.withOpacity(0.3)
                        : neonGreen.withOpacity(0.3),
                    width: 1),
                boxShadow: [
                  BoxShadow(
                    color: (_hasCompletedChallenge ? primaryBlue : neonGreen)
                        .withOpacity(_glowAnimation.value * 0.2),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_hasCompletedChallenge
                                    ? primaryBlue
                                    : neonGreen)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _hasCompletedChallenge
                                ? Icons.check_circle
                                : Icons.emoji_events_rounded,
                            color: _hasCompletedChallenge
                                ? primaryBlue
                                : neonGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasCompletedChallenge
                                    ? 'Challenge Complete!'
                                    : 'Daily Challenge',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: getDynamicFontSize(context, 24),
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                _hasCompletedChallenge
                                    ? 'Great job today!'
                                    : challengeTitle,
                                style: TextStyle(
                                  fontSize: getDynamicFontSize(context, 14),
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!_hasCompletedChallenge) ...[
                      const SizedBox(height: 16),
                      Text(
                        challengeDescription,
                        style: TextStyle(
                          fontSize: getDynamicFontSize(context, 14),
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reward: $challengeReward XP',
                        style: TextStyle(
                          fontSize: getDynamicFontSize(context, 12),
                          color: neonGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Action Button
                    GestureDetector(
                      onTap: _hasCompletedChallenge
                          ? null
                          : () => widget.onNavigateToPage
                              ?.call(1), // Post page index
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _hasCompletedChallenge
                                ? [
                                    primaryBlue.withOpacity(0.3),
                                    primaryBlue.withOpacity(0.1)
                                  ]
                                : [neonGreen, neonGreen.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: (_hasCompletedChallenge
                                      ? primaryBlue
                                      : neonGreen)
                                  .withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _hasCompletedChallenge
                                ? 'Completed ✓'
                                : 'Start Challenge',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: getDynamicFontSize(context, 18),
                              color: _hasCompletedChallenge
                                  ? primaryBlue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCardsRow(
      BuildContext context, double screenWidth, double screenHeight) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            context,
            'Perfect Form',
            'AI-powered form analysis',
            Icons.visibility_rounded,
            primaryBlue,
            () => _showInfoDialog(context, 'Perfect Form',
                'Get real-time feedback on your exercise form with our advanced AI technology.'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            context,
            'Pro Tips',
            'Learn from experts',
            Icons.school_rounded,
            coralRed,
            () => _showInfoDialog(context, 'Pro Tips',
                'Access professional guidance and tips to master your workout techniques.'),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle,
      IconData icon, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: glassPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: glassBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 12),
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpBackInSection(
      BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jump Back In',
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 22),
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Continue where you left off',
          style: TextStyle(
            fontSize: getDynamicFontSize(context, 14),
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(
      BuildContext context, double screenWidth, double screenHeight) {
    final categories = [
      {
        'name': 'Weight Lifting',
        'icon': Icons.fitness_center_rounded,
        'color': primaryBlue
      },
      {
        'name': 'Yoga',
        'icon': Icons.self_improvement_rounded,
        'color': neonGreen
      },
      {
        'name': 'Bodyweight',
        'icon': Icons.accessibility_new_rounded,
        'color': coralRed
      },
      {
        'name': 'Functional',
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFFFF9500)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(
          context,
          category['name'] as String,
          category['icon'] as IconData,
          category['color'] as Color,
        );
      },
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => widget.onNavigateToPage?.call(1), // Post page index
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: glassPrimary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double screenWidth, double screenHeight) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'History',
            Icons.history_rounded,
            neonGreen,
            () => widget.onNavigateToPage?.call(3), // History page index
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            'User Stats',
            Icons.analytics_rounded,
            primaryBlue,
            () => widget.onNavigateToPage?.call(2), // Stats page index
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: glassPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getDynamicFontSize(context, 15),
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: const Color(0xE6000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: glassBorder, width: 1),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              content: Text(
                content,
                style: const TextStyle(color: textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [neonGreen, Color(0xFF2ECC71)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context) {
    showSettingsModal(context);
  }
}
