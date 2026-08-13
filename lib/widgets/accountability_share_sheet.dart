import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/weekly_summary.dart';

/// Bottom sheet for sharing a weekly summary with an accountability
/// partner via the native share sheet.
class AccountabilityShareSheet extends StatelessWidget {
  const AccountabilityShareSheet({super.key, required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: theme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share with Your Accountability Partner', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Send your weekly summary to someone who encourages your faith journey.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My GraceLog Week', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(summary.generatedInsight, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPreviewStat(theme, icon: Icons.edit_note, value: '${summary.entries.length}', label: 'Entries'),
                      const SizedBox(width: 16),
                      _buildPreviewStat(theme, icon: Icons.local_fire_department, value: '${summary.streakDays}', label: 'Streak'),
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
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text('Your data stays on your device. Only what you share leaves.', style: theme.textTheme.labelSmall)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(ThemeData theme, {required IconData icon, required String value, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text('$value $label', style: theme.textTheme.bodySmall),
      ],
    );
  }

  Future<void> _shareSummary(BuildContext context) async {
    final start = summary.weekStart;
    final end = start.add(const Duration(days: 6));
    final fmt = (DateTime d) => '${d.month}/${d.day}/${d.year}';

    final buffer = StringBuffer();
    buffer.writeln('My GraceLog Week (${fmt(start)} - ${fmt(end)})');
    buffer.writeln();
    buffer.writeln(summary.generatedInsight);
    buffer.writeln();
    buffer.writeln('Entries: ${summary.entries.length}');
    buffer.writeln('Streak: ${summary.streakDays} days');
    buffer.writeln();
    buffer.writeln('Shared from GraceLog');

    // FIX: Share.share() (static, deprecated) -> SharePlus.instance.share()
    await SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: 'My GraceLog Weekly Summary'));
  }
}
