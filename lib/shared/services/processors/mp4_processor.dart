import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:baddil/shared/models/processing_options.dart';

class Mp4ProcessingResult {
  final Uint8List bytes;
  final List<String> changes;

  const Mp4ProcessingResult({required this.bytes, required this.changes});
}

class Mp4Processor {
  static bool isMp4OrMov(Uint8List bytes) {
    if (bytes.length < 8) return false;
    final type = ascii.decode(bytes.sublist(4, 8), allowInvalid: true);
    return type == 'ftyp' || type == 'moov' || type == 'wide' || type == 'mdat';
  }

  static Mp4ProcessingResult process(
    Uint8List input,
    ProcessingOptions options,
  ) {
    if (!isMp4OrMov(input)) {
      throw FormatException('Input is not a valid MP4/MOV container');
    }

    final changes = <String>[];
    // Work on a mutable copy
    final data = Uint8List.fromList(input);
    final byteData = ByteData.sublistView(data);
    final totalLen = data.length;

    int offset = 0;

    while (offset + 8 <= totalLen) {
      int boxSize = byteData.getUint32(offset, Endian.big);
      final boxType = ascii.decode(data.sublist(offset + 4, offset + 8), allowInvalid: true);

      int headerSize = 8;
      if (boxSize == 1) {
        if (offset + 16 > totalLen) break;
        boxSize = byteData.getUint64(offset + 8, Endian.big);
        headerSize = 16;
      } else if (boxSize == 0) {
        boxSize = totalLen - offset;
      }

      if (boxSize < headerSize || offset + boxSize > totalLen) {
        break;
      }

      if (boxType == 'moov') {
        _processMoovBox(data, byteData, offset + headerSize, offset + boxSize, options, changes);
      }

      offset += boxSize;
    }

    final outputBuilder = BytesBuilder();
    outputBuilder.add(data);

    // If perturbHashWithoutRecompress is requested, append/update a root 'free' box with nonce
    if (options.perturbHashWithoutRecompress) {
      final random = Random.secure();
      final nonce = List<int>.generate(24, (_) => random.nextInt(256));
      final payload = utf8.encode('baddil:${DateTime.now().millisecondsSinceEpoch}:') + nonce;

      final freeBoxSize = 8 + payload.length;
      final freeHeader = Uint8List(8);
      final freeBd = ByteData.sublistView(freeHeader);
      freeBd.setUint32(0, freeBoxSize, Endian.big);
      freeHeader[4] = 0x66; // 'f'
      freeHeader[5] = 0x72; // 'r'
      freeHeader[6] = 0x65; // 'e'
      freeHeader[7] = 0x65; // 'e'

      outputBuilder.add(freeHeader);
      outputBuilder.add(payload);
      changes.add('Injected root MP4 free atom with unique nonce');
    }

    return Mp4ProcessingResult(
      bytes: outputBuilder.toBytes(),
      changes: changes.isEmpty ? ['Cleaned MP4/MOV container'] : changes,
    );
  }

  static void _processMoovBox(
    Uint8List data,
    ByteData byteData,
    int start,
    int end,
    ProcessingOptions options,
    List<String> changes,
  ) {
    int offset = start;
    while (offset + 8 <= end) {
      int boxSize = byteData.getUint32(offset, Endian.big);
      final boxType = ascii.decode(data.sublist(offset + 4, offset + 8), allowInvalid: true);

      int headerSize = 8;
      if (boxSize == 1) {
        if (offset + 16 > end) break;
        boxSize = byteData.getUint64(offset + 8, Endian.big);
        headerSize = 16;
      }

      if (boxSize < headerSize || offset + boxSize > end) break;

      // Strip or neutralize udta and meta boxes inside moov
      if (options.stripMetadata && (boxType == 'udta' || boxType == 'meta')) {
        // Neutralize by turning into 'free' box without shifting byte offsets
        data[offset + 4] = 0x66; // 'f'
        data[offset + 5] = 0x72; // 'r'
        data[offset + 6] = 0x65; // 'e'
        data[offset + 7] = 0x65; // 'e'
        // Zero payload to eliminate all metadata strings/tags
        for (int i = offset + headerSize; i < offset + boxSize; i++) {
          data[i] = 0;
        }
        changes.add('Sanitized container metadata ($boxType -> free)');
      } else if (boxType == 'mvhd') {
        _updateHeaderTimestamps(data, byteData, offset + headerSize, offset + boxSize, changes, 'mvhd');
      } else if (boxType == 'trak') {
        _processTrakBox(data, byteData, offset + headerSize, offset + boxSize, options, changes);
      }

      offset += boxSize;
    }
  }

  static void _processTrakBox(
    Uint8List data,
    ByteData byteData,
    int start,
    int end,
    ProcessingOptions options,
    List<String> changes,
  ) {
    int offset = start;
    while (offset + 8 <= end) {
      int boxSize = byteData.getUint32(offset, Endian.big);
      final boxType = ascii.decode(data.sublist(offset + 4, offset + 8), allowInvalid: true);

      if (boxSize < 8 || offset + boxSize > end) break;

      if (options.stripMetadata && (boxType == 'udta' || boxType == 'meta')) {
        data[offset + 4] = 0x66;
        data[offset + 5] = 0x72;
        data[offset + 6] = 0x65;
        data[offset + 7] = 0x65;
        for (int i = offset + 8; i < offset + boxSize; i++) {
          data[i] = 0;
        }
        changes.add('Sanitized track metadata ($boxType -> free)');
      } else if (boxType == 'tkhd') {
        _updateHeaderTimestamps(data, byteData, offset + 8, offset + boxSize, changes, 'tkhd');
      }

      offset += boxSize;
    }
  }

  static void _updateHeaderTimestamps(
    Uint8List data,
    ByteData byteData,
    int start,
    int end,
    List<String> changes,
    String headerName,
  ) {
    if (start + 12 > end) return;
    final version = data[start];
    // MP4 epoch is Jan 1, 1904. Current timestamp difference is ~ 2082844800s.
    final nowMp4Seconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 2082844800;

    if (version == 0 && start + 12 <= end) {
      byteData.setUint32(start + 4, nowMp4Seconds, Endian.big); // creation time
      byteData.setUint32(start + 8, nowMp4Seconds, Endian.big); // mod time
      changes.add('Updated $headerName timestamps');
    } else if (version == 1 && start + 20 <= end) {
      byteData.setUint64(start + 4, nowMp4Seconds, Endian.big);
      byteData.setUint64(start + 12, nowMp4Seconds, Endian.big);
      changes.add('Updated $headerName 64-bit timestamps');
    }
  }
}
