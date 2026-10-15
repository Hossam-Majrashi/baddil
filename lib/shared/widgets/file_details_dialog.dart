import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/widgets/file_fingerprint_comparison.dart';

class FileDetailsDialog extends StatelessWidget {
  final FileItem item;

  const FileDetailsDialog({super.key, required this.item});

  static Future<void> show(
    BuildContext context,
    FileItem item, {
    HomeController? controller,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        if (controller == null) return FileDetailsDialog(item: item);
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final current = controller.queue.where(
              (file) => file.id == item.id,
            );
            return FileDetailsDialog(
              item: current.isEmpty ? item : current.first,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.fileDetailsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoTile(
                        context,
                        label: l10n.fileName,
                        value: item.name,
                      ),
                      _buildInfoTile(
                        context,
                        label: '${l10n.fileSizeBefore} / ${l10n.fileSizeAfter}',
                        value:
                            '${_formatBytes(item.originalSize)}  ➔  ${item.processedSize != null ? _formatBytes(item.processedSize!) : "-"}',
                      ),
                      FileFingerprintComparison(item: item),
                      const SizedBox(height: 12),
                      Text(
                        l10n.changesApplied,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.changesApplied.isEmpty)
                        Text(
                          item.status == FileStatus.waiting
                              ? l10n.statusWaiting
                              : '-',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        ...item.changesApplied.map(
                          (change) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    change,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (item.outputPath != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          context,
                          label: l10n.outputFolder,
                          value: item.outputPath!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
