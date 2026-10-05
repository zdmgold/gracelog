import 'package:flutter_test/flutter_test.dart';
import 'package:gracelog/core/models/daily_entry.dart';
import 'package:gracelog/core/models/mood_type.dart';
import 'package:gracelog/core/utils/date_formatter.dart';

void main() {
  group('MoodType.fromString', () {
    test('is case-insensitive', () {
      expect(MoodType.fromString('JOYFUL'), MoodType.joyful);
      expect(MoodType.fromString('Tired'), MoodType.tired);
    });

    test('falls back to peaceful for unknown values', () {
      expect(MoodType.fromString('nonsense'), MoodType.peaceful);
    });
  });

  group('DailyEntry JSON round trip', () {
    test('keeps every field', () {
      final entry = DailyEntry(
        id: 'abc',
        date: DateTime(2026, 10, 5),
        gratitudeItems: const ['First thing', 'Second thing'],
        mood: MoodType.hopeful,
        scriptureReference: 'Psalm 46:10',
        scriptureText: 'Be still, and know that I am God.',
        category: 'Grace',
        audioPath: '/tmp/a.m4a',
        photoPaths: const ['/tmp/1.jpg', '/tmp/2.jpg'],
        createdAt: DateTime(2026, 10, 5, 6, 30),
        updatedAt: DateTime(2026, 10, 5, 6, 31),
      );

      final decoded = DailyEntry.fromJson(entry.toJson());

      expect(decoded, entry);
      expect(decoded.hasAudio, isTrue);
      expect(decoded.hasPhotos, isTrue);
    });

    test('missing photoPaths decodes to an empty list', () {
      final json = DailyEntry(
        id: 'x',
        date: DateTime(2026, 1, 1),
        gratitudeItems: const ['One'],
        mood: MoodType.thankful,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ).toJson()
        ..remove('photoPaths');

      expect(DailyEntry.fromJson(json).photoPaths, isEmpty);
    });
  });

  group('DateFormatter', () {
    test('isSameDay ignores time of day', () {
      expect(
        DateFormatter.isSameDay(DateTime(2026, 10, 5, 0, 1), DateTime(2026, 10, 5, 23, 59)),
        isTrue,
      );
      expect(
        DateFormatter.isSameDay(DateTime(2026, 10, 5), DateTime(2026, 10, 6)),
        isFalse,
      );
    });

    test('getWeekRange runs Monday to Sunday', () {
      // 2026-10-07 is a Wednesday.
      final range = DateFormatter.getWeekRange(DateTime(2026, 10, 7));
      expect(range.start.weekday, DateTime.monday);
      expect(range.start, DateTime(2026, 10, 5));
      expect(range.end, DateTime(2026, 10, 11));
    });

    test('ISO round trip preserves the moment', () {
      final original = DateTime(2026, 10, 5, 6, 30, 15);
      expect(DateFormatter.fromIso8601(DateFormatter.toIso8601(original)), original);
    });
  });
}
