import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/models/scripture_verse.dart';
import '../core/models/weekly_summary.dart';
import '../core/providers/app_state_provider.dart';
import '../core/providers/entries_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/scripture_engine.dart';
import '../core/utils/constants.dart';
import '../core/utils/date_formatter.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/scripture_card.dart';
import '../widgets/streak_flame.dart';
import '../widgets/weekly_blessing_card.dart';
import 'daily_entry_screen.dart';
import 'scripture_detail_screen.dart';
import 'settings_screen.dart';
import 'weekly_review_screen.dart';

/// GraceLog home dashboard.
///
/// Displays: greeting by time of day, today's entry status, streak
/// flame, 7-day mood trend chart, weekly blessing card, scripture of
/// the day, and a banner ad at bottom (hidden if subscribed).
///
/// All provider listens use [ListenableBuilder] per blueprint Section 15.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
  final ThemeProvider _themeProvider = ThemeProvider();

  ScriptureVerse? _dailyVerse;
  WeeklySummary? _weeklySummary;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
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
    _entriesProvider.dispose();
    _subscriptionProvider.dispose();
    _appStateProvider.dispose();
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildTodayStatus()),
            SliverToBoxAdapter(child: _buildStreakSection()),
            SliverToBoxAdapter(child: _buildMoodTrendSection()),
            if (_weeklySummary != null)
              SliverToBoxAdapter(
                child: _buildWeeklyBlessingSection(),
              ),
            if (_dailyVerse != null)
              SliverToBoxAdapter(
                child: _buildScriptureSection(),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEntry,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'GraceLog',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _navigateToSettings,
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Settings',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus() {
    return ListenableBuilder(
      listenable: _entriesProvider,
      builder: (context, _) {
        final today = DateTime.now();
        final hasEntry = _entriesProvider.value.entries.any(
          (e) => DateFormatter.isSameDay(e.date, today),
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasEntry
                  ? AppColors.accentSuccess.withOpacity(0.1)
                  : AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasEntry
                    ? AppColors.accentSuccess.withOpacity(0.3)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasEntry ? Icons.check_circle : Icons.circle_outlined,
                  color: hasEntry
                      ? AppColors.accentSuccess
                      : AppColors.textTertiary,
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasEntry
                            ? 'Come back tomorrow to keep your streak alive.'
                            : 'Take a moment to reflect and give thanks.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
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

  Widget _buildStreakSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          StreakFlame(streakDays: _streak),
          const Spacer(),
          TextButton.icon(
            onPressed: _navigateToWeeklyReview,
            icon: const Icon(Icons.calendar_view_week, size: 18),
            label: const Text('Weekly Review'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Trend (7 Days)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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

  Widget _buildWeeklyBlessingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: WeeklyBlessingCard(summary: _weeklySummary!),
    );
  }

  Widget _buildScriptureSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scripture of the Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ScriptureCard(
            verse: _dailyVerse!,
            onUseVerse: () => _navigateToEntry(verse: _dailyVerse),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return ListenableBuilder(
      listenable: _subscriptionProvider,
      builder: (context, _) {
        final isSubscribed = _subscriptionProvider.value;
        if (isSubscribed) return const SizedBox.shrink();

        // AdMob banner placeholder --- actual BannerAd widget injected
        // by the screen that hosts this dashboard.
        return Container(
          height: 60,
          color: AppColors.bgSecondary,
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
}
