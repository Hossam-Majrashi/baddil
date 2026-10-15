import 'package:baddil/core/constants/app_constants.dart';

class ProcessingOptions {
  final bool stripMetadata;
  final bool perturbHashWithoutRecompress;
  final bool reencodeImages;
  final int imageQuality;
  final bool customMetadataEnabled;
  final String companyName;
  final String authorName;
  final String copyright;
  final String outputFilenamePattern;
  final String? outputDirectory;

  const ProcessingOptions({
    this.stripMetadata = true,
    this.perturbHashWithoutRecompress = true,
    this.reencodeImages = false,
    this.imageQuality = 85,
    this.customMetadataEnabled = false,
    this.companyName = '',
    this.authorName = '',
    this.copyright = '',
    this.outputFilenamePattern = AppConstants.defaultFilenamePattern,
    this.outputDirectory,
  });

  ProcessingOptions copyWith({
    bool? stripMetadata,
    bool? perturbHashWithoutRecompress,
    bool? reencodeImages,
    int? imageQuality,
    bool? customMetadataEnabled,
    String? companyName,
    String? authorName,
    String? copyright,
    String? outputFilenamePattern,
    String? outputDirectory,
  }) {
    return ProcessingOptions(
      stripMetadata: stripMetadata ?? this.stripMetadata,
      perturbHashWithoutRecompress:
          perturbHashWithoutRecompress ?? this.perturbHashWithoutRecompress,
      reencodeImages: reencodeImages ?? this.reencodeImages,
      imageQuality: imageQuality ?? this.imageQuality,
      customMetadataEnabled:
          customMetadataEnabled ?? this.customMetadataEnabled,
      companyName: companyName ?? this.companyName,
      authorName: authorName ?? this.authorName,
      copyright: copyright ?? this.copyright,
      outputFilenamePattern:
          outputFilenamePattern ?? this.outputFilenamePattern,
      outputDirectory: outputDirectory ?? this.outputDirectory,
    );
  }
}
