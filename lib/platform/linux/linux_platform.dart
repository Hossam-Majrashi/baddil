import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:baddil/core/constants/app_constants.dart';

class LinuxPlatform {
  static Future<void> initializeWindow() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(
        AppConstants.defaultDesktopMinWidth,
        AppConstants.defaultDesktopMinHeight,
      ),
      center: true,
      title: 'بدّل - Baddil',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static bool isFfmpegAvailable() {
    try {
      final res = Process.runSync('which', ['ffmpeg']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
