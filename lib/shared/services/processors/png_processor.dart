import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:baddil/shared/models/processing_options.dart';
import 'package:baddil/shared/services/crc32.dart';

class PngProcessingResult {
  final Uint8List bytes;
  final List<String> changes;

  const PngProcessingResult({required this.bytes, required this.changes});
}

class PngProcessor {
  static const List<int> pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

  static bool isPng(Uint8List bytes) {
    if (bytes.length < 8) return false;
    for (int i = 0; i < 8; i++) {
      if (bytes[i] != pngSignature[i]) return false;
    }
    return true;
  }

  static PngProcessingResult process(
    Uint8List input,
    ProcessingOptions options,
  ) {
    if (!isPng(input)) {
      throw FormatException('Input is not a valid PNG image');
    }

    final changes = <String>[];
    final outputBuilder = BytesBuilder();
    outputBuilder.add(pngSignature);

    int offset = 8;
    final totalLen = input.length;
    bool insertedAncillary = false;

    while (offset + 8 <= totalLen) {
      final length = (input[offset] << 24) |
          (input[offset + 1] << 16) |
          (input[offset + 2] << 8) |
          input[offset + 3];

      final typeBytes = input.sublist(offset + 4, offset + 8);
      final chunkType = ascii.decode(typeBytes);

      final chunkDataStart = offset + 8;
      final chunkDataEnd = chunkDataStart + length;
      final chunkEnd = chunkDataEnd + 4; // Including 4 bytes CRC

      if (chunkEnd > totalLen) {
        // Corrupted chunk or trailing data, append as is
        outputBuilder.add(input.sublist(offset));
        break;
      }

      bool shouldStrip = false;
      if (options.stripMetadata) {
        if (chunkType == 'tEXt' || chunkType == 'zTXt' || chunkType == 'iTXt') {
          shouldStrip = true;
          changes.add('Removed PNG text metadata ($chunkType)');
        } else if (chunkType == 'eXIf') {
          shouldStrip = true;
          changes.add('Removed PNG EXIF block (eXIf)');
        } else if (chunkType == 'caBX') {
          shouldStrip = true;
          changes.add('Removed PNG C2PA Content Credentials (caBX)');
        } else if (chunkType == 'tIME') {
          shouldStrip = true;
          changes.add('Removed PNG timestamp chunk (tIME)');
        }
      }

      if (!shouldStrip) {
        outputBuilder.add(input.sublist(offset, chunkEnd));
      }

      // Insert ancillary chunk right after IHDR
      if (chunkType == 'IHDR' && !insertedAncillary) {
        insertedAncillary = true;

        if (options.perturbHashWithoutRecompress) {
          final random = Random.secure();
          final nonce = List<int>.generate(24, (_) => random.nextInt(256));
          final payload = utf8.encode('baddil:${DateTime.now().millisecondsSinceEpoch}:') + nonce;

          _writeChunk(outputBuilder, 'bAdD', payload);
          changes.add('Injected ancillary private chunk (bAdD) with valid CRC');
        }

        if (options.customMetadataEnabled) {
          if (options.authorName.isNotEmpty) {
            _writeTextChunk(outputBuilder, 'Author', options.authorName);
          }
          if (options.companyName.isNotEmpty) {
            _writeTextChunk(outputBuilder, 'Company', options.companyName);
          }
          if (options.copyright.isNotEmpty) {
            _writeTextChunk(outputBuilder, 'Copyright', options.copyright);
          }
          changes.add('Injected custom tEXt metadata chunks');
        }
      }

      offset = chunkEnd;
    }

    return PngProcessingResult(
      bytes: outputBuilder.toBytes(),
      changes: changes.isEmpty ? ['Cleaned PNG structure'] : changes,
    );
  }

  static void _writeTextChunk(BytesBuilder builder, String keyword, String text) {
    final payload = <int>[...latin1.encode(keyword), 0, ...utf8.encode(text)];
    _writeChunk(builder, 'tEXt', payload);
  }

  static void _writeChunk(BytesBuilder builder, String type, List<int> data) {
    final length = data.length;
    // Length (4 bytes big-endian)
    builder.add([
      (length >> 24) & 0xFF,
      (length >> 16) & 0xFF,
      (length >> 8) & 0xFF,
      length & 0xFF,
    ]);

    // Chunk type (4 bytes ASCII)
    final typeBytes = ascii.encode(type);
    builder.add(typeBytes);

    // Payload data
    builder.add(data);

    // CRC32 over type + data
    final crcInput = [...typeBytes, ...data];
    final crc = Crc32.calculate(crcInput);

    builder.add([
      (crc >> 24) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 8) & 0xFF,
      crc & 0xFF,
    ]);
  }
}
