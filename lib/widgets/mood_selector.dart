import 'package:flutter/material.dart';

import '../core/models/mood_type.dart';
import '../core/utils/haptics.dart';

/// Mood selector grid — all 7 moods visible at once, no scrolling.
///
/// Wraps to a new row as needed rather than hiding options behind a
/// horizontal scroll.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final MoodType selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MoodType.values.map((mood) {
        final isSelected = mood == selectedMood;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Haptics.select(context);
              onMoodSelected(mood);
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? mood.colorToken.withOpacity(0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? mood.colorToken
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mood.icon,
                    size: 18,
                    color: isSelected ? mood.colorToken : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mood.name[0].toUpperCase() + mood.name.substring(1),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected ? mood.colorToken : theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
