import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/scripture_verse.dart';
import '../core/utils/constants.dart';
import '../widgets/scripture_card.dart';
import 'daily_entry_screen.dart';

/// Full scripture detail screen.
///
/// Displays the verse in large text with reference, mood tag,
/// copy button, share button, and "Use this verse" button that
/// navigates to the entry screen with the verse pre-filled.
class ScriptureDetailScreen extends StatelessWidget {
  const ScriptureDetailScreen({
    super.key,
    required this.verse,
  });

  final ScriptureVerse verse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          verse.reference,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareVerse(),
            icon: Icon(Icons.share, color: AppColors.accentPrimary),
            tooltip: 'Share verse',
          ),
          IconButton(
            onPressed: () => _copyToClipboard(context),
            icon: Icon(Icons.copy, color: AppColors.accentPrimary),
            tooltip: 'Copy verse',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    verse.reference,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      verse.mood[0].toUpperCase() + verse.mood.substring(1),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '"${verse.text}"',
              style: TextStyle(
                fontSize: 22,
                height: 1.7,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '-- ${verse.book} ${verse.chapter}:${verse.verseStart}${verse.verseEnd != null ? '-${verse.verseEnd}' : ''} (KJV)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _useVerse(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Use This Verse in Entry',
                  style: TextStyle(fontSize: 16),
                ),
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
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () => _copyToClipboard(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSecondaryButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () => _shareVerse(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentPrimary,
        side: BorderSide(color: AppColors.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  void _useVerse(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DailyEntryScreen(preselectedVerse: verse),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final text = '${verse.reference}\n"${verse.text}"';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verse copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareVerse() async {
    final text = '${verse.reference}\n\n"${verse.text}"\n\n-- GraceLog';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: verse.reference),
    );
  }
}
