import 'dart:typed_data';

enum FileStatus {
  waiting,
  processing,
  done,
  error,
  cancelled,
}

class FileItem {
  final String id;
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int originalSize;
  String originalSha256;
  String originalMd5;

  Uint8List? processedBytes;
  int? processedSize;
  String? processedSha256;
  String? processedMd5;
  String? outputPath;

  FileStatus status;
  double progress;
  List<String> changesApplied;
  String? errorMessage;

  FileItem({
    required this.id,
    required this.name,
    this.path,
    this.bytes,
    required this.originalSize,
    this.originalSha256 = '',
    this.originalMd5 = '',
    this.processedBytes,
    this.processedSize,
    this.processedSha256,
    this.processedMd5,
    this.outputPath,
    this.status = FileStatus.waiting,
    this.progress = 0.0,
    List<String>? changesApplied,
    this.errorMessage,
  }) : changesApplied = changesApplied ?? [];

  FileItem copyWith({
    String? id,
    String? name,
    String? path,
    Uint8List? bytes,
    int? originalSize,
    String? originalSha256,
    String? originalMd5,
    Uint8List? processedBytes,
    int? processedSize,
    String? processedSha256,
    String? processedMd5,
    String? outputPath,
    FileStatus? status,
    double? progress,
    List<String>? changesApplied,
    String? errorMessage,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      originalSize: originalSize ?? this.originalSize,
      originalSha256: originalSha256 ?? this.originalSha256,
      originalMd5: originalMd5 ?? this.originalMd5,
      processedBytes: processedBytes ?? this.processedBytes,
      processedSize: processedSize ?? this.processedSize,
      processedSha256: processedSha256 ?? this.processedSha256,
      processedMd5: processedMd5 ?? this.processedMd5,
      outputPath: outputPath ?? this.outputPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      changesApplied: changesApplied ?? List.from(this.changesApplied),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
