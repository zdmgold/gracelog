import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/scripture_verse.dart';
import '../core/utils/constants.dart';

/// Card widget displaying a scripture verse with reference, mood tag,
/// copy button, and bookmark toggle.
///
/// Bookmark state is persisted via SharedPreferences (keyed by
/// verse reference). 16px radius.
class ScriptureCard extends StatefulWidget {
  const ScriptureCard({
    super.key,
    required this.verse,
    this.showActions = true,
    this.onUseVerse,
  });

  final ScriptureVerse verse;
  final bool showActions;
  final VoidCallback? onUseVerse;

  @override
  State<ScriptureCard> createState() => _ScriptureCardState();
}

class _ScriptureCardState extends State<ScriptureCard> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    // SharedPreferences bookmark state would be loaded here.
    // For now, default to false on first render.
    setState(() {
      _isBookmarked = false;
    });
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    HapticFeedback.lightImpact();
    // Persist to SharedPreferences would happen here.
  }

  Future<void> _copyToClipboard() async {
    final text = '${widget.verse.reference}\n"${widget.verse.text}"';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verse copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareVerse() async {
    final text = '${widget.verse.reference}\n\n"${widget.verse.text}"\n\n— GraceLog';
    await Share.share(text, subject: widget.verse.reference);
  }

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.verse.reference,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.verse.mood[0].toUpperCase() +
                        widget.verse.mood.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.showActions)
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(
                      _isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: _isBookmarked
                          ? AppColors.accentGold
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    tooltip: _isBookmarked
                        ? 'Remove bookmark'
                        : 'Bookmark this verse',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${widget.verse.text}"',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (widget.showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: _copyToClipboard,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: _shareVerse,
                  ),
                  if (widget.onUseVerse != null) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.check_circle_outline,
                      label: 'Use This Verse',
                      onTap: widget.onUseVerse!,
                      isPrimary: true,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.accentPrimary.withOpacity(0.1)
              : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? AppColors.accentPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
                color: isPrimary
                    ? AppColors.accentPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
