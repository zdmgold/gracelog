import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gracelog/core/models/sound_track.dart';

void main() {
  group('SoundLibrary', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('ids are unique', () {
      final ids = SoundLibrary.tracks.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every track file exists on disk and is declared in pubspec.yaml', () {
      for (final track in SoundLibrary.tracks) {
        expect(File(track.assetPath).existsSync(), isTrue,
            reason: '${track.assetPath} missing on disk');
        expect(pubspec.contains(track.assetPath), isTrue,
            reason: '${track.assetPath} not declared in pubspec.yaml');
      }
    });
  });
}
