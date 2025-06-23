import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/firestore_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  String _selectedItem = "All Exercises";
  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _listAnimation;

  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _workoutHistory = [];
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

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listController.forward();
    });

    _loadWorkoutHistory();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final activities =
            await _firestoreService.getUserActivities(user.uid, limit: 50);
        setState(() {
          _workoutHistory = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading workout history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _isLoading = true;
    });
    await _loadWorkoutHistory();
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedItem == "All Exercises") {
      return _workoutHistory;
    }
    return _workoutHistory.where((workout) {
      return workout['category']?.toLowerCase() ==
              _selectedItem.toLowerCase() ||
          workout['exerciseType']
                  ?.toLowerCase()
                  .contains(_selectedItem.toLowerCase()) ==
              true;
    }).toList();
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
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          // Header Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.02,
                            ),
                            child: _buildHeaderSection(context),
                          ),

                          // Filter Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                            ),
                            child: _buildFilterSection(context),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // List of exercises
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          neonGreen),
                                    ),
                                  )
                                : AnimatedBuilder(
                                    animation: _listAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _listAnimation.value,
                                        child: _buildHistoryList(context),
                                      );
                                    },
                                  ),
                          ),
                        ],
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
                'Workout History',
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
                  Icons.history_rounded,
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
    final totalWorkouts = _workoutHistory.length;
    final avgScore = _workoutHistory.isNotEmpty
        ? (_workoutHistory.fold<double>(
                    0, (sum, workout) => sum + (workout['score'] ?? 0)) /
                totalWorkouts)
            .round()
        : 0;

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
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your progress and achievements',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  _buildStatItem('$totalWorkouts', 'Total', primaryBlue),
                  const SizedBox(height: 12),
                  _buildStatItem('$avgScore%', 'Avg Score', neonGreen),
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
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final filterOptions = [
      "All Exercises",
      "Bodyweight",
      "Functional",
      "Lifting",
      "Yoga"
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = _selectedItem == option;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedItem = option;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: index == filterOptions.length - 1 ? 0 : 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [neonGreen, neonGreen.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : glassPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? neonGreen : glassBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.black : textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final filteredHistory = _filteredHistory;

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: glassPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glassBorder, width: 1),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedItem == "All Exercises"
                  ? 'No workouts yet'
                  : 'No $_selectedItem workouts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first workout to see your history here',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      backgroundColor: const Color(0xFF1A1A1B),
      color: neonGreen,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(filteredHistory[index], index);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> workout, int index) {
    final exerciseType = workout['exerciseType'] ?? 'Unknown Exercise';
    final category = workout['category'] ?? 'unknown';
    final score = workout['score'] ?? 0;
    final duration = workout['duration'] ?? 0;
    final timestamp = workout['timestamp'] as Timestamp?;

    final dateStr = timestamp != null
        ? '${timestamp.toDate().month}/${timestamp.toDate().day}/${timestamp.toDate().year}'
        : 'Unknown Date';

    final timeStr = timestamp != null
        ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    final scoreColor = score >= 80
        ? neonGreen
        : score >= 60
            ? Colors.orange
            : coralRed;

    final categoryColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
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
            child: Row(
              children: [
                // Exercise Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: categoryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Exercise Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr • $timeStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      if (duration > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${duration}s duration',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Score Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: scoreColor, width: 1),
                  ),
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 14,
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'bodyweight':
        return neonGreen;
      case 'functional':
        return primaryBlue;
      case 'lifting':
        return coralRed;
      case 'yoga':
        return Colors.purple;
      default:
        return textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bodyweight':
        return Icons.fitness_center;
      case 'functional':
        return Icons.directions_run;
      case 'lifting':
        return Icons.sports_gymnastics;
      case 'yoga':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }
}
