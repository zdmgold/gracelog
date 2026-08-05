import 'package:flutter/foundation.dart';

import '../models/daily_entry.dart';
import '../models/mood_type.dart';
import '../models/weekly_summary.dart';
import '../services/local_storage.dart';

/// Immutable state container for the entries provider.
class EntriesState {
  const EntriesState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DailyEntry> entries;
  final bool isLoading;
  final String? error;

  EntriesState copyWith({
    List<DailyEntry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error : this.error,
    );
  }
}

/// Manages all DailyEntry CRUD operations, streak calculation,
/// and weekly summary generation.
///
/// Uses [LocalStorage] for persistence. All mutations emit a new
/// [EntriesState] so [ListenableBuilder] widgets rebuild correctly.
class EntriesProvider extends ValueNotifier<EntriesState> {
  EntriesProvider() : super(const EntriesState());

  final LocalStorage _storage = LocalStorage();

  /// Loads all entries from the database.
  Future<void> loadEntries() async {
    value = value.copyWith(isLoading: true, error: null);
    try {
      final entries = await _storage.getAllEntries();
      value = value.copyWith(entries: entries, isLoading: false);
    } catch (e, stackTrace) {
      _logError('loadEntries', e, stackTrace);
      value = value.copyWith(
        isLoading: false,
        error: 'Failed to load entries.',
      );
    }
  }

  /// Adds a new entry. Refreshes the full list on success.
  Future<bool> addEntry(DailyEntry entry) async {
    try {
      final result = await _storage.insertEntry(entry);
      if (result != null) {
        await loadEntries();
        return true;
      }
      value = value.copyWith(error: 'Failed to save entry.');
      return false;
    } catch (e, stackTrace) {
      _logError('addEntry', e, stackTrace);
      value = value.copyWith(error: 'Failed to save entry.');
      return false;
    }
  }

  /// Updates an existing entry. Refreshes the full list on success.
  Future<bool> updateEntry(DailyEntry entry) async {
    try {
      final result = await _storage.updateEntry(entry);
      if (result != null) {
        await loadEntries();
        return true;
      }
      value = value.copyWith(error: 'Failed to update entry.');
      return false;
    } catch (e, stackTrace) {
      _logError('updateEntry', e, stackTrace);
      value = value.copyWith(error: 'Failed to update entry.');
      return false;
    }
  }

  /// Deletes an entry by [id]. Refreshes the full list on success.
  Future<bool> deleteEntry(String id) async {
    try {
      final success = await _storage.deleteEntry(id);
      if (success) {
        await loadEntries();
        return true;
      }
      value = value.copyWith(error: 'Failed to delete entry.');
      return false;
    } catch (e, stackTrace) {
      _logError('deleteEntry', e, stackTrace);
      value = value.copyWith(error: 'Failed to delete entry.');
      return false;
    }
  }

  /// Returns the entry for a specific date, or null if none exists.
  Future<DailyEntry?> getEntryForDate(DateTime date) async {
    try {
      return await _storage.getEntryByDate(date);
    } catch (e, stackTrace) {
      _logError('getEntryForDate', e, stackTrace);
      return null;
    }
  }

  /// Returns the current streak count.
  Future<int> getStreak() async {
    try {
      return await _storage.getStreakCount();
    } catch (e, stackTrace) {
      _logError('getStreak', e, stackTrace);
      return 0;
    }
  }

  /// Generates a [WeeklySummary] for the week containing [date].
  Future<WeeklySummary?> getWeeklySummary(DateTime date) async {
    try {
      final weekStart = _startOfWeek(date);
      final entries = await _storage.getEntriesForWeek(weekStart);
      if (entries.isEmpty) return null;

      final moodCounts = <MoodType, int>{};
      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }

      final dominantMood = moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final insight = _generateInsight(dominantMood, entries.length);
      final streak = await _storage.getStreakCount();

      return WeeklySummary(
        id: 'week_${weekStart.toIso8601String().split("T").first}',
        weekStart: weekStart,
        entries: entries,
        moodCounts: moodCounts,
        generatedInsight: insight,
        streakDays: streak,
      );
    } catch (e, stackTrace) {
      _logError('getWeeklySummary', e, stackTrace);
      return null;
    }
  }

  /// Searches entries by query text.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await loadEntries();
      return;
    }
    value = value.copyWith(isLoading: true, error: null);
    try {
      final results = await _storage.searchEntries(query);
      value = value.copyWith(entries: results, isLoading: false);
    } catch (e, stackTrace) {
      _logError('search', e, stackTrace);
      value = value.copyWith(
        isLoading: false,
        error: 'Search failed.',
      );
    }
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  DateTime _startOfWeek(DateTime date) {
    // Sunday-based week start
    final weekday = date.weekday % 7;
    return DateTime(date.year, date.month, date.day - weekday);
  }

  String _generateInsight(MoodType dominantMood, int entryCount) {
    return switch (dominantMood) {
      MoodType.thankful =>
        'You felt thankful $entryCount times this week. Gratitude turns what we have into enough.',
      MoodType.joyful =>
        'Joy marked your week with $entryCount entries. The joy of the Lord is your strength.',
      MoodType.peaceful =>
        'Peace was your theme this week ($entryCount entries). His peace passes all understanding.',
      MoodType.hopeful =>
        'Hope carried you through $entryCount moments this week. Faith is the substance of things hoped for.',
      MoodType.anxious =>
        'You faced anxious moments this week ($entryCount entries). Cast all your anxiety on Him.',
      MoodType.worried =>
        'Worry surfaced $entryCount times this week. Do not worry about tomorrow.',
      MoodType.tired =>
        'You recorded weariness $entryCount times this week. Come to Me, all who are weary.',
    };
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[EntriesProvider::$method] $error\n$stackTrace');
  }
}
