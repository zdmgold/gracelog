import 'package:flutter/foundation.dart';

/// Immutable model representing a single scripture verse.
/// Matches the schema in assets/scriptures_*.json
@immutable
class ScriptureVerse {
  const ScriptureVerse({
    required this.reference,
    required this.text,
    required this.mood,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
  });

  final String reference;
  final String text;
  final String mood;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;

  ScriptureVerse copyWith({
    String? reference,
    String? text,
    String? mood,
    String? book,
    int? chapter,
    int? verseStart,
    int? verseEnd,
  }) {
    return ScriptureVerse(
      reference: reference ?? this.reference,
      text: text ?? this.text,
      mood: mood ?? this.mood,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseStart: verseStart ?? this.verseStart,
      verseEnd: verseEnd ?? this.verseEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'text': text,
      'mood': mood,
      'book': book,
      'chapter': chapter,
      'verse_start': verseStart,
      'verse_end': verseEnd,
    };
  }

  factory ScriptureVerse.fromJson(Map<String, dynamic> json) {
    return ScriptureVerse(
      reference: json['reference'] as String,
      text: json['text'] as String,
      mood: json['mood'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verseStart: json['verse_start'] as int,
      verseEnd: json['verse_end'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScriptureVerse &&
        other.reference == reference &&
        other.text == text &&
        other.mood == mood &&
        other.book == book &&
        other.chapter == chapter &&
        other.verseStart == verseStart &&
        other.verseEnd == verseEnd;
  }

  @override
  int get hashCode {
    return Object.hash(
      reference,
      text,
      mood,
      book,
      chapter,
      verseStart,
      verseEnd,
    );
  }

  @override
  String toString() {
    return 'ScriptureVerse(reference: $reference, mood: $mood)';
  }
}
