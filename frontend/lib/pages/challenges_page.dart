import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/firestore_service.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirestoreService _firestoreService = FirestoreService();

  // User data
  List<Map<String, dynamic>> _challenges = [];
  Map<String, dynamic>? _challengeStats;
  bool _isLoading = true;

  // Modern fitness colors
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color coralRed = Color(0xFFFF5C5C);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final results = await Future.wait([
          _firestoreService.getUserChallenges(user.uid),
          _firestoreService.getChallengeStats(user.uid),
        ]);

        setState(() {
          _challenges = results[0] as List<Map<String, dynamic>>;
          _challengeStats = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });

        _animationController.forward();
      }
    } catch (e) {
      print('Error loading challenges data: $e');
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0B), Color(0xFF1A1A1B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Glass App Bar
              _buildGlassAppBar(context),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(neonGreen),
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: RefreshIndicator(
                              onRefresh: _loadUserData,
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
                                    // Header Section
                                    _buildHeaderSection(context),

                                    SizedBox(height: screenHeight * 0.03),

                                    // Stats Cards Row
                                    _buildStatsSection(context),

                                    SizedBox(height: screenHeight * 0.03),

                                    // Challenges Section Header
                                    _buildSectionHeader(
                                        context, 'Today\'s Challenges'),

                                    SizedBox(height: screenHeight * 0.02),

                                    // Challenge Cards
                                    _buildChallengesList(context),

                                    // Secret Challenge Unlock Message
                                    if (_challengeStats?['secretUnlocked'] ==
                                            false &&
                                        (_challengeStats?['completedToday'] ??
                                                0) >
                                            0)
                                      _buildSecretChallengeTeaser(context),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: glassPrimary,
            border: const Border(
              bottom: BorderSide(color: glassBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Challenges',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: neonGreen,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Your Limits',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete daily challenges to earn points and improve your skills',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [neonGreen, const Color(0xFF2ECC71)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final completedToday = _challengeStats?['completedToday'] ?? 0;
    final totalChallenges = _challengeStats?['totalChallenges'] ?? 5;
    final totalPoints = _challengeStats?['totalPoints'] ?? 0;
    final streak = _challengeStats?['streak'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('$completedToday/$totalChallenges', 'Completed',
              neonGreen, Icons.check_circle_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              '$totalPoints', 'Points', primaryBlue, Icons.stars_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('$streak', 'Streak', coralRed,
              Icons.local_fire_department_rounded),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_challenges.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesList(BuildContext context) {
    if (_challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No challenges available',
                style: TextStyle(
                  fontSize: 18,
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete some workouts to unlock challenges!',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutBack,
          child: RealChallengeCard(
            challenge: challenge,
          ),
        );
      },
    );
  }

  Widget _buildSecretChallengeTeaser(BuildContext context) {
    final completed = _challengeStats?['completedToday'] ?? 0;
    final remaining = 3 - completed;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: glassPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secret Challenge Locked',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete $remaining more challenge${remaining != 1 ? 's' : ''} to unlock!',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RealChallengeCard extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const RealChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  State<RealChallengeCard> createState() => _RealChallengeCardState();
}

class _RealChallengeCardState extends State<RealChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Modern fitness colors
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color secretGold = Color(0xFFFFD700);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  bool get isSecretChallenge =>
      widget.challenge['type']?.toLowerCase() == 'secret';
  bool get isCompleted => widget.challenge['completed'] == true;

  @override
  void initState() {
    super.initState();
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

    if (isCompleted || isSecretChallenge) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.challenge['progress'] ?? 0.0) as double;
    final current = widget.challenge['current'] ?? 0;
    final target = widget.challenge['target'] ?? 1;
    final title = widget.challenge['title'] ?? 'Challenge';
    final description = widget.challenge['description'] ?? '';
    final type = widget.challenge['type'] ?? 'GENERAL';
    final points = widget.challenge['points'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: glassPrimary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? neonGreen
                        : isSecretChallenge
                            ? secretGold.withOpacity(0.6)
                            : glassBorder,
                    width: isCompleted || isSecretChallenge ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isCompleted) ...[
                      BoxShadow(
                        color:
                            neonGreen.withOpacity(_glowAnimation.value * 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ] else if (isSecretChallenge) ...[
                      BoxShadow(
                        color:
                            secretGold.withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSecretChallenge
                                  ? secretGold.withOpacity(0.2)
                                  : primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSecretChallenge
                                    ? secretGold.withOpacity(0.6)
                                    : primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSecretChallenge) ...[
                                  Icon(Icons.star, size: 14, color: secretGold),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                    color: isSecretChallenge
                                        ? secretGold
                                        : primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Completion Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isCompleted ? neonGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isCompleted ? Colors.black : textSecondary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // Progress Section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$current / $target',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? neonGreen
                                            : textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCompleted
                                            ? neonGreen
                                            : isSecretChallenge
                                                ? secretGold
                                                : primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Text(
                                '+$points',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSecretChallenge
                                      ? secretGold
                                      : neonGreen,
                                ),
                              ),
                              Text(
                                'XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
