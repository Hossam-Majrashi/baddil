import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/settings/services/settings_controller.dart';

class OnboardingScreen extends StatefulWidget {
  final SettingsController settingsController;
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.settingsController,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.settingsController.completeOnboarding();
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      // Steps indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = index == _currentStep;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 28 : 10,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (page) => setState(() => _currentStep = page),
                          children: [
                            _buildIntroStep(context),
                            _buildLanguageStep(context),
                            _buildThemeStep(context),
                          ],
                        ),
                      ),

                      // Next / Complete Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _nextPage,
                          child: Text(
                            _currentStep == 2 ? l10n.getStarted : l10n.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroStep(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outline, width: 1.5),
          ),
          child: Center(
            child: Image.asset(
              'assets/icon/icon.png',
              width: 58,
              height: 58,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.fingerprint_rounded,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Text(
            l10n.onboardingDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageStep(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.selectLanguage,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        _buildChoiceCard(
          context,
          title: l10n.languageArabic,
          subtitle: 'العربية (Arabic)',
          isSelected: widget.settingsController.locale.languageCode == 'ar',
          onTap: () => widget.settingsController.setLocale(const Locale('ar')),
        ),
        const SizedBox(height: 12),
        _buildChoiceCard(
          context,
          title: l10n.languageEnglish,
          subtitle: 'English',
          isSelected: widget.settingsController.locale.languageCode == 'en',
          onTap: () => widget.settingsController.setLocale(const Locale('en')),
        ),
      ],
    );
  }

  Widget _buildThemeStep(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.selectTheme,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        _buildChoiceCard(
          context,
          title: l10n.themeDark,
          subtitle: 'Dark Theme (#212327)',
          isSelected: widget.settingsController.themeMode == ThemeMode.dark,
          onTap: () => widget.settingsController.setThemeMode(ThemeMode.dark),
        ),
        const SizedBox(height: 12),
        _buildChoiceCard(
          context,
          title: l10n.themeLight,
          subtitle: 'Light Theme (#efeef1)',
          isSelected: widget.settingsController.themeMode == ThemeMode.light,
          onTap: () => widget.settingsController.setThemeMode(ThemeMode.light),
        ),
        const SizedBox(height: 12),
        _buildChoiceCard(
          context,
          title: l10n.themeSystem,
          subtitle: 'Follow device settings',
          isSelected: widget.settingsController.themeMode == ThemeMode.system,
          onTap: () => widget.settingsController.setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }

  Widget _buildChoiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 22)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  color: theme.colorScheme.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}
