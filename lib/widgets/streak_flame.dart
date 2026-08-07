import 'package:flutter/material.dart';

import '../core/utils/constants.dart';
import '../core/utils/haptics.dart';

/// Animated streak counter with flame icon.
///
/// Scales up briefly when the streak hits a milestone (7, 30, 100, 365)
/// and fires success haptics. When the streak is 0, gently breathes
/// (scale 1.0 → 1.06 loop) as a soft invitation rather than a
/// discouraging static state.
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
    with TickerProviderStateMixin {
  late AnimationController _milestoneController;
  late Animation<double> _milestoneScale;

  late AnimationController _breatheController;
  late Animation<double> _breatheScale;

  int _lastStreak = 0;

  @override
  void initState() {
    super.initState();
    _milestoneController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _milestoneScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_milestoneController);

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _breatheScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _lastStreak = widget.streakDays;
    if (_lastStreak == 0) _breatheController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant StreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakDays != _lastStreak) {
      final previous = _lastStreak;
      _lastStreak = widget.streakDays;

      if (widget.streakDays == 0) {
        _breatheController.repeat(reverse: true);
      } else if (previous == 0) {
        _breatheController.stop();
        _breatheController.value = 0;
      }

      if (AppConstants.streakMilestones.contains(widget.streakDays)) {
        Haptics.success(context);
        _milestoneController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _milestoneController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flameColor = widget.streakDays >= 30
        ? AppColors.accentGold
        : widget.streakDays >= 7
            ? AppColors.accentOrange
            : AppColors.accentWarm;

    return Semantics(
      label: '${widget.streakDays} day streak',
      value: widget.streakDays > 0 ? 'Keep it going!' : 'Start your streak today',
      child: AnimatedBuilder(
        animation: Listenable.merge([_milestoneScale, _breatheScale]),
        builder: (context, child) {
          final scale = widget.streakDays == 0 ? _breatheScale.value : _milestoneScale.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, color: flameColor, size: 28),
            const SizedBox(width: 6),
            Text(
              '${widget.streakDays}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: flameColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.streakDays == 1 ? 'day' : 'days',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
