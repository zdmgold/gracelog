import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/mood_type.dart';

/// Horizontal scrollable mood selector with 7 chips.
///
/// Each chip shows the mood icon + localized label, colored by the
/// mood's semantic token. 48dp minimum touch target. Haptic feedback
/// on selection. Full Semantics support.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MoodType.all.map((mood) {
          final isSelected = selectedMood == mood;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              label: 'Select ${mood.name} mood',
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onMoodSelected(mood);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.colorToken.withOpacity(0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? mood.colorToken
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mood.icon,
                        color: isSelected
                            ? mood.colorToken
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moodLabel(mood),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? mood.colorToken
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _moodLabel(MoodType mood) {
    return switch (mood) {
      MoodType.peaceful => 'Peaceful',
      MoodType.thankful => 'Thankful',
      MoodType.joyful => 'Joyful',
      MoodType.hopeful => 'Hopeful',
      MoodType.anxious => 'Anxious',
      MoodType.worried => 'Worried',
      MoodType.tired => 'Tired',
    };
  }
}
