import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/models/daily_entry.dart';
import '../core/models/scripture_verse.dart';
import '../core/providers/entries_provider.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/haptics.dart';
import 'scripture_detail_screen.dart';

/// Read-only detail view for a saved [DailyEntry], regardless of how
/// it was created (Scripture Journal, Bedtime Reflection, Voice Note,
/// or Photo Memory). Shows whichever of mood, photos, audio,
/// gratitude text, category, and scripture the entry actually has.
class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entry});

  final DailyEntry entry;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  AudioPlayer? _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry.hasAudio) {
      _player = AudioPlayer();
      _player!.setFilePath(widget.entry.audioPath!).then((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });
      _player!.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _player!.seek(Duration.zero);
          _player!.pause();
        }
      });
      _player!.positionStream.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
      });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    // EntriesProvider intentionally not disposed — instance-per-screen
    // convention established in Batch 1.
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_player == null) return;
    if (_isPlaying) {
      await _player!.pause();
    } else {
      await _player!.play();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _confirmDelete() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This entry will be permanently removed. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || _isDeleting) return;

    setState(() => _isDeleting = true);
    await _entriesProvider.deleteEntry(widget.entry.id);
    if (!mounted) return;
    Haptics.success(context);
    Navigator.of(context).pop(true);
  }

  void _openScripture() {
    final entry = widget.entry;
    if (entry.scriptureReference == null || entry.scriptureText == null) return;
    final verse = ScriptureVerse(
      reference: entry.scriptureReference!,
      text: entry.scriptureText!,
      mood: entry.mood.name,
      book: entry.scriptureReference!.split(' ').first,
      chapter: 1,
      verseStart: 1,
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScriptureDetailScreen(verse: verse)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
        title: Text(DateFormatter.formatDate(entry.date, pattern: 'MMMM d, y'), style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _confirmDelete,
            icon: _isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.error),
                  )
                : Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete entry',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodChip(theme, entry),
            const SizedBox(height: 20),
            if (entry.hasPhotos) ...[
              _buildPhotos(entry),
              const SizedBox(height: 20),
            ],
            if (entry.hasAudio) ...[
              _buildAudioPlayer(theme),
              const SizedBox(height: 20),
            ],
            Text('Gratitude', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...entry.gratitudeItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
                  ],
                ),
              ),
            ),
            if (entry.category != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(entry.category!, style: theme.textTheme.labelMedium),
              ),
            ],
            if (entry.scriptureReference != null && entry.scriptureText != null) ...[
              const SizedBox(height: 24),
              Text('Scripture', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              InkWell(
                onTap: _openScripture,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${entry.scriptureText}"',
                        style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('— ${entry.scriptureReference}', style: theme.textTheme.labelMedium)),
                          Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip(ThemeData theme, DailyEntry entry) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: entry.mood.colorToken.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(entry.mood.icon, color: entry.mood.colorToken, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          entry.mood.name[0].toUpperCase() + entry.mood.name.substring(1),
          style: theme.textTheme.titleMedium?.copyWith(color: entry.mood.colorToken, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPhotos(DailyEntry entry) {
    if (entry.photoPaths.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(entry.photoPaths.first), width: double.infinity, height: 280, fit: BoxFit.cover),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entry.photoPaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(entry.photoPaths[index]), width: 200, height: 200, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildAudioPlayer(ThemeData theme) {
    final progress = _duration.inMilliseconds > 0 ? _position.inMilliseconds / _duration.inMilliseconds : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _togglePlayback,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
              child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
