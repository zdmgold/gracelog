import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/mood_type.dart';
import '../core/models/daily_entry.dart';
import '../core/models/scripture_verse.dart';
import '../core/models/weekly_summary.dart';
import '../core/providers/app_state_provider.dart';
import '../core/providers/entries_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/scripture_engine.dart';
import '../core/utils/constants.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/theme.dart';
import '../widgets/entry_list_tile.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/scripture_card.dart';
import '../widgets/streak_flame.dart';
import '../widgets/weekly_blessing_card.dart';
import 'bedtime_reflection_screen.dart';
import 'daily_entry_screen.dart';
import 'scripture_detail_screen.dart';
import 'settings_screen.dart';
import 'weekly_review_screen.dart';

/// GraceLog home dashboard.
///
/// Displays: animated hero header, today's entry status, streak flame,
/// calendar heatmap, 7-day mood trend, recent entries list, weekly
/// blessing card, scripture of the day, and expandable quick-action FAB.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
  final ThemeProvider _themeProvider = ThemeProvider();

  ScriptureVerse? _dailyVerse;
  WeeklySummary? _weeklySummary;
  int _streak = 0;
  bool _isFabExpanded = false;

  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    _initialize();
  }

  Future<void> _initialize() async {
    await ScriptureEngine().initialize();
    await _entriesProvider.loadEntries();
    _refreshData();
  }

  void _refreshData() {
    if (!mounted) return;
    _loadDailyVerse();
    _loadWeeklySummary();
    _loadStreak();
  }

  void _loadDailyVerse() {
    final verse = ScriptureEngine().getRandomVerse();
    if (mounted) {
      setState(() => _dailyVerse = verse);
    }
  }

  Future<void> _loadWeeklySummary() async {
    final summary = await _entriesProvider.getWeeklySummary(DateTime.now());
    if (mounted) {
      setState(() => _weeklySummary = summary);
    }
  }

  Future<void> _loadStreak() async {
    final streak = await _entriesProvider.getStreak();
    if (mounted) {
      setState(() => _streak = streak);
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    // DELETED: provider disposals. Singletons live for app lifetime.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader(theme)),
            SliverToBoxAdapter(child: _buildTodayStatus(theme)),
            SliverToBoxAdapter(child: _buildStreakSection(theme)),
            SliverToBoxAdapter(child: _buildCalendarHeatmap(theme)),
            SliverToBoxAdapter(child: _buildMoodTrendSection(theme)),
            SliverToBoxAdapter(child: _buildRecentEntriesSection(theme)),
            // Weekly blessing ALWAYS renders — placeholder when null
            SliverToBoxAdapter(
              child: _buildWeeklyBlessingSection(theme),
            ),
            // Scripture ALWAYS renders — placeholder when null
            SliverToBoxAdapter(
              child: _buildScriptureSection(theme),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      floatingActionButton: _buildExpandableFab(theme),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER — Animated gradient with wordmark
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeader(ThemeData theme) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final t = _gradientController.value;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFD4A76A), const Color(0xFF8FBC8F), t)!,
                Color.lerp(const Color(0xFF8FBC8F), const Color(0xFFFFB300), (t * 2) % 1)!,
                Color.lerp(const Color(0xFFFFB300), const Color(0xFFD4A76A), (t * 3) % 1)!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GraceLog',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Bedtime navigation button
                      IconButton(
                        onPressed: _navigateToBedtime,
                        icon: Icon(
                          Icons.bedtime_outlined,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        tooltip: 'Bedtime Reflection',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _navigateToSettings,
                        icon: Icon(
                          Icons.settings_outlined,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        tooltip: 'Settings',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateTime.now().day} ${_monthName(DateTime.now().month)}, ${DateTime.now().year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TODAY STATUS — Entry completion indicator
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTodayStatus(ThemeData theme) {
    return ListenableBuilder(
      listenable: _entriesProvider,
      builder: (context, _) {
        final today = DateTime.now();
        final hasEntry = _entriesProvider.value.entries.any(
          (e) => DateFormatter.isSameDay(e.date, today),
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasEntry
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasEntry
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: theme.shadowLight,
            ),
            child: Row(
              children: [
                Icon(
                  hasEntry ? Icons.check_circle : Icons.circle_outlined,
                  color: hasEntry
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasEntry
                            ? "Today's gratitude is recorded"
                            : "You haven't journaled today",
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasEntry
                            ? 'Come back tomorrow to keep your streak alive.'
                            : 'Take a moment to reflect and give thanks.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STREAK SECTION — Flame + weekly review link
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStreakSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          StreakFlame(streakDays: _streak),
          const Spacer(),
          TextButton.icon(
            onPressed: _navigateToWeeklyReview,
            icon: Icon(Icons.calendar_view_week, size: 18, color: theme.colorScheme.primary),
            label: Text('Weekly Review', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CALENDAR HEATMAP — Mini 7×4 grid
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCalendarHeatmap(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _entriesProvider,
            builder: (context, _) {
              final entries = _entriesProvider.value.entries;
              return _CalendarHeatmapMini(
                entries: entries,
                onDayTap: (date) {
                  // TODO: Open entry detail for this date
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOOD TREND SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMoodTrendSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Trend (7 Days)',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _entriesProvider,
            builder: (context, _) {
              final now = DateTime.now();
              final weekStart = now.subtract(
                Duration(days: now.weekday % 7 + 6),
              );
              final weekEntries = _entriesProvider.value.entries
                  .where((e) => e.date.isAfter(weekStart))
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              return MoodTrendChart(entries: weekEntries);
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RECENT ENTRIES SECTION — Last 7 entries
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentEntriesSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Entries',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _entriesProvider,
            builder: (context, _) {
              final recent = _entriesProvider.value.entries
                  .take(7)
                  .toList();

              if (recent.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No entries yet. Start your gratitude journey today!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: recent.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EntryListTile(
                      entry: entry,
                      onTap: () => _navigateToEntry(verse: entry.scriptureReference != null
                          ? ScriptureVerse(
                              reference: entry.scriptureReference!,
                              text: entry.scriptureText ?? '',
                              mood: entry.mood.name,
                              book: entry.scriptureReference!.split(' ').first,
                              chapter: 1,
                              verseStart: 1,
                            )
                          : null),
                      onDelete: () => _entriesProvider.deleteEntry(entry.id),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WEEKLY BLESSING — Always renders, placeholder when null
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWeeklyBlessingSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: _weeklySummary != null
          ? WeeklyBlessingCard(summary: _weeklySummary!)
          : _buildPlaceholderCard(
              theme,
              icon: Icons.auto_awesome,
              title: 'Weekly Blessing',
              subtitle: 'Log entries this week to see your personalized insight.',
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SCRIPTURE SECTION — Always renders, placeholder when null
  // ═══════════════════════════════════════════════════════════════
  Widget _buildScriptureSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scripture of the Day',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _dailyVerse != null
              ? ScriptureCard(
                  verse: _dailyVerse!,
                  onUseVerse: () => _navigateToEntry(verse: _dailyVerse),
                  onTap: () => _navigateToScriptureDetail(_dailyVerse!),
                )
              : _buildPlaceholderCard(
                  theme,
                  icon: Icons.menu_book,
                  title: 'Daily Scripture',
                  subtitle: 'A verse will appear here to guide your reflection.',
                ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PLACEHOLDER CARD — Used when data is loading/null
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPlaceholderCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EXPANDABLE FAB — Quick actions
  // ═══════════════════════════════════════════════════════════════
  Widget _buildExpandableFab(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabAction(
            icon: Icons.mic,
            label: 'Voice Note',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFabExpanded = false);
              // TODO: Voice note entry
            },
          ),
          const SizedBox(height: 8),
          _buildFabAction(
            icon: Icons.photo_camera,
            label: 'Photo Memory',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFabExpanded = false);
              // TODO: Photo entry
            },
          ),
          const SizedBox(height: 8),
          _buildFabAction(
            icon: Icons.menu_book,
            label: 'Scripture Journal',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFabExpanded = false);
              _navigateToEntry();
            },
          ),
          const SizedBox(height: 8),
          _buildFabAction(
            icon: Icons.bedtime,
            label: 'Bedtime Reflection',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFabExpanded = false);
              _navigateToBedtime();
            },
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (_isFabExpanded) {
              _navigateToEntry();
            } else {
              setState(() => _isFabExpanded = true);
            }
          },
          icon: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0,
            duration: AppConstants.durationNormal,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
          label: Text(_isFabExpanded ? 'Close' : 'New Entry'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildFabAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: AppConstants.durationNormal,
      curve: AppConstants.easeOutExpo,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM BAR — Ad banner or nothing
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    return ListenableBuilder(
      listenable: _subscriptionProvider,
      builder: (context, _) {
        final isSubscribed = _subscriptionProvider.value;
        if (isSubscribed) return const SizedBox.shrink();

        return Container(
          height: 60,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Text(
              'Ad Banner Placeholder',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _navigateToEntry({ScriptureVerse? verse}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyEntryScreen(preselectedVerse: verse),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToWeeklyReview() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WeeklyReviewScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _navigateToBedtime() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BedtimeReflectionScreen()),
    ).then((_) => _refreshData());
  }

  void _navigateToScriptureDetail(ScriptureVerse verse) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScriptureDetailScreen(verse: verse),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// MINI CALENDAR HEATMAP — Inline widget for home dashboard
// ═════════════════════════════════════════════════════════════════
class _CalendarHeatmapMini extends StatelessWidget {
  const _CalendarHeatmapMini({
    required this.entries,
    this.onDayTap,
  });

  final List<DailyEntry> entries;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(28, (i) {
      return now.subtract(Duration(days: 27 - i));
    });

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((date) {
        final entry = entries.firstWhere(
          (e) => DateFormatter.isSameDay(e.date, date),
          orElse: () => DailyEntry(
            id: '',
            date: date,
            gratitudeItems: const [],
            mood: MoodType.peaceful,
            createdAt: date,
            updatedAt: date,
          ),
        );

        final hasEntry = entry.id.isNotEmpty;
        final intensity = hasEntry
            ? (entry.gratitudeItems.join(' ').length / 200).clamp(0.3, 1.0)
            : 0.0;

        return InkWell(
          onTap: hasEntry ? () => onDayTap?.call(date) : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hasEntry
                  ? theme.colorScheme.primary.withOpacity(intensity as double)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: hasEntry
                ? Center(
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: intensity > 0.6
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
