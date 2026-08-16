import 'package:flutter/material.dart';

import '../core/models/sound_track.dart';
import '../core/services/sleep_sounds_service.dart';
import '../core/utils/haptics.dart';
import '../core/utils/theme.dart';

/// Sleep Sounds — bundled ambient/instrumental tracks with continuous
/// looping and an optional sleep timer, for meditation or overnight
/// listening. Playback survives navigation and continues in the
/// background with lock-screen controls (see SleepSoundsService).
class SleepSoundsScreen extends StatefulWidget {
  const SleepSoundsScreen({super.key});

  @override
  State<SleepSoundsScreen> createState() => _SleepSoundsScreenState();
}

class _SleepSoundsScreenState extends State<SleepSoundsScreen> {
  final SleepSoundsService _service = SleepSoundsService();

  static const List<int?> _timerOptions = [null, 15, 30, 60, 120];

  String _timerLabel(int? minutes) {
    if (minutes == null) return 'All Night';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    return '$hours hr${hours > 1 ? 's' : ''}';
  }

  String _formatRemaining(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
        title: Text('Sleep Sounds', style: theme.textTheme.titleLarge),
      ),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, _) {
          final state = _service.value;
          return Column(
            children: [
              _buildNowPlayingBar(theme, state),
              _buildControlsPanel(theme, state),
              const Divider(height: 1),
              Expanded(child: _buildTrackList(theme, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingBar(ThemeData theme, SleepSoundsState state) {
    if (state.currentTrack == null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Pick a track below to begin.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: theme.shadowMedium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Haptics.tap(context);
                  _service.togglePlayPause();
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                  child: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.currentTrack!.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      state.remainingSeconds != null
                          ? 'Stops in ${_formatRemaining(state.remainingSeconds!)}'
                          : 'Looping — all night',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Haptics.tap(context);
                  _service.stop();
                },
                icon: Icon(Icons.stop_circle_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                tooltip: 'Stop',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(ThemeData theme, SleepSoundsState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text('Loop', style: theme.textTheme.bodyMedium),
              const Spacer(),
              Switch(
                value: state.isLooping,
                onChanged: (value) {
                  Haptics.select(context);
                  _service.setLooping(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Sleep Timer', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timerOptions.map((minutes) {
              final isSelected = state.sleepTimerMinutes == minutes;
              return ChoiceChip(
                label: Text(_timerLabel(minutes)),
                selected: isSelected,
                onSelected: (_) {
                  Haptics.select(context);
                  _service.setSleepTimer(minutes);
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3)),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList(ThemeData theme, SleepSoundsState state) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: SoundLibrary.tracks.length,
      itemBuilder: (context, index) {
        final track = SoundLibrary.tracks[index];
        final isCurrent = state.currentTrack?.id == track.id;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCurrent && state.isPlaying ? Icons.graphic_eq : Icons.music_note,
              color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ),
          title: Text(
            track.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isCurrent ? theme.colorScheme.primary : null,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          onTap: () {
            Haptics.tap(context);
            if (isCurrent) {
              _service.togglePlayPause();
            } else {
              _service.play(track);
            }
          },
        );
      },
    );
  }
}
