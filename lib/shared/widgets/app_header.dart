import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  const AppHeader({
    super.key,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
              tooltip: l10n.settings,
              onPressed: onSettingsPressed,
            ),
          ),

          // App branding (matching design)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Baddil',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.fingerprint_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
