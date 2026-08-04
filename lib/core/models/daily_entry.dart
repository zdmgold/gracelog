import 'package:flutter/foundation.dart';

import '../utils/date_formatter.dart';
import 'mood_type.dart';

/// Immutable model representing a single daily gratitude entry.
@immutable
class DailyEntry {
  const DailyEntry({
    required this.id,
    required this.date,
    required this.gratitudeItems,
    required this.mood,
    this.scriptureReference,
    this.scriptureText,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime date;
  final List<String> gratitudeItems;
  final MoodType mood;
  final String? scriptureReference;
  final String? scriptureText;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a copy with optional field overrides.
  DailyEntry copyWith({
    String? id,
    DateTime? date,
    List<String>? gratitudeItems,
    MoodType? mood,
    String? scriptureReference,
    String? scriptureText,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      gratitudeItems: gratitudeItems ?? this.gratitudeItems,
      mood: mood ?? this.mood,
      scriptureReference: scriptureReference ?? this.scriptureReference,
      scriptureText: scriptureText ?? this.scriptureText,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateFormatter.toIso8601(date),
      'gratitudeItems': gratitudeItems,
      'mood': mood.name,
      'scriptureReference': scriptureReference,
      'scriptureText': scriptureText,
      'category': category,
      'createdAt': DateFormatter.toIso8601(createdAt),
      'updatedAt': DateFormatter.toIso8601(updatedAt),
    };
  }

  /// Deserializes from JSON.
  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json['id'] as String,
      date: DateFormatter.fromIso8601(json['date'] as String),
      gratitudeItems: (json['gratitudeItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mood: MoodType.fromString(json['mood'] as String),
      scriptureReference: json['scriptureReference'] as String?,
      scriptureText: json['scriptureText'] as String?,
      category: json['category'] as String?,
      createdAt: DateFormatter.fromIso8601(json['createdAt'] as String),
      updatedAt: DateFormatter.fromIso8601(json['updatedAt'] as String),
    );
  }

  /// Serializes to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormatter.toIso8601(date),
      'gratitudeItems': gratitudeItems.join('\n'),
      'mood': mood.name,
      'scriptureReference': scriptureReference,
      'scriptureText': scriptureText,
      'category': category,
      'createdAt': DateFormatter.toIso8601(createdAt),
      'updatedAt': DateFormatter.toIso8601(updatedAt),
    };
  }

  /// Deserializes from a database map.
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'] as String,
      date: DateFormatter.fromIso8601(map['date'] as String),
      gratitudeItems: (map['gratitudeItems'] as String)
          .split('\n')
          .where((s) => s.isNotEmpty)
          .toList(),
      mood: MoodType.fromString(map['mood'] as String),
      scriptureReference: map['scriptureReference'] as String?,
      scriptureText: map['scriptureText'] as String?,
      category: map['category'] as String?,
      createdAt: DateFormatter.fromIso8601(map['createdAt'] as String),
      updatedAt: DateFormatter.fromIso8601(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyEntry &&
        other.id == id &&
        other.date == date &&
        listEquals(other.gratitudeItems, gratitudeItems) &&
        other.mood == mood &&
        other.scriptureReference == scriptureReference &&
        other.scriptureText == scriptureText &&
        other.category == category &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      date,
      Object.hashAll(gratitudeItems),
      mood,
      scriptureReference,
      scriptureText,
      category,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyEntry(id: $id, date: $date, mood: ${mood.name}, '
        'items: ${gratitudeItems.length})';
  }
}
