import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baddil/core/constants/developer_info.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController;

  const SettingsScreen({
    super.key,
    required this.settingsController,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.launchUrlError)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.launchUrlError)),
        );
      }
    }
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Language Selection
                  _buildSectionHeader(context, l10n.language),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildSelectionRow(
                          context,
                          title: l10n.languageArabic,
                          isSelected: settingsController.locale.languageCode == 'ar',
                          onTap: () => settingsController.setLocale(const Locale('ar')),
                        ),
                        Divider(color: theme.colorScheme.outline, height: 1),
                        _buildSelectionRow(
                          context,
                          title: l10n.languageEnglish,
                          isSelected: settingsController.locale.languageCode == 'en',
                          onTap: () => settingsController.setLocale(const Locale('en')),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Theme Selection
                  _buildSectionHeader(context, l10n.theme),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildSelectionRow(
                          context,
                          title: l10n.themeDark,
                          isSelected: settingsController.themeMode == ThemeMode.dark,
                          onTap: () => settingsController.setThemeMode(ThemeMode.dark),
                        ),
                        Divider(color: theme.colorScheme.outline, height: 1),
                        _buildSelectionRow(
                          context,
                          title: l10n.themeLight,
                          isSelected: settingsController.themeMode == ThemeMode.light,
                          onTap: () => settingsController.setThemeMode(ThemeMode.light),
                        ),
                        Divider(color: theme.colorScheme.outline, height: 1),
                        _buildSelectionRow(
                          context,
                          title: l10n.themeSystem,
                          isSelected: settingsController.themeMode == ThemeMode.system,
                          onTap: () => settingsController.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Privacy & Security (100% Offline)
                  _buildSectionHeader(context, l10n.privacyAndSecurity),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline, width: 1),
                    ),
                    child: Text(
                      l10n.privacyDescription,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Disclaimer & Limits
                  _buildSectionHeader(context, l10n.disclaimerTitle),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline, width: 1),
                    ),
                    child: Text(
                      l10n.disclaimerText,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // DEVELOPER SECTION (MUST BE LAST ON ALL PLATFORMS AS PER SECTION 8)
                  _buildSectionHeader(context, l10n.developerSection),
                  const SizedBox(height: 12),
                  Text(
                    DeveloperInfo.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    context,
                    icon: Icons.alternate_email_rounded,
                    label: l10n.email,
                    value: DeveloperInfo.email,
                    onTap: () => _launchUrl(context, 'mailto:${DeveloperInfo.email}'),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    context,
                    icon: Icons.public_rounded,
                    label: l10n.website,
                    value: 'hossam-majrashi.github.io/Works/',
                    onTap: () => _launchUrl(context, DeveloperInfo.websiteUrl),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSelectionRow(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
