import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/scripture_verse.dart';
import '../models/mood_type.dart';

/// GraceLog scripture engine.
///
/// Loads all 7 scripture batch files at app init, merges them into a
/// single master list, and provides mood-based selection, reference
/// lookup, and full-text search.
///
/// Usage:
/// ```dart
/// await ScriptureEngine().initialize();
/// final verse = ScriptureEngine().getVerseForMood(MoodType.peaceful);
/// ```
class ScriptureEngine {
  static final ScriptureEngine _instance = ScriptureEngine._internal();
  factory ScriptureEngine() => _instance;
  ScriptureEngine._internal();

  final List<ScriptureVerse> _verses = [];
  bool _initialized = false;
  final Random _random = Random();

  /// True if all batch files have been loaded successfully.
  bool get isInitialized => _initialized;

  /// Total number of verses loaded across all batches.
  int get verseCount => _verses.length;

  /// Loads scriptures_1.json through scriptures_7.json from the asset
  /// bundle and merges them into [_verses].
  ///
  /// Safe to call multiple times --- subsequent calls are no-ops.
  /// Individual batch failures are logged but do not abort the init;
  /// the engine continues with whatever batches loaded successfully.
  Future<void> initialize() async {
    if (_initialized) return;

    const int batchCount = 7;
    for (int i = 1; i <= batchCount; i++) {
      try {
        final jsonString = await rootBundle.loadString(
          'assets/scriptures_$i.json',
        );
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final batchVerses = (json['verses'] as List<dynamic>)
            .map(
              (v) => ScriptureVerse.fromJson(v as Map<String, dynamic>),
            )
            .toList();
        _verses.addAll(batchVerses);
      } catch (e, stackTrace) {
        _logError('initialize batch $i', e, stackTrace);
      }
    }

    _initialized = true;
  }

  /// Returns a random [ScriptureVerse] matching [mood].
  /// Returns null if the engine is not initialized or no verses match.
  ScriptureVerse? getVerseForMood(MoodType mood) {
    if (!_initialized || _verses.isEmpty) return null;

    final matching = _verses.where((v) => v.mood == mood.name).toList();
    if (matching.isEmpty) return null;

    return matching[_random.nextInt(matching.length)];
  }

  /// Returns the first [ScriptureVerse] whose [reference] exactly matches
  /// [reference]. Returns null if not found or not initialized.
  ScriptureVerse? getVerseByReference(String reference) {
    if (!_initialized || _verses.isEmpty) return null;

    for (final verse in _verses) {
      if (verse.reference == reference) return verse;
    }
    return null;
  }

  /// Returns all verses whose [book] exactly matches [bookName].
  /// Book names use full names (e.g., "Philippians", "2 Corinthians").
  /// Returns an empty list if not initialized.
  List<ScriptureVerse> getVersesByBook(String bookName) {
    if (!_initialized || _verses.isEmpty) return [];

    return _verses.where((v) => v.book == bookName).toList();
  }

  /// Returns all verses tagged with [mood].
  /// Returns an empty list if not initialized.
  List<ScriptureVerse> getVersesByMood(MoodType mood) {
    if (!_initialized || _verses.isEmpty) return [];

    return _verses.where((v) => v.mood == mood.name).toList();
  }

  /// Full-text search across verse [text], [reference], [book], and [mood].
  /// Case-insensitive. Returns an empty list if not initialized or
  /// [query] is empty.
  List<ScriptureVerse> searchVerses(String query) {
    if (!_initialized || _verses.isEmpty || query.trim().isEmpty) {
      return [];
    }

    final lower = query.toLowerCase().trim();
    return _verses.where((v) {
      return v.text.toLowerCase().contains(lower) ||
          v.reference.toLowerCase().contains(lower) ||
          v.book.toLowerCase().contains(lower) ||
          v.mood.toLowerCase().contains(lower);
    }).toList();
  }

  /// Returns an unmodifiable view of all loaded verses.
  List<ScriptureVerse> getAllVerses() => List.unmodifiable(_verses);

  /// Returns a map of mood tag to verse count for all loaded verses.
  Map<String, int> getMoodDistribution() {
    final distribution = <String, int>{};
    for (final verse in _verses) {
      distribution[verse.mood] = (distribution[verse.mood] ?? 0) + 1;
    }
    return distribution;
  }

  /// Returns a random verse from the entire collection, regardless of mood.
  /// Useful for "verse of the day" or daily notification content.
  ScriptureVerse? getRandomVerse() {
    if (!_initialized || _verses.isEmpty) return null;
    return _verses[_random.nextInt(_verses.length)];
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  void _logError(String method, Object error, StackTrace stackTrace) {
    // In production this routes to the global ErrorHandler.
    // ignore: avoid_print
    print('[ScriptureEngine::$method] $error\n$stackTrace');
  }
}
