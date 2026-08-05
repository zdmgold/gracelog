import 'package:flutter/material.dart';

import '../core/models/weekly_summary.dart';
import '../core/utils/constants.dart';

/// Card widget displaying the auto-generated weekly insight.
///
/// Shows the dominant mood theme, entry count, streak, and the
/// generated blessing text. 16px radius, subtle border, warm
/// gradient accent on the left edge.
class WeeklyBlessingCard extends StatelessWidget {
  const WeeklyBlessingCard({
    super.key,
    required this.summary,
  });

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      color: AppColors.bgSecondary,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.accentWarm.withOpacity(0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.15],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentWarm,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Blessing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildWeekRangeChip(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              summary.generatedInsight,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.edit_note,
                  label: '${summary.entries.length} entries',
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  icon: Icons.local_fire_department,
                  label: '${summary.streakDays} day streak',
                ),
                const SizedBox(width: 12),
                _buildDominantMoodChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRangeChip() {
    final start = summary.weekStart;
    final end = start.add(const Duration(days: 6));
    final fmt = (DateTime d) =>
        '${d.month}/${d.day}';
    return Chip(
      label: Text(
        '${fmt(start)} - ${fmt(end)}',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
      backgroundColor: AppColors.bgTertiary,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDominantMoodChip() {
    final dominant = summary.moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          dominant.icon,
          size: 14,
          color: dominant.colorToken,
        ),
        const SizedBox(width: 4),
        Text(
          dominant.name[0].toUpperCase() + dominant.name.substring(1),
          style: TextStyle(
            fontSize: 12,
            color: dominant.colorToken,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
