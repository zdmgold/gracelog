import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/utils/haptics.dart';
import '../core/utils/theme.dart';

/// List tile for the entry history list.
///
/// Shows date, mood icon, first gratitude item preview, category chip.
/// 48dp minimum height. Tap to view detail. Swipe to delete with
/// confirmation dialog.
class EntryListTile extends StatelessWidget {
  const EntryListTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final DailyEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = entry.gratitudeItems.isNotEmpty ? entry.gratitudeItems.first : 'No gratitude items';

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirm(context, theme),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: theme.shadowLight,
        ),
        child: InkWell(
          onTap: () {
            Haptics.tap(context);
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${entry.date.day}', style: theme.textTheme.titleLarge),
                      Text(_monthAbbrev(entry.date.month), style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.mood.colorToken.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.mood.icon, color: entry.mood.colorToken, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (entry.category != null) _buildCategoryChip(theme, entry.category!),
                          if (entry.scriptureReference != null) ...[
                            if (entry.category != null) const SizedBox(width: 8),
                            Icon(Icons.menu_book, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Text(entry.scriptureReference!, style: theme.textTheme.labelSmall),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(category, style: theme.textTheme.labelSmall),
    );
  }

  String _monthAbbrev(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<bool> _showDeleteConfirm(BuildContext context, ThemeData theme) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This entry will be permanently removed. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
