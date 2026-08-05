import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/models/weekly_summary.dart';
import '../core/providers/entries_provider.dart';
import '../core/services/export_service.dart';
import '../core/utils/constants.dart';
import '../core/utils/date_formatter.dart';
import '../widgets/accountability_share_sheet.dart';
import '../widgets/entry_list_tile.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/weekly_blessing_card.dart';
import 'scripture_detail_screen.dart';

/// Weekly review screen.
///
/// Displays: scrollable list of the last 7 days' entries, mood trend
/// chart, category breakdown bar counts, weekly blessing card, and
/// export buttons (JSON, PNG, PDF).
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
    _entriesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Weekly Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showShareSheet,
            icon: Icon(Icons.share, color: AppColors.accentPrimary),
            tooltip: 'Share weekly summary',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                MoodTrendChart(
                  entries: weekEntries.reversed.toList(),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _buildCategoryBreakdown(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week\'s Entries',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${weekEntries.length} entries',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
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
                    Icon(
                      Icons.edit_note,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No entries this week yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
            child: _buildExportButtons(weekEntries),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_summary == null || _summary!.moodCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = _summary!.moodCounts.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._summary!.moodCounts.entries.map((entry) {
          final pct = (entry.value / total * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  entry.key.icon,
                  size: 16,
                  color: entry.key.colorToken,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key.name[0].toUpperCase() +
                      entry.key.name.substring(1),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: AppColors.bgTertiary,
                      valueColor: AlwaysStoppedAnimation(
                        entry.key.colorToken,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExportButtons(List<DailyEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                icon: Icons.code,
                label: 'JSON',
                onTap: () => ExportService().exportToJson(entries),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                icon: Icons.image,
                label: 'Image',
                onTap: () {
                  // Image export requires a specific entry + verse
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Select an entry to export as image'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
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

  Widget _buildExportButton({
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
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentPrimary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
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
        MaterialPageRoute(
          builder: (_) => ScriptureDetailScreen(verse: verse),
        ),
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
