import 'dart:ui';

import 'package:flutter/material.dart';

// Helper function to get dynamic font size based on screen width
double getDynamicFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * screenWidth / 390;
}

class ChallengeCard extends StatefulWidget {
  final String title;
  final String description;
  final String typeOfChallenge;
  final double progress;
  final bool done;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.typeOfChallenge,
    this.progress = 0.0,
    this.done = false,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  // Modern fitness colors
  static const Color primaryBlue = Color(0xFF5F87D4);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color secretGold = Color(0xFFFFD700);
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);

  bool get isSecretChallenge =>
      widget.typeOfChallenge.toLowerCase() == 'secret';

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

    if (widget.done || isSecretChallenge) {
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                      color: widget.done
                          ? neonGreen
                          : isSecretChallenge
                              ? secretGold.withOpacity(0.6)
                              : glassBorder,
                      width: widget.done || isSecretChallenge ? 2 : 1,
                    ),
                    boxShadow: [
                      if (widget.done) ...[
                        BoxShadow(
                          color:
                              neonGreen.withOpacity(_glowAnimation.value * 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color:
                              neonGreen.withOpacity(_glowAnimation.value * 0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ] else if (isSecretChallenge) ...[
                        BoxShadow(
                          color: secretGold
                              .withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: secretGold
                              .withOpacity(_glowAnimation.value * 0.1),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      children: [
                        // Positioned Checkmark in the top right corner
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  widget.done ? neonGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: widget.done
                                  ? [
                                      BoxShadow(
                                        color: neonGreen.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              widget.done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: widget.done ? Colors.black : textSecondary,
                              size: getDynamicFontSize(context, 24),
                            ),
                          ),
                        ),

                        // Main content
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type of challenge badge
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
                                      Icon(
                                        Icons.star,
                                        size: getDynamicFontSize(context, 14),
                                        color: secretGold,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      widget.typeOfChallenge.toUpperCase(),
                                      style: TextStyle(
                                        color: isSecretChallenge
                                            ? secretGold
                                            : primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            getDynamicFontSize(context, 12),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Title of the challenge
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: getDynamicFontSize(context, 22),
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Description of the challenge
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: getDynamicFontSize(context, 14),
                                  color: textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 16),

                              // Progress section
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Progress',
                                          style: TextStyle(
                                            fontSize:
                                                getDynamicFontSize(context, 12),
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: LinearProgressIndicator(
                                              value: widget.progress,
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                widget.done
                                                    ? neonGreen
                                                    : primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${(widget.progress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: getDynamicFontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color:
                                          widget.done ? neonGreen : primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
