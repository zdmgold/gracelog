import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/providers/app_state_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/export_service.dart';
import '../core/utils/constants.dart';
import '../widgets/bedtime_mode_toggle.dart';

/// Settings screen.
///
/// Sections: theme toggle, bedtime mode, biometric lock, language
/// selector (11 languages), subscription status card, restore
/// purchases, export all data, privacy policy link, support link,
/// app version.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
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
      if (mounted) {
        setState(() => _appVersion = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      setState(() => _appVersion = '1.0.0');
    }
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    _subscriptionProvider.dispose();
    _appStateProvider.dispose();
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
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeTile(),
          ListenableBuilder(
            listenable: _appStateProvider,
            builder: (context, _) => BedtimeModeToggle(
              isEnabled: _appStateProvider.value.isBedtimeMode,
              onToggle: () => _appStateProvider.toggleBedtimeMode(),
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Security'),
          _buildBiometricTile(),
          const Divider(height: 32),
          _buildSectionHeader('Language'),
          _buildLanguageTile(),
          const Divider(height: 32),
          _buildSectionHeader('Subscription'),
          _buildSubscriptionTile(),
          _buildRestoreTile(),
          const Divider(height: 32),
          _buildSectionHeader('Data'),
          _buildExportTile(),
          const Divider(height: 32),
          _buildSectionHeader('About'),
          _buildLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'gracelog.pages.dev/privacy',
            onTap: () {}, // Would launch URL via url_launcher
          ),
          _buildLinkTile(
            icon: Icons.help_outline,
            title: 'Support',
            subtitle: 'gracelog.pages.dev/support',
            onTap: () {}, // Would launch URL via url_launcher
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
            title: Text(
              'Version',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              _appVersion,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile() {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        final mode = _themeProvider.value;
        return ListTile(
          leading: Icon(
            mode == ThemeMode.dark
                ? Icons.dark_mode
                : mode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: AppColors.textSecondary,
          ),
          title: Text(
            'Theme',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            mode == ThemeMode.dark
                ? 'Dark'
                : mode == ThemeMode.light
                    ? 'Light'
                    : 'System default',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: _showThemePicker,
        );
      },
    );
  }

  Widget _buildBiometricTile() {
    return ListenableBuilder(
      listenable: _appStateProvider,
      builder: (context, _) {
        return SwitchListTile(
          secondary: Icon(
            Icons.fingerprint,
            color: AppColors.textSecondary,
          ),
          title: Text(
            'Biometric Lock',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            'Require fingerprint or face ID to open the app',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          value: _appStateProvider.value.isBiometricEnabled,
          onChanged: (_) => _appStateProvider.toggleBiometric(),
          activeColor: AppColors.accentPrimary,
        );
      },
    );
  }

  Widget _buildLanguageTile() {
    return ListenableBuilder(
      listenable: _appStateProvider,
      builder: (context, _) {
        final currentCode = _appStateProvider.value.currentLocale.languageCode;
        final currentLang = _languages.firstWhere(
          (l) => l['code'] == currentCode,
          orElse: () => _languages.first,
        );
        return ListTile(
          leading: Icon(Icons.language, color: AppColors.textSecondary),
          title: Text(
            'Language',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            currentLang['name']!,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          onTap: _showLanguagePicker,
        );
      },
    );
  }

  Widget _buildSubscriptionTile() {
    return ListenableBuilder(
      listenable: _subscriptionProvider,
      builder: (context, _) {
        final isSubscribed = _subscriptionProvider.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSubscribed
                ? AppColors.accentSuccess.withOpacity(0.1)
                : AppColors.accentPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSubscribed
                  ? AppColors.accentSuccess.withOpacity(0.3)
                  : AppColors.accentPrimary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSubscribed ? Icons.check_circle : Icons.lock_open,
                color: isSubscribed
                    ? AppColors.accentSuccess
                    : AppColors.accentPrimary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSubscribed ? 'Pro Active' : 'GraceLog Pro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSubscribed
                          ? 'Ad-free experience. Thank you for your support!'
                          : r'Remove ads for $0.99/month',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSubscribed)
                ElevatedButton(
                  onPressed: () => _subscriptionProvider.purchaseSubscription(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestoreTile() {
    return ListTile(
      leading: Icon(Icons.restore, color: AppColors.textSecondary),
      title: Text(
        'Restore Purchases',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        'Recover your Pro subscription on this device',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      onTap: () => _subscriptionProvider.restorePurchases(),
    );
  }

  Widget _buildExportTile() {
    return ListTile(
      leading: _isExporting
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentPrimary,
              ),
            )
          : Icon(Icons.download, color: AppColors.textSecondary),
      title: Text(
        'Export All Data',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        'Backup your entries as JSON',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      onTap: _isExporting ? null : _exportAllData,
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);
    // In a real implementation, this would fetch all entries from
    // the EntriesProvider and pass them to ExportService.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export feature requires entries provider integration')),
      );
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
