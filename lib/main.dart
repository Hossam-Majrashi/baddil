import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/core/theme/app_theme.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/features/onboarding/screens/onboarding_screen.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';
import 'package:baddil/platform/linux/linux_platform.dart';
import 'package:baddil/platform/macos/macos_platform.dart';
import 'package:baddil/platform/windows/windows_platform.dart';
import 'package:baddil/screens/desktop/desktop_home_screen.dart';
import 'package:baddil/screens/mobile/mobile_home_screen.dart';
import 'package:baddil/screens/web/web_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux) {
      await LinuxPlatform.initializeWindow();
    } else if (Platform.isWindows) {
      await WindowsPlatform.initializeWindow();
    } else if (Platform.isMacOS) {
      await MacosPlatform.initializeWindow();
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final settingsController = SettingsController(prefs);
  final homeController = HomeController();

  runApp(
    BaddilApp(
      settingsController: settingsController,
      homeController: homeController,
    ),
  );
}

class BaddilApp extends StatelessWidget {
  final SettingsController settingsController;
  final HomeController homeController;

  const BaddilApp({
    super.key,
    required this.settingsController,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'بدّل - Baddil',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _buildHomeScreen(context),
        );
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    if (!settingsController.isOnboardingDone) {
      return OnboardingScreen(
        settingsController: settingsController,
        onFinish: () {},
      );
    }

    if (kIsWeb) {
      return WebHomeScreen(
        homeController: homeController,
        settingsController: settingsController,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return MobileHomeScreen(
        homeController: homeController,
        settingsController: settingsController,
      );
    } else {
      return DesktopHomeScreen(
        homeController: homeController,
        settingsController: settingsController,
      );
    }
  }
}
