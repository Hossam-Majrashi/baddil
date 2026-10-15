import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/models/processing_options.dart';
import 'package:baddil/shared/services/file_fingerprint_service.dart';
import 'package:baddil/shared/services/processors/generic_file_processor.dart';
import 'package:baddil/shared/services/processors/image_reencoder.dart';
import 'package:baddil/shared/services/processors/jpeg_processor.dart';
import 'package:baddil/shared/services/processors/mp4_processor.dart';
import 'package:baddil/shared/services/processors/png_processor.dart';
import 'package:baddil/shared/services/processors/webp_processor.dart';

class ProcessingTaskParams {
  final Uint8List inputBytes;
  final String fileName;
  final ProcessingOptions options;

  const ProcessingTaskParams({
    required this.inputBytes,
    required this.fileName,
    required this.options,
  });
}

class ProcessingTaskResult {
  final Uint8List outputBytes;
  final List<String> changes;

  const ProcessingTaskResult({
    required this.outputBytes,
    required this.changes,
  });
}

class FileProcessingService {
  /// Entry point to process a single FileItem in a background Isolate
  static Future<FileItem> processFile(
    FileItem item,
    ProcessingOptions options, {
    ValueChanged<FileItem>? onFingerprintReady,
  }) async {
    try {
      final inputBytes = await FileFingerprintService.readInputBytes(item);

      // Recalculate from the actual input in case it changed after selection.
      final originalSha256 = sha256.convert(inputBytes).toString();
      final originalMd5 = md5.convert(inputBytes).toString();
      item = item.copyWith(
        originalSha256: originalSha256,
        originalMd5: originalMd5,
      );
      onFingerprintReady?.call(item);

      // Allow the original fingerprint to render before processing starts.
      await Future<void>.delayed(Duration.zero);

      // Execute byte manipulation inside background Isolate
      final taskParams = ProcessingTaskParams(
        inputBytes: inputBytes,
        fileName: item.name,
        options: options,
      );

      final taskResult = await compute(_runProcessingTask, taskParams);
      final processedBytes = taskResult.outputBytes;
      final changes = taskResult.changes;

      final processedSha256 = sha256.convert(processedBytes).toString();
      final processedMd5 = md5.convert(processedBytes).toString();

      String? outputPath;
      if (!kIsWeb) {
        outputPath = await _determineAndWriteOutputFile(
          item: item,
          processedBytes: processedBytes,
          options: options,
        );
      }

      return item.copyWith(
        originalSha256: originalSha256,
        originalMd5: originalMd5,
        processedBytes: processedBytes,
        processedSize: processedBytes.length,
        processedSha256: processedSha256,
        processedMd5: processedMd5,
        outputPath: outputPath,
        status: FileStatus.done,
        progress: 1.0,
        changesApplied: changes,
      );
    } catch (e) {
      return item.copyWith(
        status: FileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Worker function executed inside isolate
  static ProcessingTaskResult _runProcessingTask(ProcessingTaskParams params) {
    Uint8List currentBytes = params.inputBytes;
    final changes = <String>[];
    final options = params.options;
    final fileName = params.fileName;
    final lowerName = fileName.toLowerCase();

    // 1. Layer 3: Optional re-encoding if enabled
    if (options.reencodeImages &&
        (lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.webp'))) {
      final reencoded = ImageReencoder.reencode(
        currentBytes,
        fileName,
        options.imageQuality,
      );
      if (reencoded != null) {
        currentBytes = reencoded;
        changes.add('Re-encoded image at ${options.imageQuality}% quality');
      }
    }

    // 2. Layer 1 & 2: Format-specific metadata stripping and lossless hash alteration
    if (JpegProcessor.isJpeg(currentBytes) ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg')) {
      final result = JpegProcessor.process(currentBytes, options);
      currentBytes = result.bytes;
      changes.addAll(result.changes);
    } else if (PngProcessor.isPng(currentBytes) || lowerName.endsWith('.png')) {
      final result = PngProcessor.process(currentBytes, options);
      currentBytes = result.bytes;
      changes.addAll(result.changes);
    } else if (WebPProcessor.isWebP(currentBytes) ||
        lowerName.endsWith('.webp')) {
      final result = WebPProcessor.process(currentBytes, options);
      currentBytes = result.bytes;
      changes.addAll(result.changes);
    } else if (Mp4Processor.isMp4OrMov(currentBytes) ||
        lowerName.endsWith('.mp4') ||
        lowerName.endsWith('.mov')) {
      final result = Mp4Processor.process(currentBytes, options);
      currentBytes = result.bytes;
      changes.addAll(result.changes);
    } else {
      final result = GenericFileProcessor.process(
        currentBytes,
        fileName,
        options,
      );
      currentBytes = result.bytes;
      changes.addAll(result.changes);
    }

    return ProcessingTaskResult(outputBytes: currentBytes, changes: changes);
  }

  static Future<String> _determineAndWriteOutputFile({
    required FileItem item,
    required Uint8List processedBytes,
    required ProcessingOptions options,
  }) async {
    String baseDir;
    if (options.outputDirectory != null &&
        options.outputDirectory!.isNotEmpty &&
        Directory(options.outputDirectory!).existsSync()) {
      baseDir = options.outputDirectory!;
    } else if (item.path != null) {
      baseDir = p.dirname(item.path!);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      baseDir = dir.path;
    }

    final extWithDot = p.extension(item.name);
    final extWithoutDot = extWithDot.startsWith('.')
        ? extWithDot.substring(1)
        : extWithDot;
    final nameWithoutExt = p.basenameWithoutExtension(item.name);

    String pattern = options.outputFilenamePattern;
    if (!pattern.contains('{name}')) pattern = '{name}_baddil.{ext}';

    String newFilename = pattern
        .replaceAll('{name}', nameWithoutExt)
        .replaceAll('{ext}', extWithoutDot);

    // Prevent overwriting original file under any circumstances
    String destinationPath = p.join(baseDir, newFilename);
    if (item.path != null &&
        p.canonicalize(destinationPath) == p.canonicalize(item.path!)) {
      destinationPath = p.join(
        baseDir,
        '${nameWithoutExt}_modified.$extWithoutDot',
      );
    }

    int counter = 1;
    while (File(destinationPath).existsSync()) {
      destinationPath = p.join(
        baseDir,
        '${nameWithoutExt}_baddil_$counter.$extWithoutDot',
      );
      counter++;
    }

    final outFile = File(destinationPath);
    await outFile.writeAsBytes(processedBytes);
    return destinationPath;
  }
}
