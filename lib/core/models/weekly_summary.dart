import 'package:flutter/foundation.dart';

import '../utils/date_formatter.dart';
import 'daily_entry.dart';
import 'mood_type.dart';

/// Immutable model representing a weekly summary of entries.
@immutable
class WeeklySummary {
  const WeeklySummary({
    required this.id,
    required this.weekStart,
    required this.entries,
    required this.moodCounts,
    required this.generatedInsight,
    required this.streakDays,
  });

  final String id;
  final DateTime weekStart;
  final List<DailyEntry> entries;
  final Map<MoodType, int> moodCounts;
  final String generatedInsight;
  final int streakDays;

  WeeklySummary copyWith({
    String? id,
    DateTime? weekStart,
    List<DailyEntry>? entries,
    Map<MoodType, int>? moodCounts,
    String? generatedInsight,
    int? streakDays,
  }) {
    return WeeklySummary(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      entries: entries ?? this.entries,
      moodCounts: moodCounts ?? this.moodCounts,
      generatedInsight: generatedInsight ?? this.generatedInsight,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekStart': DateFormatter.toIso8601(weekStart),
      'entries': entries.map((e) => e.toJson()).toList(),
      'moodCounts': moodCounts.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'generatedInsight': generatedInsight,
      'streakDays': streakDays,
    };
  }

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      id: json['id'] as String,
      weekStart: DateFormatter.fromIso8601(json['weekStart'] as String),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => DailyEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      moodCounts: (json['moodCounts'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(MoodType.fromString(key), value as int),
      ),
      generatedInsight: json['generatedInsight'] as String,
      streakDays: json['streakDays'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklySummary &&
        other.id == id &&
        other.weekStart == weekStart &&
        listEquals(other.entries, entries) &&
        mapEquals(other.moodCounts, moodCounts) &&
        other.generatedInsight == generatedInsight &&
        other.streakDays == streakDays;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      weekStart,
      Object.hashAll(entries),
      Object.hashAll(moodCounts.entries),
      generatedInsight,
      streakDays,
    );
  }

  @override
  String toString() {
    return 'WeeklySummary(id: $id, weekStart: $weekStart, '
        'entries: ${entries.length}, streak: $streakDays)';
  }
}
