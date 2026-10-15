import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/features/settings/screens/settings_screen.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';
import 'package:baddil/shared/widgets/app_header.dart';
import 'package:baddil/shared/widgets/options_card.dart';
import 'package:baddil/shared/widgets/queue_card.dart';
import 'package:baddil/shared/widgets/upload_drop_zone.dart';

class MobileHomeScreen extends StatelessWidget {
  final HomeController homeController;
  final SettingsController settingsController;

  const MobileHomeScreen({
    super.key,
    required this.homeController,
    required this.settingsController,
  });

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: OptionsCard(
                controller: homeController,
                isBottomSheet: true,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: homeController,
          builder: (context, _) {
            final isProcessing = homeController.isProcessing;

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        UploadDropZone(
                          controller: homeController,
                          isMobile: true,
                        ),
                        const SizedBox(height: 16),
                        QueueCard(
                          controller: homeController,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Mobile bottom action bar (matches design/Mobile.png)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: theme.colorScheme.outline, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Start Processing button (Teal) with progress state
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isProcessing
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            foregroundColor: isProcessing
                                ? theme.colorScheme.onError
                                : theme.colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (isProcessing) {
                              homeController.cancelProcessing();
                            } else {
                              homeController.startProcessing();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isProcessing) ...[
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onError,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                isProcessing
                                    ? l10n.cancelProcessing
                                    : l10n.startProcessing,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Options button (Dark button opening bottom sheet)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(color: theme.colorScheme.outline, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => _showOptionsBottomSheet(context),
                          child: Text(
                            l10n.optionsTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
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
