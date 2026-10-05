import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gracelog/core/providers/app_state_provider.dart';
import 'package:gracelog/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('shared providers', () {
    test('ThemeProvider is one shared instance', () {
      expect(identical(ThemeProvider(), ThemeProvider()), isTrue);
    });

    test('AppStateProvider is one shared instance', () {
      expect(identical(AppStateProvider(), AppStateProvider()), isTrue);
    });

    test('a theme change on one handle is seen by every other handle', () async {
      final a = ThemeProvider();
      final b = ThemeProvider();
      await a.setThemeMode(ThemeMode.dark);
      expect(b.value, ThemeMode.dark);
    });

    test('a name change on one handle is seen by every other handle', () async {
      final a = AppStateProvider();
      final b = AppStateProvider();
      await a.setUserName('  Grace ');
      expect(b.value.userName, 'Grace');
    });
  });
}
