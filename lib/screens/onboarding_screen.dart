import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers/theme_provider.dart';
import '../core/utils/constants.dart';
import '../core/utils/haptics.dart';
import '../platform/notification_service.dart';
import 'home_dashboard.dart';

/// 3-page parallax onboarding flow, shown once on first launch.
///
/// Page 1: Welcome. Page 2: How It Works. Page 3: Get Started —
/// collects an optional name, a daily reminder time, and a theme
/// preference, then awards the "First Step" badge and enters the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// SharedPreferences flag checked at app startup.
  static const String prefsKey = 'hasSeenOnboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final ThemeProvider _themeProvider = ThemeProvider();

  double _page = 0;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    Haptics.tap(context);
    _pageController.nextPage(
      duration: AppConstants.durationNormal,
      curve: AppConstants.easeOutExpo,
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _completeOnboarding() async {
    Haptics.success(context);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.prefsKey, true);
    await prefs.setBool('badge_first_step', true);
    if (_nameController.text.trim().isNotEmpty) {
      await prefs.setString('user_first_name', _nameController.text.trim());
    }

    await NotificationService().initialize();
    await NotificationService().scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeDashboard()),
    );
  }

  double _parallaxOffset(int pageIndex, double speed) {
    return (_page - pageIndex) * 100 * speed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            children: [
              _buildPage(
                theme,
                index: 0,
                icon: Icons.favorite,
                title: 'Welcome to GraceLog',
                body: "A quiet place to record what you're thankful for, "
                    'every single day — 100% offline, entirely yours.',
                buttonLabel: 'Next',
                onButtonTap: _nextPage,
              ),
              _buildPage(
                theme,
                index: 1,
                icon: Icons.auto_awesome,
                title: 'How It Works',
                body: 'Each day, note three things you\'re grateful for. '
                    'GraceLog pairs your mood with a scripture that speaks '
                    'to it, and tracks your streak along the way.',
                buttonLabel: 'Next',
                onButtonTap: _nextPage,
              ),
              _buildPage(
                theme,
                index: 2,
                icon: Icons.rocket_launch,
                title: "Let's Get Started",
                buttonLabel: 'Begin My Journey',
                onButtonTap: _completeOnboarding,
                extraContent: _buildGetStartedForm(theme),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: AppConstants.durationFast,
                opacity: _page < 1.5 ? 1 : 0,
                child: TextButton(
                  onPressed: _page < 1.5 ? _completeOnboarding : null,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _buildPageIndicator(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedForm(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Your first name (optional)'),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
            title: const Text('Daily reminder'),
            subtitle: Text(_reminderTime.format(context)),
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            onTap: _pickReminderTime,
          ),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _themeProvider,
          builder: (context, _) => SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
            ],
            selected: {_themeProvider.value},
            onSelectionChanged: (selection) {
              Haptics.select(context);
              _themeProvider.setThemeMode(selection.first);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPage(
    ThemeData theme, {
    required int index,
    required IconData icon,
    required String title,
    String? body,
    required String buttonLabel,
    required VoidCallback onButtonTap,
    Widget? extraContent,
  }) {
    return Stack(
      children: [
        // Background gradient — 0.5x parallax speed
        Transform.translate(
          offset: Offset(_parallaxOffset(index, 0.5), 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.08),
                ],
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_parallaxOffset(index, 0.5), 0),
          child: Align(
            alignment: const Alignment(0, -0.45),
            child: Icon(icon, size: 120, color: theme.colorScheme.primary.withOpacity(0.12)),
          ),
        ),
        // Text content — moves at page speed (1.0x, effectively static per-page)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                if (body != null) ...[
                  const SizedBox(height: 16),
                  Text(body, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                ],
                if (extraContent != null) ...[
                  const SizedBox(height: 24),
                  extraContent,
                ],
                const SizedBox(height: 48),
                // Button — 1.2x parallax speed
                Transform.translate(
                  offset: Offset(_parallaxOffset(index, 1.2), 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(buttonLabel, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = _page.round() == i;
        return AnimatedContainer(
          duration: AppConstants.durationFast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
