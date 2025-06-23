import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/firestore_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  final FirestoreService _firestoreService = FirestoreService();

  // User data
  Map<String, dynamic>? _userStats;
  List<Map<String, dynamic>> _progressData = [];
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

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final results = await Future.wait([
          _firestoreService.getUserStats(user.uid),
          _firestoreService.getWeeklyProgressData(user.uid),
        ]);

        setState(() {
          _userStats = results[0] as Map<String, dynamic>;
          _progressData = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });

        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          _chartController.forward();
        });
      }
    } catch (e) {
      print('Error loading stats data: $e');
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
    }
  }

  List<FlSpot> get _chartSpots {
    if (_progressData.isEmpty) {
      // Return fallback data if no real data
      return [
        const FlSpot(0, 30),
        const FlSpot(1, 45),
        const FlSpot(2, 50),
        const FlSpot(3, 55),
        const FlSpot(4, 60),
        const FlSpot(5, 65),
        const FlSpot(6, 70),
        const FlSpot(7, 75),
        const FlSpot(8, 80),
        const FlSpot(9, 85),
        const FlSpot(10, 90),
        const FlSpot(11, 95),
        const FlSpot(12, 100),
        const FlSpot(13, 95),
        const FlSpot(14, 90),
      ];
    }

    return _progressData.map((data) {
      return FlSpot(
        (data['day'] as int).toDouble(),
        (data['score'] as double).clamp(0.0, 100.0),
      );
    }).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartController.dispose();
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

                                    SizedBox(height: screenHeight * 0.025),

                                    // Stats Cards Row
                                    _buildStatsCardsRow(context),

                                    SizedBox(height: screenHeight * 0.03),

                                    // Weekly Progress Chart
                                    _buildWeeklyProgressChart(context),

                                    SizedBox(height: screenHeight * 0.03),

                                    // Weekly Challenges Card
                                    _buildWeeklyChallengesCard(context),

                                    SizedBox(height: screenHeight * 0.02),
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
                'Performance Stats',
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
                  color: primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: primaryBlue,
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Your Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your fitness journey with detailed analytics',
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
                    colors: [primaryBlue, const Color(0xFF4A73C1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCardsRow(BuildContext context) {
    final totalWorkouts = _userStats?['totalWorkouts'] ?? 0;
    final currentStreak = _userStats?['currentStreak'] ?? 0;
    final recentActivities = _userStats?['recentActivities'] as List? ?? [];

    // Calculate average score from recent activities
    final averageScore = recentActivities.isNotEmpty
        ? recentActivities.fold<double>(
                0, (sum, activity) => sum + (activity['score'] ?? 0)) /
            recentActivities.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildModernStatsBox(
            '${averageScore.toInt()}%',
            'Average',
            'Form Score',
            primaryBlue,
            Icons.analytics_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatsBox(
            '$currentStreak',
            'Day',
            'Streak',
            neonGreen,
            Icons.local_fire_department_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatsBox(
      String value, String label1, String label2, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
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
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label1,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                label2,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: neonGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      color: neonGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _chartAnimation.value,
                    child: SizedBox(
                      height: 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 600,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 20,
                                verticalInterval: 2,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: textSecondary.withOpacity(0.1),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: textSecondary.withOpacity(0.1),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    'Days',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      TextStyle style = TextStyle(
                                        fontSize: 10,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      );
                                      String text = '';
                                      if (value.toInt() % 2 == 0) {
                                        text = '${value.toInt() + 1}/08';
                                      }
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(text, style: style),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    'Form Scores',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      TextStyle style = TextStyle(
                                        fontSize: 10,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      );
                                      String text = '${value.toInt()}%';
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(text, style: style),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: glassBorder,
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: 14,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _chartSpots,
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [neonGreen, primaryBlue],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: neonGreen,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        neonGreen.withOpacity(0.3),
                                        neonGreen.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChallengesCard(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: coralRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: coralRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Weekly Achievements',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAchievementRow('Total Workouts',
                  '${_userStats?['totalWorkouts'] ?? 0}', neonGreen),
              const SizedBox(height: 16),
              _buildAchievementRow('Current Streak',
                  '${_userStats?['currentStreak'] ?? 0}', primaryBlue),
              const SizedBox(height: 16),
              _buildAchievementRow('Weekly Sessions',
                  '${_userStats?['weeklyWorkouts'] ?? 0}', coralRed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
