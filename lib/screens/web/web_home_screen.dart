import 'package:flutter/material.dart';
import 'package:baddil/core/constants/app_constants.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/features/settings/screens/settings_screen.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';
import 'package:baddil/shared/widgets/app_header.dart';
import 'package:baddil/shared/widgets/options_card.dart';
import 'package:baddil/shared/widgets/queue_card.dart';
import 'package:baddil/shared/widgets/upload_drop_zone.dart';

class WebHomeScreen extends StatelessWidget {
  final HomeController homeController;
  final SettingsController settingsController;

  const WebHomeScreen({
    super.key,
    required this.homeController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: homeController,
          builder: (context, _) {
            return Column(
              children: [
                AppHeader(
                  onSettingsPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          settingsController: settingsController,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: constraints.maxWidth > 750
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left column: Options panel
                                      SizedBox(
                                        width: 320,
                                        child: SingleChildScrollView(
                                          child: OptionsCard(
                                            controller: homeController,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Right column: Drop zone & Queue
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              UploadDropZone(
                                                controller: homeController,
                                              ),
                                              const SizedBox(height: 20),
                                              QueueCard(
                                                controller: homeController,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        UploadDropZone(controller: homeController),
                                        const SizedBox(height: 16),
                                        QueueCard(controller: homeController),
                                        const SizedBox(height: 16),
                                        OptionsCard(controller: homeController),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
