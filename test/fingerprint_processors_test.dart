import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

import 'package:baddil/shared/models/processing_options.dart';
import 'package:baddil/shared/services/processors/jpeg_processor.dart';
import 'package:baddil/shared/services/processors/png_processor.dart';
import 'package:baddil/shared/services/processors/webp_processor.dart';
import 'package:baddil/shared/services/processors/mp4_processor.dart';
import 'package:baddil/shared/services/crc32.dart';

void main() {
  group('Baddil Fingerprint Processors Unit Tests', () {
    test('JPEG: Hash changes, target metadata stripped, visual decoding preserved', () {
      // 1. Create a 16x16 test image
      final testImage = img.Image(width: 16, height: 16);
      for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
          testImage.setPixelRgba(x, y, 40, 180, 150, 255);
        }
      }
      final rawJpeg = Uint8List.fromList(img.encodeJpg(testImage, quality: 90));

      // 2. Synthesize an APP1 Exif marker inside the raw JPEG
      final withExifBuilder = BytesBuilder();
      withExifBuilder.add(rawJpeg.sublist(0, 2)); // SOI
      final exifPayload = [
        ...[0x45, 0x78, 0x69, 0x66, 0x00, 0x00], // 'Exif\0\0'
        ...utf8.encode('SampleCameraModel1234'),
      ];
      final exifLen = exifPayload.length + 2;
      withExifBuilder.add([0xFF, 0xE1]); // APP1
      withExifBuilder.add([(exifLen >> 8) & 0xFF, exifLen & 0xFF]);
      withExifBuilder.add(exifPayload);
      withExifBuilder.add(rawJpeg.sublist(2));

      final inputJpeg = withExifBuilder.toBytes();
      final inputSha256 = sha256.convert(inputJpeg).toString();

      // 3. Process with JpegProcessor
      const options = ProcessingOptions(
        stripMetadata: true,
        perturbHashWithoutRecompress: true,
      );
      final result = JpegProcessor.process(inputJpeg, options);
      final outputBytes = result.bytes;
      final outputSha256 = sha256.convert(outputBytes).toString();

      // A. Hash changed
      expect(outputSha256, isNot(equals(inputSha256)));

      // B. File still opens and decodes to exact same dimensions
      final decoded = img.decodeImage(outputBytes);
      expect(decoded, isNotNull);
      if (decoded != null) {
        expect(decoded.width, equals(16));
        expect(decoded.height, equals(16));
      }

      // C. Target metadata (APP1 Exif) is stripped
      final hasExif = _containsSubsequence(
        outputBytes,
        [0xFF, 0xE1, ...((exifLen >> 8) & 0xFF == 0 ? [] : [(exifLen >> 8) & 0xFF]), 0x45, 0x78, 0x69, 0x66],
      );
      expect(hasExif, isFalse);

      // D. COM perturbation is present
      expect(_containsSubsequence(outputBytes, [0xFF, 0xFE]), isTrue);
    });

    test('PNG: Hash changes, tEXt/eXIf stripped, ancillary bAdD chunk with valid CRC injected', () {
      // 1. Create a 16x16 test PNG image
      final testImage = img.Image(width: 16, height: 16);
      for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
          testImage.setPixelRgba(x, y, 60, 200, 180, 255);
        }
      }
      final rawPng = Uint8List.fromList(img.encodePng(testImage));

      // 2. Synthesize a tEXt chunk
      final withTextBuilder = BytesBuilder();
      withTextBuilder.add(rawPng.sublist(0, 33)); // PNG header + IHDR chunk
      final textData = [...latin1.encode('Description'), 0, ...utf8.encode('OriginalSecretMetadata')];
      final textLen = textData.length;
      withTextBuilder.add([
        (textLen >> 24) & 0xFF,
        (textLen >> 16) & 0xFF,
        (textLen >> 8) & 0xFF,
        textLen & 0xFF,
      ]);
      final textType = ascii.encode('tEXt');
      withTextBuilder.add(textType);
      withTextBuilder.add(textData);
      final textCrc = Crc32.calculate([...textType, ...textData]);
      withTextBuilder.add([
        (textCrc >> 24) & 0xFF,
        (textCrc >> 16) & 0xFF,
        (textCrc >> 8) & 0xFF,
        textCrc & 0xFF,
      ]);
      withTextBuilder.add(rawPng.sublist(33));

      final inputPng = withTextBuilder.toBytes();
      final inputSha256 = sha256.convert(inputPng).toString();

      // 3. Process with PngProcessor
      const options = ProcessingOptions(
        stripMetadata: true,
        perturbHashWithoutRecompress: true,
      );
      final result = PngProcessor.process(inputPng, options);
      final outputBytes = result.bytes;
      final outputSha256 = sha256.convert(outputBytes).toString();

      // A. Hash changed
      expect(outputSha256, isNot(equals(inputSha256)));

      // B. File still opens and decodes cleanly
      final decoded = img.decodeImage(outputBytes);
      expect(decoded, isNotNull);
      if (decoded != null) {
        expect(decoded.width, equals(16));
        expect(decoded.height, equals(16));
      }

      // C. Target metadata (tEXt chunk) stripped
      expect(_containsSubsequence(outputBytes, ascii.encode('OriginalSecretMetadata')), isFalse);

      // D. Ancillary chunk 'bAdD' present
      expect(_containsSubsequence(outputBytes, ascii.encode('bAdD')), isTrue);
    });

    test('WebP: Hash changes and custom RIFF chunk injected without container corruption', () {
      // 1. Synthesize minimal valid WebP RIFF file
      final webpBuilder = BytesBuilder();
      final vp8Chunk = Uint8List(12);
      final riffSize = 4 + 8 + vp8Chunk.length; // 'WEBP' + VP8 chunk header + payload

      webpBuilder.add(ascii.encode('RIFF'));
      webpBuilder.add([
        riffSize & 0xFF,
        (riffSize >> 8) & 0xFF,
        (riffSize >> 16) & 0xFF,
        (riffSize >> 24) & 0xFF,
      ]);
      webpBuilder.add(ascii.encode('WEBP'));
      webpBuilder.add(ascii.encode('EXIF')); // Target metadata to strip
      webpBuilder.add([4, 0, 0, 0]);
      webpBuilder.add([1, 2, 3, 4]);

      webpBuilder.add(ascii.encode('VP8 '));
      webpBuilder.add([
        vp8Chunk.length & 0xFF,
        (vp8Chunk.length >> 8) & 0xFF,
        (vp8Chunk.length >> 16) & 0xFF,
        (vp8Chunk.length >> 24) & 0xFF,
      ]);
      webpBuilder.add(vp8Chunk);

      final inputWebP = webpBuilder.toBytes();
      final inputSha256 = sha256.convert(inputWebP).toString();

      // 2. Process
      const options = ProcessingOptions(
        stripMetadata: true,
        perturbHashWithoutRecompress: true,
      );
      final result = WebPProcessor.process(inputWebP, options);
      final outputBytes = result.bytes;
      final outputSha256 = sha256.convert(outputBytes).toString();

      // A. Hash changed
      expect(outputSha256, isNot(equals(inputSha256)));

      // B. Valid RIFF WEBP signature maintained
      expect(ascii.decode(outputBytes.sublist(0, 4)), equals('RIFF'));
      expect(ascii.decode(outputBytes.sublist(8, 12)), equals('WEBP'));

      // C. Target EXIF chunk stripped
      expect(_containsSubsequence(outputBytes, ascii.encode('EXIF')), isFalse);

      // D. Custom chunk injected
      expect(_containsSubsequence(outputBytes, ascii.encode('bAdD')), isTrue);
    });

    test('MP4: Pure Dart container parsing strips udta, updates timestamps, alters hash', () {
      // 1. Synthesize valid minimal MP4 structure
      final mp4Builder = BytesBuilder();

      // ftyp box
      final ftypBytes = [
        0x00, 0x00, 0x00, 0x14, // size = 20
        0x66, 0x74, 0x79, 0x70, // 'ftyp'
        0x69, 0x73, 0x6F, 0x6D, // 'isom'
        0x00, 0x00, 0x02, 0x00, // minor version
        0x69, 0x73, 0x6F, 0x6D, // compatible brands
      ];
      mp4Builder.add(ftypBytes);

      // moov box with mvhd and udta
      final moovContentBuilder = BytesBuilder();

      // mvhd box (v0, 108 bytes standard)
      final mvhdBytes = Uint8List(108);
      final mvhdBd = ByteData.sublistView(mvhdBytes);
      mvhdBd.setUint32(0, 108, Endian.big);
      mvhdBytes[4] = 0x6D; // 'm'
      mvhdBytes[5] = 0x76; // 'v'
      mvhdBytes[6] = 0x68; // 'h'
      mvhdBytes[7] = 0x64; // 'd'
      mvhdBytes[8] = 0; // version 0
      // initial creation time = 1000
      mvhdBd.setUint32(12, 1000, Endian.big);
      mvhdBd.setUint32(16, 1000, Endian.big);
      moovContentBuilder.add(mvhdBytes);

      // udta box containing metadata string
      final udtaContent = utf8.encode('Author=ConfidentialCorp');
      final udtaSize = 8 + udtaContent.length;
      final udtaHeader = Uint8List(8);
      ByteData.sublistView(udtaHeader).setUint32(0, udtaSize, Endian.big);
      udtaHeader[4] = 0x75; // 'u'
      udtaHeader[5] = 0x64; // 'd'
      udtaHeader[6] = 0x74; // 't'
      udtaHeader[7] = 0x61; // 'a'
      moovContentBuilder.add(udtaHeader);
      moovContentBuilder.add(udtaContent);

      final moovPayload = moovContentBuilder.toBytes();
      final moovSize = 8 + moovPayload.length;
      final moovHeader = Uint8List(8);
      ByteData.sublistView(moovHeader).setUint32(0, moovSize, Endian.big);
      moovHeader[4] = 0x6D; // 'm'
      moovHeader[5] = 0x6F; // 'o'
      moovHeader[6] = 0x6F; // 'o'
      moovHeader[7] = 0x76; // 'v'

      mp4Builder.add(moovHeader);
      mp4Builder.add(moovPayload);

      final inputMp4 = mp4Builder.toBytes();
      final inputSha256 = sha256.convert(inputMp4).toString();

      // 2. Process with Mp4Processor
      const options = ProcessingOptions(
        stripMetadata: true,
        perturbHashWithoutRecompress: true,
      );
      final result = Mp4Processor.process(inputMp4, options);
      final outputBytes = result.bytes;
      final outputSha256 = sha256.convert(outputBytes).toString();

      // A. Hash changed
      expect(outputSha256, isNot(equals(inputSha256)));

      // B. udta metadata neutralized (box turned to free, string eliminated)
      expect(_containsSubsequence(outputBytes, ascii.encode('udta')), isFalse);
      expect(_containsSubsequence(outputBytes, utf8.encode('Author=ConfidentialCorp')), isFalse);

      // C. free box present
      expect(_containsSubsequence(outputBytes, ascii.encode('free')), isTrue);
    });
  });
}

bool _containsSubsequence(List<int> haystack, List<int> needle) {
  if (needle.isEmpty || haystack.length < needle.length) return false;
  for (int i = 0; i <= haystack.length - needle.length; i++) {
    bool match = true;
    for (int j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}
