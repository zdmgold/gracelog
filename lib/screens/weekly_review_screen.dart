import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/models/scripture_verse.dart';
import '../core/models/weekly_summary.dart';
import '../core/providers/entries_provider.dart';
import '../core/services/export_service.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/theme.dart';
import '../widgets/accountability_share_sheet.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/entry_list_tile.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/weekly_blessing_card.dart';
import 'scripture_detail_screen.dart';

/// Weekly review screen.
///
/// Displays: weekly blessing card, 12-week journey heatmap, scripture
/// highlight, mood trend chart, category breakdown, scrollable list
/// of the week's entries, and export buttons (JSON, image, journal text).
class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  WeeklySummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _entriesProvider.loadEntries();
    final summary = await _entriesProvider.getWeeklySummary(DateTime.now());
    if (mounted) {
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Provider intentionally not disposed — instance-per-screen
    // convention established in Batch 1.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Weekly Review', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: _showShareSheet,
            icon: Icon(Icons.share, color: theme.colorScheme.primary),
            tooltip: 'Share weekly summary',
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7 + 6));
    final weekEntries = _entriesProvider.value.entries
        .where((e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return CustomScrollView(
      slivers: [
        if (_summary != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: WeeklyBlessingCard(summary: _summary!),
            ),
          ),
        SliverToBoxAdapter(
          child: _buildJourneySection(theme),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _buildScriptureHighlight(theme, weekEntries),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood Trend', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                MoodTrendChart(entries: weekEntries.reversed.toList()),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _buildCategoryBreakdown(theme),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("This Week's Entries", style: theme.textTheme.titleLarge),
                Text('${weekEntries.length} entries', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        if (weekEntries.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.edit_note, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No entries this week yet.', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = weekEntries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EntryListTile(
                    entry: entry,
                    onTap: () => _navigateToDetail(entry),
                    onDelete: () => _deleteEntry(entry.id),
                  ),
                );
              },
              childCount: weekEntries.length,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildExportButtons(theme, weekEntries),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Journey', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Last 12 weeks', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _entriesProvider,
            builder: (context, _) {
              return CalendarHeatmap(
                entries: _entriesProvider.value.entries,
                weeks: 12,
                onDayTap: (date) {
                  DailyEntry? match;
                  for (final e in _entriesProvider.value.entries) {
                    if (DateFormatter.isSameDay(e.date, date)) {
                      match = e;
                      break;
                    }
                  }
                  if (match != null) _navigateToDetail(match);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScriptureHighlight(ThemeData theme, List<DailyEntry> weekEntries) {
    DailyEntry? withVerse;
    for (final e in weekEntries) {
      if (e.scriptureReference != null && e.scriptureText != null) {
        withVerse = e;
        break;
      }
    }
    if (withVerse == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text('This Week\'s Scripture', style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${withVerse.scriptureText}"',
                style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text('— ${withVerse.scriptureReference}', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme) {
    if (_summary == null || _summary!.moodCounts.isEmpty) return const SizedBox.shrink();

    final total = _summary!.moodCounts.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood Breakdown', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ..._summary!.moodCounts.entries.map((entry) {
          final pct = (entry.value / total * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(entry.key.icon, size: 16, color: entry.key.colorToken),
                const SizedBox(width: 8),
                Text(
                  entry.key.name[0].toUpperCase() + entry.key.name.substring(1),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(entry.key.colorToken),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$pct%', style: theme.textTheme.labelMedium),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExportButtons(ThemeData theme, List<DailyEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                theme,
                icon: Icons.code,
                label: 'JSON',
                onTap: () => ExportService().exportToJson(entries),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                theme,
                icon: Icons.image,
                label: 'Image',
                onTap: () => _exportImage(entries),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                theme,
                icon: Icons.description,
                label: 'Journal',
                onTap: () => ExportService().exportToPdf(entries),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportImage(List<DailyEntry> entries) async {
    DailyEntry? withVerse;
    for (final e in entries) {
      if (e.scriptureReference != null && e.scriptureText != null) {
        withVerse = e;
        break;
      }
    }

    if (withVerse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entry with scripture found this week yet.')),
      );
      return;
    }

    final verse = ScriptureVerse(
      reference: withVerse.scriptureReference!,
      text: withVerse.scriptureText!,
      mood: withVerse.mood.name,
      book: withVerse.scriptureReference!.split(' ').first,
      chapter: 1,
      verseStart: 1,
    );

    await ExportService().exportToImage(withVerse, verse);
  }

  Widget _buildExportButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(DailyEntry entry) {
    if (entry.scriptureReference != null && entry.scriptureText != null) {
      final verse = ScriptureVerse(
        reference: entry.scriptureReference!,
        text: entry.scriptureText!,
        mood: entry.mood.name,
        book: entry.scriptureReference!.split(' ').first,
        chapter: 1,
        verseStart: 1,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ScriptureDetailScreen(verse: verse)),
      );
    }
  }

  Future<void> _deleteEntry(String id) async {
    await _entriesProvider.deleteEntry(id);
    await _loadData();
  }

  void _showShareSheet() {
    if (_summary == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AccountabilityShareSheet(summary: _summary!),
    );
  }
}
