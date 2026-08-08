import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/providers/entries_provider.dart';
import '../core/utils/constants.dart';
import '../core/utils/haptics.dart';
import '../widgets/mood_selector.dart';

enum _VoiceStage { idle, recording, recorded, saving }

/// Quick voice-note gratitude entry.
///
/// Flow: pick a mood, record, preview playback, optional short
/// caption, save. Only the recording itself is required — caption
/// and mood default are both optional, keeping this a genuinely
/// fast capture path rather than a second full entry form.
class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen>
    with SingleTickerProviderStateMixin {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _captionController = TextEditingController();

  late final AnimationController _pulseController;

  _VoiceStage _stage = _VoiceStage.idle;
  MoodType _selectedMood = MoodType.thankful;
  String? _recordedPath;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackTotal = Duration.zero;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _positionSub = _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _playbackPosition = position);
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    _player.dispose();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _captionController.dispose();
    // EntriesProvider intentionally not disposed — instance-per-screen
    // convention established in Batch 1.
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showError('Microphone access is needed to record a voice note.');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/gracelog_audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final path = '${audioDir.path}/${const Uuid().v4()}.m4a';

      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);

      Haptics.tap(context);
      _pulseController.repeat(reverse: true);
      _recordDuration = Duration.zero;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordDuration += const Duration(seconds: 1));
      });

      setState(() => _stage = _VoiceStage.recording);
    } catch (e) {
      _showError('Could not start recording. Please try again.');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      _recordTimer?.cancel();
      _pulseController.stop();
      _pulseController.value = 0;

      if (path == null) {
        _showError('Recording failed. Please try again.');
        setState(() => _stage = _VoiceStage.idle);
        return;
      }

      Haptics.success(context);
      setState(() {
        _recordedPath = path;
        _stage = _VoiceStage.recorded;
      });

      await _player.setFilePath(path);
      _playbackTotal = _player.duration ?? _recordDuration;
    } catch (e) {
      _showError('Could not save the recording. Please try again.');
      setState(() => _stage = _VoiceStage.idle);
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _reRecord() async {
    Haptics.tap(context);
    await _player.stop();
    if (_recordedPath != null) {
      try {
        final file = File(_recordedPath!);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Non-fatal — a stray temp file isn't worth surfacing an error for.
      }
    }
    setState(() {
      _recordedPath = null;
      _recordDuration = Duration.zero;
      _playbackPosition = Duration.zero;
      _stage = _VoiceStage.idle;
    });
  }

  Future<void> _saveEntry() async {
    if (_recordedPath == null || _stage == _VoiceStage.saving) return;

    setState(() => _stage = _VoiceStage.saving);

    final caption = _captionController.text.trim();
    final entry = DailyEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      gratitudeItems: [caption.isNotEmpty ? caption : 'Voice gratitude note'],
      mood: _selectedMood,
      audioPath: _recordedPath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _entriesProvider.addEntry(entry);

    if (!mounted) return;

    if (success) {
      Haptics.success(context);
      Navigator.of(context).pop();
    } else {
      setState(() => _stage = _VoiceStage.recorded);
      _showError('Failed to save. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text('Voice Note', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildRecordArea(theme),
              const SizedBox(height: 32),
              if (_stage == _VoiceStage.recorded) _buildRecordedControls(theme),
              const Spacer(),
              if (_stage == _VoiceStage.recorded) _buildSaveArea(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordArea(ThemeData theme) {
    switch (_stage) {
      case _VoiceStage.idle:
        return Column(
          children: [
            _buildMicButton(theme, onTap: _startRecording, icon: Icons.mic, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Tap to record', style: theme.textTheme.bodyLarge),
          ],
        );

      case _VoiceStage.recording:
        return Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                return Transform.scale(scale: scale, child: child);
              },
              child: _buildMicButton(theme, onTap: _stopRecording, icon: Icons.stop, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_recordDuration),
              style: theme.textTheme.headlineMedium?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 4),
            Text('Recording — tap to stop', style: theme.textTheme.bodySmall),
          ],
        );

      case _VoiceStage.recorded:
      case _VoiceStage.saving:
        return Column(
          children: [
            _buildMicButton(
              theme,
              onTap: _stage == _VoiceStage.saving ? null : _togglePlayback,
              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${_formatDuration(_playbackPosition)} / ${_formatDuration(_playbackTotal)}',
              style: theme.textTheme.titleMedium?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
            ),
          ],
        );
    }
  }

  Widget _buildMicButton(
    ThemeData theme, {
    required VoidCallback? onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(56),
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, size: 44, color: color),
      ),
    );
  }

  Widget _buildRecordedControls(ThemeData theme) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: _stage == _VoiceStage.saving ? null : _reRecord,
          icon: const Icon(Icons.refresh),
          label: const Text('Re-record'),
        ),
        const SizedBox(height: 16),
        Text('How are you feeling?', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        MoodSelector(selectedMood: _selectedMood, onMoodSelected: (mood) => setState(() => _selectedMood = mood)),
        const SizedBox(height: 20),
        TextField(
          controller: _captionController,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Add a short caption (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveArea(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _stage == _VoiceStage.saving ? null : _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _stage == _VoiceStage.saving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
              )
            : const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
