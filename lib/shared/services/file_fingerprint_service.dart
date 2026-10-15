import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:baddil/shared/models/file_item.dart';

class FileFingerprints {
  final String sha256Hash;
  final String md5Hash;
  final int size;

  const FileFingerprints({
    required this.sha256Hash,
    required this.md5Hash,
    required this.size,
  });
}

/// Calculates fingerprints without modifying or saving the selected file.
class FileFingerprintService {
  static Future<FileFingerprints> calculate(FileItem item) {
    return compute(_calculate, item);
  }

  static Future<Uint8List> readInputBytes(FileItem item) async {
    if (item.bytes != null) return item.bytes!;
    if (item.path != null && !kIsWeb) {
      return File(item.path!).readAsBytes();
    }
    throw StateError('File data is not accessible');
  }

  static Future<FileFingerprints> _calculate(FileItem item) async {
    final bytes = await readInputBytes(item);
    return FileFingerprints(
      sha256Hash: sha256.convert(bytes).toString(),
      md5Hash: md5.convert(bytes).toString(),
      size: bytes.length,
    );
  }
}
