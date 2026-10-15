import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:baddil/core/l10n/l10n.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/services/csv_export_service.dart';
import 'package:baddil/shared/widgets/file_details_dialog.dart';
import 'package:baddil/shared/widgets/file_fingerprint_comparison.dart';

class QueueCard extends StatefulWidget {
  final HomeController controller;

  const QueueCard({super.key, required this.controller});

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.controller.isProcessing) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant QueueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.isProcessing && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.controller.isProcessing &&
        _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = widget.controller;
    final queue = controller.queue;

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
          // Header with title and quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.processingQueue,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (queue.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${queue.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (queue.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download_rounded, size: 20),
                      tooltip: l10n.exportCsv,
                      onPressed: () async {
                        final path = await CsvExportService.exportToFile(queue);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                path != null
                                    ? '${l10n.exportSuccess}: $path'
                                    : l10n.exportSuccess,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                      tooltip: l10n.clearQueue,
                      onPressed: controller.isProcessing
                          ? null
                          : controller.clearQueue,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Animated Processing Banner with progress bar
          if (controller.isProcessing) ...[
            _buildAnimatedProcessingBanner(context),
            const SizedBox(height: 14),
          ],

          // 2. Animated Completion Banner when finished
          if (controller.justFinished &&
              !controller.isProcessing &&
              queue.isNotEmpty) ...[
            _buildAnimatedCompletionBanner(context),
            const SizedBox(height: 14),
          ],

          if (queue.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 36.0,
                horizontal: 16.0,
              ),
              child: Center(
                child: Text(
                  l10n.queueEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              separatorBuilder: (context, index) =>
                  Divider(color: theme.colorScheme.outline, height: 16),
              itemBuilder: (context, index) {
                final item = queue[index];
                return _buildQueueItemTile(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProcessingBanner(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = widget.controller;
    final progress = controller.batchProgress;
    final total = controller.totalCount;
    final completed = controller.completedCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(90),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _pulseController.value * 2 * math.pi,
                    child: Icon(
                      Icons.sync_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.batchProcessingTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.batchProcessingSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, animatedValue, child) {
                return LinearProgressIndicator(
                  value: animatedValue > 0 ? animatedValue : null,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCompletionBanner(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: 0.95 + (scale * 0.05),
          child: Opacity(
            opacity: scale.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.allCompletedTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.allCompletedSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: l10n.dismiss,
                    onPressed: widget.controller.dismissCompletionBanner,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQueueItemTile(BuildContext context, FileItem item) {
    final theme = Theme.of(context);
    final isProcessingThis = item.status == FileStatus.processing;

    return InkWell(
      onTap: () =>
          FileDetailsDialog.show(context, item, controller: widget.controller),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Status Badge on the leading side
                _buildStatusBadge(context, item.status),
                const SizedBox(width: 12),
                // File name
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Delete button
                if (!widget.controller.isProcessing)
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => widget.controller.removeItem(item.id),
                  ),
              ],
            ),
            // Show the old fingerprint on selection, then the new one
            // automatically when processing finishes.
            const SizedBox(height: 8),
            FileFingerprintComparison(item: item),
            // Progress indicator if processing
            if (isProcessingThis) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, FileStatus status) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final (label, bgColor, textColor, icon) = switch (status) {
      FileStatus.done => (
        l10n.statusDone,
        theme.colorScheme.primary,
        theme.colorScheme.onPrimary,
        Icons.check_rounded,
      ),
      FileStatus.processing => (
        l10n.statusProcessing,
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurface,
        Icons.hourglass_top_rounded,
      ),
      FileStatus.waiting => (
        l10n.statusWaiting,
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
        null,
      ),
      FileStatus.error => (
        l10n.statusError,
        theme.colorScheme.error,
        theme.colorScheme.onError,
        Icons.error_outline_rounded,
      ),
      FileStatus.cancelled => (
        l10n.statusCancelled,
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
