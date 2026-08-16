import 'dart:async';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/sound_track.dart';

/// Immutable state for the Sleep Sounds player.
class SleepSoundsState {
  const SleepSoundsState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLooping = true,
    this.sleepTimerMinutes,
    this.remainingSeconds,
  });

  final SoundTrack? currentTrack;
  final bool isPlaying;
  final bool isLooping;

  /// Null means no timer set — loops until manually stopped ("all night").
  final int? sleepTimerMinutes;
  final int? remainingSeconds;
}

/// Manages Sleep Sounds playback: local looping ambient/instrumental
/// tracks with lock-screen controls (via just_audio_background) and
/// an optional sleep timer.
///
/// True singleton — unlike the instance-per-screen provider
/// convention used elsewhere, playback must survive navigation and
/// be visible from the home dashboard even when this screen is closed.
class SleepSoundsService extends ValueNotifier<SleepSoundsState> {
  static final SleepSoundsService _instance = SleepSoundsService._internal();
  factory SleepSoundsService() => _instance;
  SleepSoundsService._internal() : super(const SleepSoundsState());

  final AudioPlayer _player = AudioPlayer();
  Timer? _countdownTimer;

  Future<void> play(SoundTrack track) async {
    try {
      await _player.setAudioSource(
        AudioSource.asset(
          track.assetPath,
          tag: MediaItem(
            id: track.id,
            title: track.title,
            album: 'GraceLog Sleep Sounds',
          ),
        ),
      );
      await _player.setLoopMode(value.isLooping ? LoopMode.one : LoopMode.off);
      await _player.play();
      value = SleepSoundsState(
        currentTrack: track,
        isPlaying: true,
        isLooping: value.isLooping,
        sleepTimerMinutes: value.sleepTimerMinutes,
        remainingSeconds: value.remainingSeconds,
      );
    } catch (e, stackTrace) {
      _logError('play', e, stackTrace);
    }
  }

  Future<void> togglePlayPause() async {
    if (value.currentTrack == null) return;
    try {
      if (value.isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      value = SleepSoundsState(
        currentTrack: value.currentTrack,
        isPlaying: !value.isPlaying,
        isLooping: value.isLooping,
        sleepTimerMinutes: value.sleepTimerMinutes,
        remainingSeconds: value.remainingSeconds,
      );
    } catch (e, stackTrace) {
      _logError('togglePlayPause', e, stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e, stackTrace) {
      _logError('stop', e, stackTrace);
    }
    _cancelCountdown();
    value = const SleepSoundsState();
  }

  Future<void> setLooping(bool loop) async {
    try {
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    } catch (e, stackTrace) {
      _logError('setLooping', e, stackTrace);
    }
    value = SleepSoundsState(
      currentTrack: value.currentTrack,
      isPlaying: value.isPlaying,
      isLooping: loop,
      sleepTimerMinutes: value.sleepTimerMinutes,
      remainingSeconds: value.remainingSeconds,
    );
  }

  /// Sets a sleep timer in [minutes]; pass null for no timer (loops
  /// until manually stopped).
  void setSleepTimer(int? minutes) {
    _cancelCountdown();

    if (minutes == null) {
      value = SleepSoundsState(
        currentTrack: value.currentTrack,
        isPlaying: value.isPlaying,
        isLooping: value.isLooping,
        sleepTimerMinutes: null,
        remainingSeconds: null,
      );
      return;
    }

    value = SleepSoundsState(
      currentTrack: value.currentTrack,
      isPlaying: value.isPlaying,
      isLooping: value.isLooping,
      sleepTimerMinutes: minutes,
      remainingSeconds: minutes * 60,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = (value.remainingSeconds ?? 0) - 1;
      if (remaining <= 0) {
        stop();
      } else {
        value = SleepSoundsState(
          currentTrack: value.currentTrack,
          isPlaying: value.isPlaying,
          isLooping: value.isLooping,
          sleepTimerMinutes: value.sleepTimerMinutes,
          remainingSeconds: remaining,
        );
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[SleepSoundsService::$method] $error\n$stackTrace');
  }
}
