import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageReencoder {
  static Uint8List? reencode(Uint8List inputBytes, String fileName, int quality) {
    try {
      final decoded = img.decodeImage(inputBytes);
      if (decoded == null) return null;

      final lower = fileName.toLowerCase();
      if (lower.endsWith('.png')) {
        return Uint8List.fromList(img.encodePng(decoded));
      } else {
        // Default to JPEG
        return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
      }
    } catch (_) {
      return null;
    }
  }
}
