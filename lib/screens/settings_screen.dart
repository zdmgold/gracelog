import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/providers/app_state_provider.dart';
import '../core/providers/entries_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/export_service.dart';
import '../widgets/bedtime_mode_toggle.dart';

/// Settings screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
  final EntriesProvider _entriesProvider = EntriesProvider();
  String _appVersion = '';
  bool _isExporting = false;

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'he', 'name': 'עברית'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    } catch (_) {
      if (mounted) setState(() => _appVersion = '1.0.0');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
        title: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(theme, 'Appearance'),
          _buildThemeTile(theme),
          ListenableBuilder(
            listenable: _appStateProvider,
            builder: (context, _) => BedtimeModeToggle(
              isEnabled: _appStateProvider.value.isBedtimeMode,
              onToggle: () => _appStateProvider.toggleBedtimeMode(),
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Security'),
          _buildBiometricTile(theme),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Notifications'),
          _buildReminderTile(theme),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Language'),
          _buildLanguageTile(theme),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Subscription'),
          _buildSubscriptionTile(theme),
          _buildRestoreTile(theme),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Data'),
          _buildExportTile(theme),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'About'),
          _buildLinkTile(
            theme,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'gracelog.pages.dev/privacy',
            onTap: () => _launchUrl('https://gracelog.pages.dev/privacy'),
          ),
          _buildLinkTile(
            theme,
            icon: Icons.help_outline,
            title: 'Support',
            subtitle: 'gracelog.pages.dev/support',
            onTap: () => _launchUrl('https://gracelog.pages.dev/support'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            title: Text('Version', style: theme.textTheme.bodyLarge),
            subtitle: Text(_appVersion, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildThemeTile(ThemeData theme) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        final mode = _themeProvider.value;
        return ListTile(
          leading: Icon(
            mode == ThemeMode.dark ? Icons.dark_mode : mode == ThemeMode.light ? Icons.light_mode : Icons.brightness_auto,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          title: Text('Theme', style: theme.textTheme.bodyLarge),
          subtitle: Text(
            mode == ThemeMode.dark ? 'Dark' : mode == ThemeMode.light ? 'Light' : 'System default',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          onTap: _showThemePicker,
        );
      },
    );
  }

  Widget _buildBiometricTile(ThemeData theme) {
    return ListenableBuilder(
      listenable: _appStateProvider,
      builder: (context, _) {
        return SwitchListTile(
          secondary: Icon(Icons.fingerprint, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          title: Text('Biometric Lock', style: theme.textTheme.bodyLarge),
          subtitle: Text('Require fingerprint or face ID to open the app', style: theme.textTheme.bodySmall),
          value: _appStateProvider.value.isBiometricEnabled,
          onChanged: (_) => _appStateProvider.toggleBiometric(),
          activeColor: theme.colorScheme.primary,
        );
      },
    );
  }

  // NEW: Daily Reminder tile — the gap you found. Shows the currently
  // scheduled time and lets you change it at any point after onboarding.
  Widget _buildReminderTile(ThemeData theme) {
    return ListenableBuilder(
      listenable: _appStateProvider,
      builder: (context, _) {
        final time = _appStateProvider.value.reminderTime;
        return ListTile(
          leading: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          title: Text('Daily Reminder', style: theme.textTheme.bodyLarge),
          subtitle: Text('Remind me at ${time.format(context)}', style: theme.textTheme.bodySmall),
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) {
              await _appStateProvider.setReminderTime(picked);
            }
          },
        );
      },
    );
  }

  Widget _buildLanguageTile(ThemeData theme) {
    return ListenableBuilder(
      listenable: _appStateProvider,
      builder: (context, _) {
        final currentCode = _appStateProvider.value.currentLocale.languageCode;
        final currentLang = _languages.firstWhere((l) => l['code'] == currentCode, orElse: () => _languages.first);
        return ListTile(
          leading: Icon(Icons.language, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          title: Text('Language', style: theme.textTheme.bodyLarge),
          subtitle: Text(currentLang['name']!, style: theme.textTheme.bodySmall),
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          onTap: _showLanguagePicker,
        );
      },
    );
  }

  Widget _buildSubscriptionTile(ThemeData theme) {
    return ListenableBuilder(
      listenable: _subscriptionProvider,
      builder: (context, _) {
        final isSubscribed = _subscriptionProvider.value;
        final accent = isSubscribed ? theme.colorScheme.secondary : theme.colorScheme.primary;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(isSubscribed ? Icons.check_circle : Icons.lock_open, color: accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isSubscribed ? 'Pro Active' : 'GraceLog Pro', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      isSubscribed ? 'Ad-free experience. Thank you for your support!' : r'Remove ads for $0.99/month',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!isSubscribed)
                ElevatedButton(
                  onPressed: () => _handleUpgrade(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestoreTile(ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.restore, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      title: Text('Restore Purchases', style: theme.textTheme.bodyLarge),
      subtitle: Text('Recover your Pro subscription on this device', style: theme.textTheme.bodySmall),
      onTap: () => _subscriptionProvider.restorePurchases(),
    );
  }

  Widget _buildExportTile(ThemeData theme) {
    return ListTile(
      leading: _isExporting
          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary))
          : Icon(Icons.download, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      title: Text('Export All Data', style: theme.textTheme.bodyLarge),
      subtitle: Text('Backup your entries as JSON', style: theme.textTheme.bodySmall),
      onTap: _isExporting ? null : _exportAllData,
    );
  }

  Widget _buildLinkTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Icon(Icons.open_in_new, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);
    await _entriesProvider.loadEntries();
    final entries = _entriesProvider.value.entries;
    if (!mounted) return;
    if (entries.isEmpty) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No entries to export yet.')));
      return;
    }
    await ExportService().exportToJson(entries);
    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _handleUpgrade() async {
    final sent = await _subscriptionProvider.purchaseSubscription();
    if (!mounted) return;
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscriptions aren't available in this build yet. Check back soon.")),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                _themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                _themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System default'),
              leading: const Icon(Icons.brightness_auto),
              onTap: () {
                _themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _languages.length,
          itemBuilder: (context, index) {
            final lang = _languages[index];
            return ListTile(
              title: Text(lang['name']!),
              onTap: () {
                _appStateProvider.setLocale(lang['code']!);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
