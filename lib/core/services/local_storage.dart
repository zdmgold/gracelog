import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/daily_entry.dart';
import '../models/mood_type.dart';

/// GraceLog local persistence layer using sqflite.
///
/// Schema version 2 — entries table with audioPath and photoPaths
/// columns added on top of the version 1 schema. Existing installs
/// migrate via [onUpgrade]; new installs get the full schema directly
/// via [onCreate]. All async operations are wrapped in try/catch and
/// check for initialization before executing.
class LocalStorage {
  static const String _databaseName = 'gracelog.db';
  static const int _databaseVersion = 2;
  static const String _entriesTable = 'entries';

  Database? _db;

  /// Returns the singleton database instance, initializing if needed.
  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  /// Initializes the SQLite database with the entries table.
  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE $_entriesTable (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            gratitudeItems TEXT NOT NULL,
            mood TEXT NOT NULL,
            scriptureReference TEXT,
            scriptureText TEXT,
            category TEXT,
            audioPath TEXT,
            photoPaths TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        """);
        await db.execute("""
          CREATE INDEX idx_entries_date ON $_entriesTable(date)
        """);
        await db.execute("""
          CREATE INDEX idx_entries_mood ON $_entriesTable(mood)
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Existing installs: add the two new columns. Existing rows
          // get NULL for both, which DailyEntry.fromMap already
          // handles gracefully (treated as no attachment).
          await db.execute("ALTER TABLE $_entriesTable ADD COLUMN audioPath TEXT");
          await db.execute("ALTER TABLE $_entriesTable ADD COLUMN photoPaths TEXT");
        }
      },
    );
  }

  /// Inserts a new [DailyEntry]. Returns the inserted entry on success,
  /// or null if the operation fails.
  Future<DailyEntry?> insertEntry(DailyEntry entry) async {
    try {
      final db = await database;
      await db.insert(
        _entriesTable,
        _entryToMap(entry),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return entry;
    } catch (e, stackTrace) {
      _logError('insertEntry', e, stackTrace);
      return null;
    }
  }

  /// Updates an existing [DailyEntry] by [id]. Returns the updated entry
  /// on success, or null if the operation fails.
  Future<DailyEntry?> updateEntry(DailyEntry entry) async {
    try {
      final db = await database;
      final count = await db.update(
        _entriesTable,
        _entryToMap(entry),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      if (count == 0) return null;
      return entry;
    } catch (e, stackTrace) {
      _logError('updateEntry', e, stackTrace);
      return null;
    }
  }

  /// Deletes the entry matching [id]. Returns true on success.
  Future<bool> deleteEntry(String id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _entriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e, stackTrace) {
      _logError('deleteEntry', e, stackTrace);
      return false;
    }
  }

  /// Retrieves the single entry for a specific calendar [date]
  /// (matched by YYYY-MM-DD). Returns null if not found or on error.
  Future<DailyEntry?> getEntryByDate(DateTime date) async {
    try {
      final db = await database;
      final dateKey = _dateToKey(date);
      final results = await db.query(
        _entriesTable,
        where: 'date = ?',
        whereArgs: [dateKey],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return _mapToEntry(results.first);
    } catch (e, stackTrace) {
      _logError('getEntryByDate', e, stackTrace);
      return null;
    }
  }

  /// Retrieves all entries between [start] and [end] inclusive,
  /// ordered by date descending. Returns an empty list on error.
  Future<List<DailyEntry>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await database;
      final results = await db.query(
        _entriesTable,
        where: 'date >= ? AND date <= ?',
        whereArgs: [_dateToKey(start), _dateToKey(end)],
        orderBy: 'date DESC',
      );
      return results.map(_mapToEntry).toList();
    } catch (e, stackTrace) {
      _logError('getEntriesByDateRange', e, stackTrace);
      return [];
    }
  }

  /// Retrieves every entry in the database, ordered by date descending.
  /// Returns an empty list on error.
  Future<List<DailyEntry>> getAllEntries() async {
    try {
      final db = await database;
      final results = await db.query(
        _entriesTable,
        orderBy: 'date DESC',
      );
      return results.map(_mapToEntry).toList();
    } catch (e, stackTrace) {
      _logError('getAllEntries', e, stackTrace);
      return [];
    }
  }

  /// Full-text search across gratitude items, category, scripture
  /// reference, and scripture text. Returns an empty list on error.
  Future<List<DailyEntry>> searchEntries(String query) async {
    try {
      final db = await database;
      final pattern = '%$query%';
      final results = await db.query(
        _entriesTable,
        where:
            'gratitudeItems LIKE ? OR category LIKE ? OR '
            'scriptureReference LIKE ? OR scriptureText LIKE ?',
        whereArgs: [pattern, pattern, pattern, pattern],
        orderBy: 'date DESC',
      );
      return results.map(_mapToEntry).toList();
    } catch (e, stackTrace) {
      _logError('searchEntries', e, stackTrace);
      return [];
    }
  }

  /// Calculates the current gratitude streak.
  ///
  /// A streak is the count of consecutive days with at least one entry,
  /// counted backwards from the most recent entry day. If the most recent
  /// entry is more than one day ago, the streak is zero.
  Future<int> getStreakCount() async {
    try {
      final db = await database;
      final results = await db.query(
        _entriesTable,
        columns: ['date'],
        orderBy: 'date DESC',
      );
      if (results.isEmpty) return 0;

      final dates = results
          .map((r) => DateTime.parse(r['date'] as String))
          .toList();

      int streak = 1;
      DateTime previous = dates.first;

      for (int i = 1; i < dates.length; i++) {
        final current = dates[i];
        final difference = previous.difference(current).inDays;
        if (difference == 1) {
          streak++;
          previous = current;
        } else if (difference == 0) {
          continue;
        } else {
          break;
        }
      }

      final now = DateTime.now();
      final daysSinceLastEntry = DateTime(now.year, now.month, now.day)
          .difference(DateTime(previous.year, previous.month, previous.day))
          .inDays;
      if (daysSinceLastEntry > 1) return 0;

      return streak;
    } catch (e, stackTrace) {
      _logError('getStreakCount', e, stackTrace);
      return 0;
    }
  }

  /// Retrieves entries for the week beginning on [weekStart] (Sunday).
  /// Returns an empty list on error.
  Future<List<DailyEntry>> getEntriesForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return getEntriesByDateRange(weekStart, weekEnd);
  }

  /// Returns the count of entries in the database.
  Future<int> getEntryCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_entriesTable',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e, stackTrace) {
      _logError('getEntryCount', e, stackTrace);
      return 0;
    }
  }

  /// Returns a map of [MoodType] to occurrence count for all entries.
  Future<Map<MoodType, int>> getMoodDistribution() async {
    try {
      final db = await database;
      final results = await db.rawQuery(
        'SELECT mood, COUNT(*) as count FROM $_entriesTable GROUP BY mood',
      );
      final distribution = <MoodType, int>{};
      for (final row in results) {
        final mood = MoodType.fromString(row['mood'] as String);
        distribution[mood] = row['count'] as int;
      }
      return distribution;
    } catch (e, stackTrace) {
      _logError('getMoodDistribution', e, stackTrace);
      return {};
    }
  }

  /// Closes the database connection. Safe to call multiple times.
  Future<void> close() async {
    try {
      await _db?.close();
      _db = null;
    } catch (e, stackTrace) {
      _logError('close', e, stackTrace);
    }
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  Map<String, dynamic> _entryToMap(DailyEntry entry) {
    return {
      'id': entry.id,
      'date': _dateToKey(entry.date),
      'gratitudeItems': jsonEncode(entry.gratitudeItems),
      'mood': entry.mood.name,
      'scriptureReference': entry.scriptureReference,
      'scriptureText': entry.scriptureText,
      'category': entry.category,
      'audioPath': entry.audioPath,
      'photoPaths': entry.photoPaths.isEmpty ? null : jsonEncode(entry.photoPaths),
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
    };
  }

  DailyEntry _mapToEntry(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      gratitudeItems:
          List<String>.from(jsonDecode(map['gratitudeItems'] as String)),
      mood: MoodType.fromString(map['mood'] as String),
      scriptureReference: map['scriptureReference'] as String?,
      scriptureText: map['scriptureText'] as String?,
      category: map['category'] as String?,
      audioPath: map['audioPath'] as String?,
      photoPaths: map['photoPaths'] != null
          ? List<String>.from(jsonDecode(map['photoPaths'] as String))
          : const [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String _dateToKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.toIso8601String().split('T').first;
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // In production this routes to the global ErrorHandler.
    // ignore: avoid_print
    print('[LocalStorage::$method] $error\n$stackTrace');
  }
}
