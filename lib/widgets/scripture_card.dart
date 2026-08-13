import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/scripture_verse.dart';
import '../core/utils/theme.dart';

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
    this.onTap,
  });

  final ScriptureVerse verse;
  final bool showActions;
  final VoidCallback? onUseVerse;
  final VoidCallback? onTap;

  @override
  State<ScriptureCard> createState() => _ScriptureCardState();
}

class _ScriptureCardState extends State<ScriptureCard> {
  bool _isBookmarked = false;

  String get _prefsKey => 'bookmark_${widget.verse.reference}';

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  // FIX: previously always set false and never read SharedPreferences
  // at all, despite the docstring's claim — bookmarks silently reset
  // every time the card rebuilt. Now actually persisted.
  Future<void> _loadBookmarkState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isBookmarked = prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> _toggleBookmark() async {
    final next = !_isBookmarked;
    setState(() => _isBookmarked = next);
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, next);
  }

  Future<void> _copyToClipboard() async {
    final text = '${widget.verse.reference}\n"${widget.verse.text}"';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse copied to clipboard'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _shareVerse() async {
    final text = '${widget.verse.reference}\n\n"${widget.verse.text}"\n\n— GraceLog';
    // FIX: Share.share() (static, deprecated) -> SharePlus.instance.share()
    await SharePlus.instance.share(ShareParams(text: text, subject: widget.verse.reference));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // FIX: was Card(elevation: 0) with only a border — no real depth,
    // unlike every other card in the app. Container + boxShadow matches
    // the shared depth system (theme.shadowLight/Medium).
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: theme.shadowLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.verse.reference,
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    widget.verse.mood[0].toUpperCase() + widget.verse.mood.substring(1),
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const Spacer(),
                if (widget.showActions)
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                      size: 22,
                    ),
                    tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark this verse',
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${widget.verse.text}"',
              style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, height: 1.6),
            ),
            if (widget.showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton(icon: Icons.copy, label: 'Copy', onTap: _copyToClipboard),
                  const SizedBox(width: 8),
                  _buildActionButton(icon: Icons.share, label: 'Share', onTap: _shareVerse),
                  if (widget.onUseVerse != null) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(icon: Icons.check_circle_outline, label: 'Use This Verse', onTap: widget.onUseVerse!, isPrimary: true),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.onTap != null) {
      return InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(16), child: cardContent);
    }

    return cardContent;
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, bool isPrimary = false}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
                color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
