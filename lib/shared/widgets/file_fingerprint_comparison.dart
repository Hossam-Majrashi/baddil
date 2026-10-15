import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/shared/models/file_item.dart';

/// Full, copyable fingerprints shared by the queue and the file report.
class FileFingerprintComparison extends StatelessWidget {
  final FileItem item;

  const FileFingerprintComparison({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pending =
        item.status == FileStatus.processing ||
        item.status == FileStatus.waiting;
    final placeholder = pending
        ? l10n.fingerprintPending
        : l10n.fingerprintUnavailable;
    final hasComparison =
        item.originalSha256.isNotEmpty &&
        (item.processedSha256?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final before = _buildGroup(
              context,
              title: l10n.fingerprintBefore,
              shaLabel: l10n.hashBefore,
              shaHash: item.originalSha256,
              md5Label: l10n.md5Before,
              md5Hash: item.originalMd5,
              placeholder: placeholder,
            );
            if (item.status == FileStatus.waiting) return before;
            final after = _buildGroup(
              context,
              title: l10n.fingerprintAfter,
              shaLabel: l10n.hashAfter,
              shaHash: item.processedSha256 ?? '',
              md5Label: l10n.md5After,
              md5Hash: item.processedMd5 ?? '',
              placeholder: placeholder,
            );
            if (constraints.maxWidth >= 520) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: before),
                  const SizedBox(width: 12),
                  Expanded(child: after),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [before, const SizedBox(height: 8), after],
            );
          },
        ),
        if (hasComparison) ...[
          const SizedBox(height: 8),
          Text(
            item.originalSha256 != item.processedSha256
                ? l10n.fingerprintChanged
                : l10n.fingerprintUnchanged,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required String title,
    required String shaLabel,
    required String shaHash,
    required String md5Label,
    required String md5Hash,
    required String placeholder,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildHash(context, shaLabel, shaHash, placeholder),
          const SizedBox(height: 8),
          _buildHash(context, md5Label, md5Hash, placeholder),
        ],
      ),
    );
  }

  Widget _buildHash(
    BuildContext context,
    String label,
    String hash,
    String placeholder,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            if (hash.isNotEmpty)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: '${l10n.copyHash}: $label',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: hash));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.hashCopied)));
                },
              ),
          ],
        ),
        if (hash.isEmpty)
          Text(
            placeholder,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          SelectableText(
            hash,
            textDirection: TextDirection.ltr,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
