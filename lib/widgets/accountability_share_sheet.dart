import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/weekly_summary.dart';
import '../core/utils/constants.dart';

/// Bottom sheet for sharing a weekly summary with an accountability
/// partner via the native share sheet.
///
/// Shows a preview of the summary, a share button, and a hint about
/// choosing a contact. No server involved --- 1-to-1 native share.
class AccountabilityShareSheet extends StatelessWidget {
  const AccountabilityShareSheet({
    super.key,
    required this.summary,
  });

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share with Your Accountability Partner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send your weekly summary to someone who encourages your faith journey.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            // Preview card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My GraceLog Week',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.generatedInsight,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPreviewStat(
                        icon: Icons.edit_note,
                        value: '${summary.entries.length}',
                        label: 'Entries',
                      ),
                      const SizedBox(width: 16),
                      _buildPreviewStat(
                        icon: Icons.local_fire_department,
                        value: '${summary.streakDays}',
                        label: 'Streak',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _shareSummary(context),
                icon: const Icon(Icons.share),
                label: const Text('Share Weekly Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Your data stays on your device. Only what you share leaves.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _shareSummary(BuildContext context) async {
    final start = summary.weekStart;
    final end = start.add(const Duration(days: 6));
    final fmt = (DateTime d) =>
        '${d.month}/${d.day}/${d.year}';

    final buffer = StringBuffer();
    buffer.writeln('My GraceLog Week (${fmt(start)} - ${fmt(end)})');
    buffer.writeln();
    buffer.writeln(summary.generatedInsight);
    buffer.writeln();
    buffer.writeln('Entries: ${summary.entries.length}');
    buffer.writeln('Streak: ${summary.streakDays} days');
    buffer.writeln();
    buffer.writeln('Shared from GraceLog');

    await Share.share(
      buffer.toString(),
      subject: 'My GraceLog Weekly Summary',
    );
  }
}
