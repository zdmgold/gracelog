import 'package:flutter/material.dart';

import '../core/models/weekly_summary.dart';
import '../core/utils/constants.dart';
import '../core/utils/theme.dart';

/// Card widget displaying the auto-generated weekly insight.
///
/// Shows the dominant mood theme, entry count, streak, and the
/// generated blessing text. Soft shadow for depth, warm gradient
/// accent on the left edge.
class WeeklyBlessingCard extends StatelessWidget {
  const WeeklyBlessingCard({
    super.key,
    required this.summary,
  });

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
        boxShadow: theme.shadowLight,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.accentWarm.withOpacity(0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accentWarm, size: 20),
              const SizedBox(width: 8),
              Text('Weekly Blessing', style: theme.textTheme.titleMedium),
              const Spacer(),
              _buildWeekRangeChip(theme),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary.generatedInsight,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(theme, icon: Icons.edit_note, label: '${summary.entries.length} entries'),
              const SizedBox(width: 12),
              _buildStatChip(theme, icon: Icons.local_fire_department, label: '${summary.streakDays} day streak'),
              const SizedBox(width: 12),
              _buildDominantMoodChip(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRangeChip(ThemeData theme) {
    final start = summary.weekStart;
    final end = start.add(const Duration(days: 6));
    final fmt = (DateTime d) => '${d.month}/${d.day}';
    return Chip(
      label: Text('${fmt(start)} - ${fmt(end)}', style: theme.textTheme.labelSmall),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatChip(ThemeData theme, {required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }

  Widget _buildDominantMoodChip(ThemeData theme) {
    final dominant = summary.moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(dominant.icon, size: 14, color: dominant.colorToken),
        const SizedBox(width: 4),
        Text(
          dominant.name[0].toUpperCase() + dominant.name.substring(1),
          style: theme.textTheme.labelMedium?.copyWith(
            color: dominant.colorToken,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
