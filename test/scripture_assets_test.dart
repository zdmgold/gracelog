import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gracelog/core/models/mood_type.dart';
import 'package:gracelog/core/models/scripture_verse.dart';

void main() {
  group('scripture batch files', () {
    final moodNames = MoodType.values.map((m) => m.name).toSet();

    test('all 7 files exist, parse, and match the ScriptureVerse schema', () {
      var total = 0;
      final seenMoods = <String>{};

      for (var i = 1; i <= 7; i++) {
        final file = File('app/assets/scriptures_$i.json');
        expect(file.existsSync(), isTrue, reason: '${file.path} missing');

        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final verses = json['verses'] as List<dynamic>;
        expect(verses, isNotEmpty);

        for (final raw in verses) {
          final verse = ScriptureVerse.fromJson(raw as Map<String, dynamic>);
          expect(verse.reference.trim(), isNotEmpty);
          expect(verse.text.trim(), isNotEmpty);
          expect(moodNames.contains(verse.mood), isTrue,
              reason: 'unknown mood "${verse.mood}" in ${verse.reference}');
          seenMoods.add(verse.mood);
          total++;
        }
      }

      expect(total, greaterThanOrEqualTo(500));
      expect(seenMoods, equals(moodNames),
          reason: 'every app mood needs at least one verse');
    });
  });
}
