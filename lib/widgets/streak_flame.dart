import 'package:flutter/material.dart';

import '../core/utils/constants.dart';

/// Animated streak counter with flame icon.
///
/// Scales up briefly when the streak hits a milestone (7, 30, 100).
/// Announces via Semantics: "[N] day streak".
class StreakFlame extends StatefulWidget {
  const StreakFlame({
    super.key,
    required this.streakDays,
  });

  final int streakDays;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _lastStreak = 0;

  static const List<int> _milestones = [7, 30, 100, 365];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
    _lastStreak = widget.streakDays;
  }

  @override
  void didUpdateWidget(covariant StreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakDays != _lastStreak) {
      _lastStreak = widget.streakDays;
      if (_isMilestone(widget.streakDays)) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isMilestone(int streak) {
    return _milestones.contains(streak);
  }

  @override
  Widget build(BuildContext context) {
    final flameColor = widget.streakDays >= 30
        ? AppColors.accentGold
        : widget.streakDays >= 7
            ? AppColors.accentOrange
            : AppColors.accentWarm;

    return Semantics(
      label: '${widget.streakDays} day streak',
      value: widget.streakDays > 0
          ? 'Keep it going!'
          : 'Start your streak today',
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: flameColor,
              size: 28,
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.streakDays}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: flameColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.streakDays == 1 ? 'day' : 'days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
