import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/app_state_provider.dart';
import 'core/providers/entries_provider.dart';
import 'core/providers/subscription_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/iap_service.dart';
import 'core/services/local_storage.dart';
import 'core/services/scripture_engine.dart';
import 'core/utils/constants.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/theme.dart';
import 'platform/admob_service.dart';
import 'screens/home_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.setup();
  runApp(const GraceLogApp());
}

/// GraceLog root widget.
///
/// Initializes all services in [initState], configures the
/// [MaterialApp] with 11 supported locales, theme/darkTheme from
/// [ThemeProvider], and [HomeDashboard] as the initial route.
///
/// AdMob banner visibility is wired to [SubscriptionProvider] via
/// the [shouldShowAds] callback injected during initialization.
class GraceLogApp extends StatefulWidget {
  const GraceLogApp({super.key});

  @override
  State<GraceLogApp> createState() => _GraceLogAppState();
}

class _GraceLogAppState extends State<GraceLogApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
  final EntriesProvider _entriesProvider = EntriesProvider();

  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Local storage (database)
      await LocalStorage().database;

      // 2. Scripture engine (load all 7 batches)
      await ScriptureEngine().initialize();

      // 3. In-app purchases
      await IAPService().initialize();

      // 4. AdMob with graceful degradation
      await AdMobService().initialize();

      // 5. Wire AdMob to subscription state
      AdMobService().shouldShowAds = () => !_subscriptionProvider.value;

      // 6. Load persisted entries
      await _entriesProvider.loadEntries();

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = 'Failed to initialize app. Please restart.';
        });
      }
    }
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    _subscriptionProvider.dispose();
    _appStateProvider.dispose();
    _entriesProvider.dispose();
    AdMobService().disposeBannerAd();
    IAPService().dispose();
    LocalStorage().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.accentPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading GraceLog...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textError,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeApp,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'GraceLog',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildLightTheme(),
          darkTheme: AppTheme.buildDarkTheme(),
          themeMode: _themeProvider.value,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('es'), // Spanish
            Locale('fr'), // French
            Locale('de'), // German
            Locale('pt'), // Portuguese
            Locale('ar'), // Arabic (RTL)
            Locale('hi'), // Hindi
            Locale('ja'), // Japanese
            Locale('ko'), // Korean
            Locale('zh'), // Chinese
            Locale('he'), // Hebrew (RTL)
          ],
          locale: _appStateProvider.value.currentLocale,
          home: const HomeDashboard(),
          builder: (context, child) {
            // Global error boundary
            ErrorWidget.builder = (details) {
              return Scaffold(
                backgroundColor: AppColors.bgPrimary,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.exception.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _initializeApp(),
                          child: const Text('Restart App'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            };
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
