import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:baddil/shared/models/processing_options.dart';

class GenericProcessingResult {
  final Uint8List bytes;
  final List<String> changes;

  const GenericProcessingResult({required this.bytes, required this.changes});
}

class GenericFileProcessor {
  static GenericProcessingResult process(
    Uint8List input,
    String fileName,
    ProcessingOptions options,
  ) {
    final changes = <String>[];
    final outputBuilder = BytesBuilder();
    outputBuilder.add(input);

    if (options.perturbHashWithoutRecompress) {
      final random = Random.secure();
      final nonceHex = List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

      final lowerName = fileName.toLowerCase();
      if (lowerName.endsWith('.pdf')) {
        // For PDF, standard conformant readers ignore data following the final %%EOF
        final trailer = utf8.encode('\n%%BADDIL_NONCE_$nonceHex\n%%EOF\n');
        outputBuilder.add(trailer);
        changes.add('Appended post-EOF PDF trailer with safe nonce');
      } else {
        // For ZIP / generic documents, append trailer comment/nonce
        final trailer = utf8.encode('\n# BADDIL_NONCE_$nonceHex\n');
        outputBuilder.add(trailer);
        changes.add('Appended generic trailer nonce');
      }
    } else {
      changes.add('Calculated hashes without modifying payload');
    }

    return GenericProcessingResult(
      bytes: outputBuilder.toBytes(),
      changes: changes,
    );
  }
}
