import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:baddil/shared/models/file_item.dart';

class CsvExportService {
  static String generateCsvString(List<FileItem> items) {
    final rows = <List<dynamic>>[
      [
        'File Name',
        'Status',
        'Original Size',
        'Processed Size',
        'SHA-256 Before',
        'SHA-256 After',
        'MD5 Before',
        'MD5 After',
        'Changes Applied',
        'Output Path',
      ],
      for (final item in items)
        [
          item.name,
          item.status.name,
          item.originalSize,
          item.processedSize ?? item.originalSize,
          item.originalSha256,
          item.processedSha256 ?? '',
          item.originalMd5,
          item.processedMd5 ?? '',
          item.changesApplied.join('; '),
          item.outputPath ?? '',
        ],
    ];

    return csv.encode(rows);
  }

  static Future<String?> exportToFile(List<FileItem> items) async {
    final csvContent = generateCsvString(items);
    if (kIsWeb) {
      return null;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = p.join(dir.path, 'baddil_report_$timestamp.csv');
      final file = File(filePath);
      await file.writeAsString(csvContent, encoding: utf8);
      return filePath;
    } catch (_) {
      return null;
    }
  }

  static Uint8List getCsvBytes(List<FileItem> items) {
    return Uint8List.fromList(utf8.encode(generateCsvString(items)));
  }
}
