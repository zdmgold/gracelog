import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/haptics.dart';

/// GitHub-style contribution heatmap.
///
/// Renders [weeks] columns of 7 days each, most recent week on the
/// right. Cell color intensity scales with the entry's total word
/// count for that day. Tapping a day with an entry invokes [onDayTap].
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    super.key,
    required this.entries,
    this.weeks = 12,
    this.onDayTap,
  });

  final List<DailyEntry> entries;
  final int weeks;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Align the grid so the current week ends on today's weekday.
    final alignedStart = today.subtract(
      Duration(days: (weeks * 7 - 1) + (today.weekday % 7)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weeks, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              children: List.generate(7, (dayIndex) {
                final date = alignedStart.add(
                  Duration(days: weekIndex * 7 + dayIndex),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildCell(context, theme, date, today),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(BuildContext context, ThemeData theme, DateTime date, DateTime today) {
    if (date.isAfter(today)) {
      return const SizedBox(width: 14, height: 14);
    }

    DailyEntry? entry;
    for (final e in entries) {
      if (DateFormatter.isSameDay(e.date, date)) {
        entry = e;
        break;
      }
    }

    final hasEntry = entry != null;
    final wordCount = hasEntry ? entry!.gratitudeItems.join(' ').split(' ').length : 0;
    final intensity = hasEntry ? (wordCount / 40).clamp(0.25, 1.0) : 0.0;

    return Tooltip(
      message: hasEntry
          ? '${date.month}/${date.day} — ${entry!.gratitudeItems.length} item${entry.gratitudeItems.length == 1 ? '' : 's'}'
          : '${date.month}/${date.day} — no entry',
      child: InkWell(
        onTap: hasEntry
            ? () {
                Haptics.tick(context);
                onDayTap?.call(date);
              }
            : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: hasEntry
                ? theme.colorScheme.primary.withOpacity(intensity)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
