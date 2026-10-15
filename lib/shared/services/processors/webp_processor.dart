import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:baddil/shared/models/processing_options.dart';

class WebPProcessingResult {
  final Uint8List bytes;
  final List<String> changes;

  const WebPProcessingResult({required this.bytes, required this.changes});
}

class WebPProcessor {
  static bool isWebP(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final riff = ascii.decode(bytes.sublist(0, 4));
    final webp = ascii.decode(bytes.sublist(8, 12));
    return riff == 'RIFF' && webp == 'WEBP';
  }

  static WebPProcessingResult process(
    Uint8List input,
    ProcessingOptions options,
  ) {
    if (!isWebP(input)) {
      throw FormatException('Input is not a valid WebP RIFF file');
    }

    final changes = <String>[];
    final chunkBuilder = BytesBuilder();

    int offset = 12;
    final totalLen = input.length;
    bool insertedAncillary = false;

    while (offset + 8 <= totalLen) {
      final fourCC = ascii.decode(input.sublist(offset, offset + 4));
      final chunkSize = input[offset + 4] |
          (input[offset + 5] << 8) |
          (input[offset + 6] << 16) |
          (input[offset + 7] << 24);

      final chunkDataStart = offset + 8;
      final chunkDataEnd = chunkDataStart + chunkSize;
      final paddedEnd = (chunkSize % 2 == 1) ? chunkDataEnd + 1 : chunkDataEnd;

      if (chunkDataEnd > totalLen) {
        chunkBuilder.add(input.sublist(offset));
        break;
      }

      bool shouldStrip = false;
      if (options.stripMetadata) {
        if (fourCC == 'EXIF') {
          shouldStrip = true;
          changes.add('Removed WebP EXIF chunk');
        } else if (fourCC == 'XMP ') {
          shouldStrip = true;
          changes.add('Removed WebP XMP chunk');
        }
      }

      if (!shouldStrip) {
        // Copy chunk
        chunkBuilder.add(input.sublist(offset, paddedEnd <= totalLen ? paddedEnd : totalLen));
      }

      if (!insertedAncillary && options.perturbHashWithoutRecompress) {
        insertedAncillary = true;
        final random = Random.secure();
        final nonce = List<int>.generate(24, (_) => random.nextInt(256));
        final payload = utf8.encode('baddil:${DateTime.now().millisecondsSinceEpoch}:') + nonce;

        _writeRiffChunk(chunkBuilder, 'bAdD', payload);
        changes.add('Injected RIFF custom chunk (bAdD)');
      }

      offset = paddedEnd;
    }

    final payloadBytes = chunkBuilder.toBytes();
    final finalRiffSize = 4 + payloadBytes.length; // 'WEBP' + chunks

    final result = BytesBuilder();
    result.add(ascii.encode('RIFF'));
    result.add([
      finalRiffSize & 0xFF,
      (finalRiffSize >> 8) & 0xFF,
      (finalRiffSize >> 16) & 0xFF,
      (finalRiffSize >> 24) & 0xFF,
    ]);
    result.add(ascii.encode('WEBP'));
    result.add(payloadBytes);

    return WebPProcessingResult(
      bytes: result.toBytes(),
      changes: changes.isEmpty ? ['Cleaned WebP structure'] : changes,
    );
  }

  static void _writeRiffChunk(BytesBuilder builder, String fourCC, List<int> data) {
    builder.add(ascii.encode(fourCC));
    final size = data.length;
    builder.add([
      size & 0xFF,
      (size >> 8) & 0xFF,
      (size >> 16) & 0xFF,
      (size >> 24) & 0xFF,
    ]);
    builder.add(data);
    if (size % 2 == 1) {
      builder.add([0]); // RIFF chunks must be padded to even boundary
    }
  }
}
