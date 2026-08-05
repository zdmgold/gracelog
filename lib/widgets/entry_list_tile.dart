import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/utils/constants.dart';

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
    final preview = entry.gratitudeItems.isNotEmpty
        ? entry.gratitudeItems.first
        : 'No gratitude items';

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirm(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.textError.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.textError,
          size: 24,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date column
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.date.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _monthAbbrev(entry.date.month),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Mood icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.mood.colorToken.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  entry.mood.icon,
                  color: entry.mood.colorToken,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (entry.category != null)
                          _buildCategoryChip(entry.category!),
                        if (entry.scriptureReference != null) ...[
                          if (entry.category != null)
                            const SizedBox(width: 8),
                          Icon(
                            Icons.menu_book,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.scriptureReference!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _monthAbbrev(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'This entry will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
