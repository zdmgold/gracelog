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

  bool get isInitialized => _initialized;
  int get verseCount => _verses.length;

  /// Loads scriptures_1.json through scriptures_7.json from the asset
  /// bundle and merges them into [_verses].
  ///
  /// FIX: path corrected to 'app/assets/scriptures_$i.json' to match
  /// the actual declaration in pubspec.yaml. The previous path
  /// ('assets/scriptures_$i.json') never matched any registered asset
  /// key, so every single load failed silently — this is why
  /// "Scripture of the Day" never displayed anything.
  Future<void> initialize() async {
    if (_initialized) return;

    const int batchCount = 7;
    for (int i = 1; i <= batchCount; i++) {
      try {
        final jsonString = await rootBundle.loadString(
          'app/assets/scriptures_$i.json',
        );
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final batchVerses = (json['verses'] as List<dynamic>)
            .map((v) => ScriptureVerse.fromJson(v as Map<String, dynamic>))
            .toList();
        _verses.addAll(batchVerses);
      } catch (e, stackTrace) {
        _logError('initialize batch $i', e, stackTrace);
      }
    }

    _initialized = true;
  }

  ScriptureVerse? getVerseForMood(MoodType mood) {
    if (!_initialized || _verses.isEmpty) return null;
    final matching = _verses.where((v) => v.mood == mood.name).toList();
    if (matching.isEmpty) return null;
    return matching[_random.nextInt(matching.length)];
  }

  ScriptureVerse? getVerseByReference(String reference) {
    if (!_initialized || _verses.isEmpty) return null;
    for (final verse in _verses) {
      if (verse.reference == reference) return verse;
    }
    return null;
  }

  List<ScriptureVerse> getVersesByBook(String bookName) {
    if (!_initialized || _verses.isEmpty) return [];
    return _verses.where((v) => v.book == bookName).toList();
  }

  List<ScriptureVerse> getVersesByMood(MoodType mood) {
    if (!_initialized || _verses.isEmpty) return [];
    return _verses.where((v) => v.mood == mood.name).toList();
  }

  List<ScriptureVerse> searchVerses(String query) {
    if (!_initialized || _verses.isEmpty || query.trim().isEmpty) return [];
    final lower = query.toLowerCase().trim();
    return _verses.where((v) {
      return v.text.toLowerCase().contains(lower) ||
          v.reference.toLowerCase().contains(lower) ||
          v.book.toLowerCase().contains(lower) ||
          v.mood.toLowerCase().contains(lower);
    }).toList();
  }

  List<ScriptureVerse> getAllVerses() => List.unmodifiable(_verses);

  Map<String, int> getMoodDistribution() {
    final distribution = <String, int>{};
    for (final verse in _verses) {
      distribution[verse.mood] = (distribution[verse.mood] ?? 0) + 1;
    }
    return distribution;
  }

  ScriptureVerse? getRandomVerse() {
    if (!_initialized || _verses.isEmpty) return null;
    return _verses[_random.nextInt(_verses.length)];
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[ScriptureEngine::$method] $error\n$stackTrace');
  }
}
