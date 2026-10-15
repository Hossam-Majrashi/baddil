import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/models/processing_options.dart';

class OptionsCard extends StatefulWidget {
  final HomeController controller;
  final bool isBottomSheet;

  const OptionsCard({
    super.key,
    required this.controller,
    this.isBottomSheet = false,
  });

  @override
  State<OptionsCard> createState() => _OptionsCardState();
}

class _OptionsCardState extends State<OptionsCard> {
  late TextEditingController _companyController;
  late TextEditingController _authorController;
  late TextEditingController _copyrightController;
  late TextEditingController _patternController;

  @override
  void initState() {
    super.initState();
    final opt = widget.controller.options;
    _companyController = TextEditingController(text: opt.companyName);
    _authorController = TextEditingController(text: opt.authorName);
    _copyrightController = TextEditingController(text: opt.copyright);
    _patternController = TextEditingController(text: opt.outputFilenamePattern);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _authorController.dispose();
    _copyrightController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  void _syncTextValues(ProcessingOptions current) {
    widget.controller.updateOptions(
      current.copyWith(
        companyName: _companyController.text,
        authorName: _authorController.text,
        copyright: _copyrightController.text,
        outputFilenamePattern: _patternController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final options = widget.controller.options;
    final isProcessing = widget.controller.isProcessing;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.optionsTitle,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Strip metadata checkbox
          _buildCheckboxTile(
            title: l10n.removeMetadata,
            value: options.stripMetadata,
            onChanged: (val) {
              widget.controller.updateOptions(
                options.copyWith(stripMetadata: val ?? false),
              );
            },
          ),

          // Change hash without re-encode
          _buildCheckboxTile(
            title: l10n.changeHashWithoutReencode,
            value: options.perturbHashWithoutRecompress,
            onChanged: (val) {
              widget.controller.updateOptions(
                options.copyWith(perturbHashWithoutRecompress: val ?? false),
              );
            },
          ),

          // Re-encode images
          _buildCheckboxTile(
            title: l10n.reencodeImages,
            value: options.reencodeImages,
            onChanged: (val) {
              widget.controller.updateOptions(
                options.copyWith(reencodeImages: val ?? false),
              );
            },
          ),

          // Image quality slider
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.encodingQuality,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${options.imageQuality}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: options.imageQuality.toDouble(),
                  min: 20,
                  max: 100,
                  divisions: 16,
                  onChanged: options.reencodeImages
                      ? (val) {
                          widget.controller.updateOptions(
                            options.copyWith(imageQuality: val.round()),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),

          // Custom metadata checkbox
          _buildCheckboxTile(
            title: l10n.customMetadata,
            value: options.customMetadataEnabled,
            onChanged: (val) {
              widget.controller.updateOptions(
                options.copyWith(customMetadataEnabled: val ?? false),
              );
            },
          ),

          // Custom metadata fields (when enabled)
          if (options.customMetadataEnabled) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: l10n.companyName,
                isDense: true,
              ),
              onChanged: (_) => _syncTextValues(options),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: l10n.authorName,
                isDense: true,
              ),
              onChanged: (_) => _syncTextValues(options),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _copyrightController,
              decoration: InputDecoration(
                labelText: l10n.copyright,
                isDense: true,
              ),
              onChanged: (_) => _syncTextValues(options),
            ),
          ],

          const SizedBox(height: 12),
          // Output filename pattern
          TextField(
            controller: _patternController,
            decoration: InputDecoration(
              labelText: l10n.outputFilenamePattern,
              hintText: l10n.outputFilenamePatternHint('ext', 'name'),
              isDense: true,
            ),
            onChanged: (_) => _syncTextValues(options),
          ),

          const SizedBox(height: 20),

          // Main Action Button (matches teal design)
          ElevatedButton(
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
                widget.controller.cancelProcessing();
              } else {
                widget.controller.startProcessing();
                if (widget.isBottomSheet) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isProcessing) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  isProcessing ? l10n.cancelProcessing : l10n.startProcessing,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
