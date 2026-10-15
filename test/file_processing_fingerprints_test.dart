import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/models/processing_options.dart';
import 'package:baddil/shared/services/file_processing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  final input = Uint8List.fromList([1, 2, 3, 4, 5]);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('baddil_fingerprints_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'Original fingerprints are published before processed fingerprints',
    () async {
      FileItem? original;
      final result = await FileProcessingService.processFile(
        FileItem(
          id: 'test',
          name: 'sample.bin',
          bytes: input,
          originalSize: input.length,
          status: FileStatus.processing,
        ),
        ProcessingOptions(outputDirectory: directory.path),
        onFingerprintReady: (item) {
          original = item;
          expect(item.originalSha256, sha256.convert(input).toString());
          expect(item.originalMd5, md5.convert(input).toString());
          expect(item.processedSha256, isNull);
          expect(item.processedMd5, isNull);
          expect(item.status, FileStatus.processing);
        },
      );
      expect(original, isNotNull);
      expect(result.status, FileStatus.done);
      final output = await File(result.outputPath!).readAsBytes();
      expect(result.processedSha256, sha256.convert(output).toString());
      expect(result.processedMd5, md5.convert(output).toString());
      expect(result.originalSha256, isNot(result.processedSha256));
    },
  );

  test(
    'Controller notifies the queue of original hashes during processing',
    () async {
      final controller = HomeController();
      addTearDown(controller.dispose);
      controller.updateOptions(
        ProcessingOptions(outputDirectory: directory.path),
      );
      await controller.addFileFromBytes(name: 'sample.bin', bytes: input);
      var sawOriginalWhileProcessing = false;
      controller.addListener(() {
        final item = controller.queue.single;
        if (item.status == FileStatus.processing &&
            item.originalSha256.isNotEmpty) {
          sawOriginalWhileProcessing = true;
          expect(item.originalSha256, sha256.convert(input).toString());
          expect(item.processedSha256, isNull);
        }
      });
      await controller.startProcessing();
      expect(sawOriginalWhileProcessing, isTrue);
      expect(controller.queue.single.status, FileStatus.done);
      expect(controller.queue.single.processedSha256, isNotNull);
    },
  );

  test('Selecting bytes calculates hashes before any processing', () async {
    final controller = HomeController();
    addTearDown(controller.dispose);
    var notified = false;
    controller.addListener(() {
      if (controller.queue.single.originalSha256.isNotEmpty) notified = true;
    });
    await controller.addFileFromBytes(name: 'sample.bin', bytes: input);
    final item = controller.queue.single;
    expect(notified, isTrue);
    expect(item.status, FileStatus.waiting);
    expect(item.originalSha256, sha256.convert(input).toString());
    expect(item.originalMd5, md5.convert(input).toString());
    expect(item.processedSha256, isNull);
    expect(item.processedMd5, isNull);
    expect(item.outputPath, isNull);
    expect(item.processedBytes, isNull);
  });

  test(
    'Selecting paths hashes every file without writing any output',
    () async {
      final controller = HomeController();
      addTearDown(controller.dispose);
      final first = File('${directory.path}/one.bin');
      final second = File('${directory.path}/two.bin');
      await first.writeAsBytes(input);
      final otherInput = Uint8List.fromList([8, 9, 10]);
      await second.writeAsBytes(otherInput);
      await controller.addFilesFromPaths([first.path, second.path]);
      expect(controller.queue.map((item) => item.id).toSet(), hasLength(2));
      expect(
        controller.queue[0].originalSha256,
        sha256.convert(input).toString(),
      );
      expect(
        controller.queue[1].originalMd5,
        md5.convert(otherInput).toString(),
      );
      for (final item in controller.queue) {
        expect(item.status, FileStatus.waiting);
        expect(item.processedSha256, isNull);
        expect(item.outputPath, isNull);
      }
      expect(await first.readAsBytes(), input);
      expect(await second.readAsBytes(), otherInput);
      expect(await directory.list().length, 2);
    },
  );

  test('Empty selected files also have valid fingerprints', () async {
    final controller = HomeController();
    addTearDown(controller.dispose);
    await controller.addFileFromBytes(name: 'empty.bin', bytes: Uint8List(0));
    expect(
      controller.queue.single.originalSha256,
      sha256.convert([]).toString(),
    );
    expect(controller.queue.single.originalMd5, md5.convert([]).toString());
    expect(controller.queue.single.status, FileStatus.waiting);
  });

  test('Late selection hashes do not resurrect removed files', () async {
    final controller = HomeController();
    addTearDown(controller.dispose);
    final pending = controller.addFileFromBytes(
      name: 'sample.bin',
      bytes: input,
    );
    controller.removeItem(controller.queue.single.id);
    await pending;
    expect(controller.queue, isEmpty);
  });

  test(
    'Selection hashing can finish safely after controller disposal',
    () async {
      final controller = HomeController();
      final pending = controller.addFileFromBytes(
        name: 'sample.bin',
        bytes: input,
      );
      controller.dispose();
      await pending;
    },
  );

  test(
    'Processing immediately after selection keeps both fingerprints',
    () async {
      final controller = HomeController();
      addTearDown(controller.dispose);
      controller.updateOptions(
        ProcessingOptions(outputDirectory: directory.path),
      );
      final pending = controller.addFileFromBytes(
        name: 'sample.bin',
        bytes: input,
      );
      await controller.startProcessing();
      await pending;
      final item = controller.queue.single;
      expect(item.status, FileStatus.done);
      expect(item.originalSha256, sha256.convert(input).toString());
      expect(item.processedSha256, isNot(item.originalSha256));
    },
  );

  test('Original fingerprints remain available when saving fails', () async {
    // A nonexistent source directory forces saving to fail without plugins.
    final result = await FileProcessingService.processFile(
      FileItem(
        id: 'test',
        name: 'sample.bin',
        path: '${directory.path}/missing/sample.bin',
        bytes: input,
        originalSize: input.length,
      ),
      const ProcessingOptions(),
    );
    expect(result.status, FileStatus.error);
    expect(result.originalSha256, sha256.convert(input).toString());
    expect(result.originalMd5, md5.convert(input).toString());
    expect(result.processedSha256, isNull);
  });
}
