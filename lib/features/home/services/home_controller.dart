import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/models/processing_options.dart';
import 'package:baddil/shared/services/file_processing_service.dart';
import 'package:baddil/shared/services/file_fingerprint_service.dart';

class HomeController extends ChangeNotifier {
  final List<FileItem> _queue = [];
  ProcessingOptions _options = const ProcessingOptions();
  bool _isProcessing = false;
  bool _cancelRequested = false;
  bool _justFinished = false;
  bool _disposed = false;

  List<FileItem> get queue => List.unmodifiable(_queue);
  ProcessingOptions get options => _options;
  bool get isProcessing => _isProcessing;
  bool get justFinished => _justFinished;

  int get totalCount => _queue.length;
  int get completedCount =>
      _queue.where((e) => e.status == FileStatus.done).length;
  int get processingIndex =>
      _queue.indexWhere((e) => e.status == FileStatus.processing);
  double get batchProgress =>
      _queue.isEmpty ? 0.0 : (completedCount / _queue.length);

  void dismissCompletionBanner() {
    _justFinished = false;
    notifyListeners();
  }

  void updateOptions(ProcessingOptions newOptions) {
    _options = newOptions;
    notifyListeners();
  }

  Future<void> addFilesFromPaths(List<String> paths) async {
    final items = <FileItem>[];
    for (final path in paths) {
      final file = File(path);
      if (file.existsSync()) {
        final stat = file.statSync();
        final name = p.basename(path);
        final id = '${DateTime.now().microsecondsSinceEpoch}_${_queue.length}';
        items.add(
          FileItem(
            id: '${id}_${items.length}',
            name: name,
            path: path,
            originalSize: stat.size,
          ),
        );
      }
    }
    await _addFiles(items);
  }

  Future<void> addFileFromBytes({
    required String name,
    required Uint8List bytes,
    String? path,
  }) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}_${_queue.length}';
    await _addFiles([
      FileItem(
        id: id,
        name: name,
        path: path,
        bytes: bytes,
        originalSize: bytes.length,
      ),
    ]);
  }

  Future<void> _addFiles(List<FileItem> items) async {
    if (_disposed || items.isEmpty) return;
    _justFinished = false;
    _queue.addAll(items);
    notifyListeners();

    // Hash sequentially so selecting a large folder does not launch an
    // isolate and retain file bytes for every file at once.
    for (final item in items) {
      if (_disposed) return;
      final queuedIndex = _queue.indexWhere((file) => file.id == item.id);
      if (queuedIndex < 0 || _queue[queuedIndex].status != FileStatus.waiting) {
        continue;
      }
      FileFingerprints? fingerprints;
      String? error;
      try {
        fingerprints = await FileFingerprintService.calculate(item);
      } catch (e) {
        error = e.toString();
      }
      if (_disposed) return;
      final index = _queue.indexWhere((file) => file.id == item.id);
      // A late selection result must not replace processing results or
      // resurrect a file that was removed while its fingerprint was loading.
      if (index < 0 || _queue[index].status != FileStatus.waiting) continue;
      _queue[index] = fingerprints != null
          ? _queue[index].copyWith(
              originalSha256: fingerprints.sha256Hash,
              originalMd5: fingerprints.md5Hash,
              originalSize: fingerprints.size,
            )
          : _queue[index].copyWith(
              status: FileStatus.error,
              errorMessage: error,
            );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> pickFiles() async {
    _justFinished = false;
    final files = await FilePicker.pickFiles();

    if (files.isEmpty || _disposed) return;

    final items = <FileItem>[];
    for (final file in files) {
      final id = '${DateTime.now().microsecondsSinceEpoch}_${items.length}';
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        items.add(
          FileItem(
            id: id,
            name: file.name,
            bytes: bytes,
            originalSize: bytes.length,
          ),
        );
      } else {
        if (file.path != null) {
          final size = file.lengthSync() ?? (await file.length()) ?? 0;
          items.add(
            FileItem(
              id: id,
              name: file.name,
              path: file.path,
              originalSize: size,
            ),
          );
        }
      }
    }
    await _addFiles(items);
  }

  Future<bool> pickFolder() async {
    _justFinished = false;
    if (kIsWeb) {
      return false; // Web cannot pick directories via standard dart:io
    }

    final selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory == null) return false;

    final dir = Directory(selectedDirectory);
    if (!dir.existsSync()) return false;

    final entities = dir.listSync(recursive: true, followLinks: false);
    final items = <FileItem>[];
    for (final entity in entities) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue; // skip hidden files
        final stat = entity.statSync();
        final id = '${DateTime.now().microsecondsSinceEpoch}_${items.length}';
        items.add(
          FileItem(
            id: id,
            name: name,
            path: entity.path,
            originalSize: stat.size,
          ),
        );
      }
    }
    await _addFiles(items);
    return true;
  }

  Future<void> startProcessing() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;
    _cancelRequested = false;
    _justFinished = false;
    notifyListeners();

    int processedThisRun = 0;

    for (int i = 0; i < _queue.length; i++) {
      if (_cancelRequested) {
        if (_queue[i].status == FileStatus.waiting) {
          _queue[i] = _queue[i].copyWith(status: FileStatus.cancelled);
        }
        continue;
      }

      if (_queue[i].status == FileStatus.done) continue;

      _queue[i] = _queue[i].copyWith(
        status: FileStatus.processing,
        progress: 0.35,
      );
      notifyListeners();

      // Small async tick to allow UI animation frame to start smoothly
      await Future<void>.delayed(const Duration(milliseconds: 50));

      _queue[i] = _queue[i].copyWith(progress: 0.7);
      notifyListeners();

      final updated = await FileProcessingService.processFile(
        _queue[i],
        _options,
        onFingerprintReady: (item) {
          _queue[i] = item;
          notifyListeners();
        },
      );
      _queue[i] = updated;
      processedThisRun++;
      notifyListeners();
    }

    _isProcessing = false;
    if (!_cancelRequested && processedThisRun > 0) {
      _justFinished = true;
    }
    _cancelRequested = false;
    notifyListeners();
  }

  void cancelProcessing() {
    _cancelRequested = true;
    _isProcessing = false;
    _justFinished = false;
    for (int i = 0; i < _queue.length; i++) {
      if (_queue[i].status == FileStatus.processing ||
          _queue[i].status == FileStatus.waiting) {
        _queue[i] = _queue[i].copyWith(status: FileStatus.cancelled);
      }
    }
    notifyListeners();
  }

  void clearQueue() {
    if (_isProcessing) return;
    _justFinished = false;
    _queue.clear();
    notifyListeners();
  }

  void removeItem(String id) {
    if (_isProcessing) return;
    _queue.removeWhere((item) => item.id == id);
    if (_queue.isEmpty) {
      _justFinished = false;
    }
    notifyListeners();
  }
}
