import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/widgets/dashed_rect_painter.dart';

class UploadDropZone extends StatefulWidget {
  final HomeController controller;
  final bool isMobile;

  const UploadDropZone({
    super.key,
    required this.controller,
    this.isMobile = false,
  });

  @override
  State<UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<UploadDropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return DropTarget(
      onDragEntered: (details) => setState(() => _isDragging = true),
      onDragExited: (details) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        if (details.files.isEmpty) return;

        for (final file in details.files) {
          if (kIsWeb) {
            final bytes = await file.readAsBytes();
            await widget.controller.addFileFromBytes(
              name: file.name,
              bytes: bytes,
            );
          } else {
            await widget.controller.addFilesFromPaths([file.path]);
          }
        }
      },
      child: CustomPaint(
        painter: DashedRectBorderPainter(
          color: _isDragging
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          strokeWidth: _isDragging ? 2.0 : 1.5,
          borderRadius: 16.0,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: widget.isMobile ? 28.0 : 36.0,
            horizontal: 24.0,
          ),
          decoration: BoxDecoration(
            color: _isDragging
                ? theme.colorScheme.primary.withAlpha(20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upload icon in teal
              Icon(
                Icons.file_upload_outlined,
                size: widget.isMobile ? 38 : 46,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 14),
              // Title
              Text(
                widget.isMobile ? l10n.pickMobileTitle : l10n.dropFilesHere,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isMobile ? 17 : 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                l10n.dropFilesSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              // Buttons
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  if (!widget.isMobile)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () async {
                        if (kIsWeb) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.folderPickUnsupportedOnWeb),
                            ),
                          );
                        } else {
                          await widget.controller.pickFolder();
                        }
                      },
                      child: Text(
                        l10n.selectFolder,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => widget.controller.pickFiles(),
                    child: Text(
                      l10n.selectFiles,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
