import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';
import 'package:baddil/main.dart';

void main() {
  testWidgets('BaddilApp initial launch test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsController = SettingsController(prefs);
    final homeController = HomeController();

    await tester.pumpWidget(
      BaddilApp(
        settingsController: settingsController,
        homeController: homeController,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Onboarding / App branding renders cleanly without errors
    expect(find.byType(BaddilApp), findsOneWidget);
  });
}
