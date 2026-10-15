import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:baddil/shared/models/processing_options.dart';

class JpegProcessingResult {
  final Uint8List bytes;
  final List<String> changes;

  const JpegProcessingResult({required this.bytes, required this.changes});
}

class JpegProcessor {
  static bool isJpeg(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0xFF && bytes[1] == 0xD8;
  }

  static JpegProcessingResult process(
    Uint8List input,
    ProcessingOptions options,
  ) {
    if (!isJpeg(input)) {
      throw FormatException('Input is not a valid JPEG stream');
    }

    final changes = <String>[];
    final outputBuilder = BytesBuilder();

    // Write SOI (0xFF, 0xD8)
    outputBuilder.add([0xFF, 0xD8]);

    int offset = 2;
    final totalLen = input.length;

    // Optional COM perturbation payload
    if (options.perturbHashWithoutRecompress) {
      final random = Random.secure();
      final nonceBytes = List<int>.generate(24, (_) => random.nextInt(256));
      final comPayload = utf8.encode('baddil:${DateTime.now().millisecondsSinceEpoch}:') + nonceBytes;
      final segLength = comPayload.length + 2;

      outputBuilder.add([0xFF, 0xFE]); // COM marker
      outputBuilder.add([(segLength >> 8) & 0xFF, segLength & 0xFF]);
      outputBuilder.add(comPayload);
      changes.add('Added unique COM perturbation chunk');
    }

    if (options.customMetadataEnabled) {
      final metaString = 'Company=${options.companyName};Author=${options.authorName};Copyright=${options.copyright}';
      final metaBytes = utf8.encode('baddil-meta:$metaString');
      final segLength = metaBytes.length + 2;

      outputBuilder.add([0xFF, 0xFE]); // Custom COM marker
      outputBuilder.add([(segLength >> 8) & 0xFF, segLength & 0xFF]);
      outputBuilder.add(metaBytes);
      changes.add('Injected custom metadata');
    }

    while (offset < totalLen) {
      if (input[offset] != 0xFF) {
        // Raw scan data until next marker
        final nextMarker = _findNextMarker(input, offset);
        if (nextMarker == -1) {
          outputBuilder.add(input.sublist(offset));
          break;
        } else {
          outputBuilder.add(input.sublist(offset, nextMarker));
          offset = nextMarker;
        }
        continue;
      }

      // Check marker byte
      if (offset + 1 >= totalLen) {
        outputBuilder.add(input.sublist(offset));
        break;
      }

      final marker = input[offset + 1];

      // Byte stuffing (0xFF, 0x00) or restart markers (0xD0-0xD7)
      if (marker == 0x00 || (marker >= 0xD0 && marker <= 0xD7)) {
        outputBuilder.add(input.sublist(offset, offset + 2));
        offset += 2;
        continue;
      }

      // EOI (End of Image)
      if (marker == 0xD9) {
        outputBuilder.add([0xFF, 0xD9]);
        break;
      }

      // Length follows marker (2 bytes, big-endian)
      if (offset + 3 >= totalLen) {
        outputBuilder.add(input.sublist(offset));
        break;
      }

      final segLength = (input[offset + 2] << 8) | input[offset + 3];
      final segEnd = offset + 2 + segLength;
      if (segEnd > totalLen) {
        outputBuilder.add(input.sublist(offset));
        break;
      }

      bool shouldStrip = false;

      if (options.stripMetadata) {
        // APP1 (EXIF / XMP)
        if (marker == 0xE1) {
          final segData = input.sublist(offset + 4, segEnd);
          if (_matchesPrefix(segData, [0x45, 0x78, 0x69, 0x66, 0x00, 0x00])) {
            shouldStrip = true;
            changes.add('Removed EXIF metadata (APP1)');
          } else if (_matchesPrefix(segData, utf8.encode('http://ns.adobe.com/xap/1.0/'))) {
            shouldStrip = true;
            changes.add('Removed XMP metadata (APP1)');
          }
        }
        // APP11 (C2PA / Content Credentials / JUMBF)
        else if (marker == 0xEB) {
          shouldStrip = true;
          changes.add('Removed C2PA Content Credentials (APP11)');
        }
        // APP13 (IPTC / Photoshop 3.0)
        else if (marker == 0xED) {
          final segData = input.sublist(offset + 4, segEnd);
          if (_matchesPrefix(segData, utf8.encode('Photoshop 3.0'))) {
            shouldStrip = true;
            changes.add('Removed IPTC/Photoshop metadata (APP13)');
          }
        }
        // COM (Old comments)
        else if (marker == 0xFE) {
          shouldStrip = true;
          changes.add('Removed legacy comments (COM)');
        }
      }

      // SOS (Start of Scan) - scan data begins immediately after SOS header
      if (marker == 0xDA) {
        outputBuilder.add(input.sublist(offset, segEnd));
        offset = segEnd;
        // Remaining bytes until EOI are scan data
        final eoiPos = _findMarker(input, offset, 0xD9);
        if (eoiPos != -1) {
          outputBuilder.add(input.sublist(offset, eoiPos));
          outputBuilder.add([0xFF, 0xD9]);
          break;
        } else {
          outputBuilder.add(input.sublist(offset));
          break;
        }
      }

      if (!shouldStrip) {
        outputBuilder.add(input.sublist(offset, segEnd));
      }

      offset = segEnd;
    }

    return JpegProcessingResult(
      bytes: outputBuilder.toBytes(),
      changes: changes.isEmpty ? ['Cleaned JPEG structure'] : changes,
    );
  }

  static bool _matchesPrefix(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  static int _findNextMarker(Uint8List data, int start) {
    for (int i = start; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] != 0x00) {
        return i;
      }
    }
    return -1;
  }

  static int _findMarker(Uint8List data, int start, int markerByte) {
    for (int i = start; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] == markerByte) {
        return i;
      }
    }
    return -1;
  }
}
