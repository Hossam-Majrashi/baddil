import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baddil/core/constants/app_constants.dart';

class SettingsController extends ChangeNotifier {
  final SharedPreferences _prefs;

  Locale _locale;
  ThemeMode _themeMode;
  bool _onboardingDone;

  SettingsController(this._prefs)
      : _locale = _loadInitialLocale(_prefs),
        _themeMode = _loadInitialThemeMode(_prefs),
        _onboardingDone = _prefs.getBool(AppConstants.prefOnboardingDoneKey) ?? false;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isOnboardingDone => _onboardingDone;

  static Locale _loadInitialLocale(SharedPreferences prefs) {
    final savedCode = prefs.getString(AppConstants.prefLanguageKey);
    if (savedCode != null) {
      return Locale(savedCode);
    }
    // Check system locale
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  static ThemeMode _loadInitialThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(AppConstants.prefThemeModeKey);
    if (savedMode == 'dark') return ThemeMode.dark;
    if (savedMode == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default according to visual reference design
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    await _prefs.setString(AppConstants.prefLanguageKey, newLocale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode newMode) async {
    if (_themeMode == newMode) return;
    _themeMode = newMode;
    final modeString = switch (newMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.prefThemeModeKey, modeString);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    await _prefs.setBool(AppConstants.prefOnboardingDoneKey, true);
    notifyListeners();
  }
}
