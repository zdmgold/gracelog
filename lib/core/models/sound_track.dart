import 'package:flutter/foundation.dart';

/// A single bundled ambient/instrumental track for Sleep Sounds.
///
/// All tracks are local assets (declared in pubspec.yaml), never
/// streamed — consistent with GraceLog's 100% offline design.
@immutable
class SoundTrack {
  const SoundTrack({
    required this.id,
    required this.title,
    required this.assetPath,
  });

  final String id;
  final String title;

  /// Path exactly as declared under pubspec.yaml's `assets:` list.
  final String assetPath;
}

/// The fixed set of 13 bundled Sleep Sounds tracks.
///
/// Convention: to refresh content, swap the file at an existing path
/// and update its title here — don't add new entries, to keep the
/// app's bundled audio footprint from growing over time.
class SoundLibrary {
  const SoundLibrary._();

  static const List<SoundTrack> tracks = [
    SoundTrack(id: 'rise_up_with_grace_1', title: 'Rise Up With Grace I', assetPath: 'app/assets/sounds/rise_up_with_grace_1.m4a'),
    SoundTrack(id: 'rise_up_with_grace_2', title: 'Rise Up With Grace II', assetPath: 'app/assets/sounds/rise_up_with_grace_2.m4a'),
    SoundTrack(id: 'walking_in_faith_1', title: 'Walking in Faith I', assetPath: 'app/assets/sounds/walking_in_faith_1.m4a'),
    SoundTrack(id: 'walking_in_faith_2', title: 'Walking in Faith II', assetPath: 'app/assets/sounds/walking_in_faith_2.m4a'),
    SoundTrack(id: 'walk_in_the_light', title: 'Walk in the Light', assetPath: 'app/assets/sounds/walk_in_the_light.m4a'),
    SoundTrack(id: 'grace_of_his_light', title: 'Grace of His Light', assetPath: 'app/assets/sounds/grace_of_his_light.m4a'),
    SoundTrack(id: 'the_mark_of_god', title: 'The Mark of God', assetPath: 'app/assets/sounds/the_mark_of_god.m4a'),
    SoundTrack(id: 'gospel_hip_hop_instrumental', title: 'Gospel Hip-Hop', assetPath: 'app/assets/sounds/gospel_hip_hop_instrumental.m4a'),
    SoundTrack(id: 'gospel_reflections', title: 'Gospel Reflections', assetPath: 'app/assets/sounds/gospel_reflections.m4a'),
    SoundTrack(id: 'bible_soundtrack_instrumental', title: 'Bible Soundtrack', assetPath: 'app/assets/sounds/bible_soundtrack_instrumental.m4a'),
    SoundTrack(id: 'heavens_embrace_piano', title: "Heaven's Embrace (Piano)", assetPath: 'app/assets/sounds/heavens_embrace_piano.m4a'),
    SoundTrack(id: 'messiah_instrumental', title: 'Messiah', assetPath: 'app/assets/sounds/messiah_instrumental.m4a'),
    SoundTrack(id: 'christian_worship_piano', title: 'Worship Piano', assetPath: 'app/assets/sounds/christian_worship_piano.m4a'),
  ];
}
