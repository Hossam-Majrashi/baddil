// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baddil';

  @override
  String get appSubtitle =>
      'Local file fingerprint modifier with zero quality loss';

  @override
  String get onboardingTitle => 'Welcome to Baddil';

  @override
  String get onboardingDescription =>
      'Modify file fingerprints (hash and metadata) 100% locally with zero cloud upload and complete privacy.';

  @override
  String get onboardingDisclaimer =>
      'Notice: This app modifies file fingerprints (hash + metadata) only. It does not strip deep in-pixel watermarks (e.g. SynthID). Disclosing AI-generated content is your responsibility according to the policies of the platforms you publish to.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System Default';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get dropFilesHere => 'Drop files here';

  @override
  String get dropFilesSubtitle =>
      'Images, videos, and regular files. Processed on your device only.';

  @override
  String get selectFiles => 'Choose Files';

  @override
  String get selectFolder => 'Choose Folder';

  @override
  String get pickMobileTitle => 'Select Images, Videos or Files';

  @override
  String get optionsTitle => 'Options';

  @override
  String get removeMetadata => 'Remove metadata';

  @override
  String get changeHashWithoutReencode => 'Change hash without recompression';

  @override
  String get reencodeImages => 'Re-encode images';

  @override
  String get encodingQuality => 'Encoding quality';

  @override
  String get customMetadata => 'Custom metadata (Company, Author)';

  @override
  String get companyName => 'Company Name';

  @override
  String get authorName => 'Author Name';

  @override
  String get copyright => 'Copyright';

  @override
  String get customMetadataHint => 'Enter custom metadata values';

  @override
  String get outputFilenamePattern => 'Output filename template';

  @override
  String outputFilenamePatternHint(Object ext, Object name) {
    return 'e.g. \'$name\'_baddil.\'$ext\'';
  }

  @override
  String get outputFolder => 'Output Folder';

  @override
  String get outputFolderSelect => 'Choose output folder';

  @override
  String get outputFolderDefault => 'Default (Source folder or Downloads)';

  @override
  String get startProcessing => 'Start Processing';

  @override
  String get cancelProcessing => 'Cancel Processing';

  @override
  String get processingQueue => 'Processing Queue';

  @override
  String get queueEmpty =>
      'No files in the queue yet. Drag and drop or choose files above.';

  @override
  String get statusDone => 'Done';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusError => 'Error';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get clearQueue => 'Clear Queue';

  @override
  String get exportCsv => 'Export Report (CSV)';

  @override
  String get fileDetailsTitle => 'File Processing Report';

  @override
  String get fileName => 'File Name';

  @override
  String get fileSize => 'Size';

  @override
  String get fileSizeBefore => 'Original Size';

  @override
  String get fileSizeAfter => 'Processed Size';

  @override
  String get fingerprintBefore => 'Old fingerprint';

  @override
  String get fingerprintAfter => 'New fingerprint';

  @override
  String get fingerprintPending => 'Waiting for fingerprint…';

  @override
  String get fingerprintUnavailable => 'Fingerprint unavailable';

  @override
  String get fingerprintChanged => 'File fingerprint changed';

  @override
  String get fingerprintUnchanged => 'File fingerprint unchanged';

  @override
  String get hashBefore => 'SHA-256 Before';

  @override
  String get hashAfter => 'SHA-256 After';

  @override
  String get md5Before => 'MD5 Before';

  @override
  String get md5After => 'MD5 After';

  @override
  String get changesApplied => 'Changes Applied';

  @override
  String get copyHash => 'Copy Hash';

  @override
  String get hashCopied => 'Hash copied to clipboard';

  @override
  String get close => 'Close';

  @override
  String get unsupportedFfmpegWeb =>
      'MKV, WebM, and AVI container stripping via FFmpeg is unavailable on Web. MP4 and MOV are supported natively.';

  @override
  String get unsupportedFfmpegIos =>
      'MKV, WebM, and AVI container stripping via FFmpeg is unavailable on iOS. MP4 and MOV are supported natively.';

  @override
  String get genericFileNotice =>
      'Generic files (PDF, ZIP, docs) are processed by appending a safe trailer (best-effort). Please verify the file after processing.';

  @override
  String get folderPickUnsupportedOnWeb =>
      'Folder selection is not supported in web browsers; please pick files directly.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get aboutApp => 'About App';

  @override
  String get appVersion => 'Version';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get privacyDescription =>
      'This application runs entirely on your local machine (100% Offline). No files are uploaded, no telemetry or analytics are collected, and no ads are displayed.';

  @override
  String get disclaimerTitle => 'Boundaries & Disclaimer';

  @override
  String get disclaimerText =>
      'Baddil modifies file fingerprints (hash + metadata) only. It does not remove imperceptible in-pixel watermarks (such as SynthID) and does not silently alter pixels. Disclosure of AI-generated content is user responsibility according to the policies of the platforms you publish to.';

  @override
  String get developerSection => 'Developer';

  @override
  String get developer => 'Developer';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get launchUrlError => 'Could not launch link';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get noFilesSelected => 'No files selected';

  @override
  String get exportSuccess => 'Report exported successfully';

  @override
  String get processingComplete => 'Processing completed for all files';

  @override
  String get processingFailed => 'Processing failed for one or more files';

  @override
  String get batchProcessingTitle => 'Processing files...';

  @override
  String get batchProcessingSubtitle =>
      'Applying fingerprint modifications without loss';

  @override
  String get allCompletedTitle => 'Processing Completed Successfully!';

  @override
  String get allCompletedSubtitle =>
      'All fingerprints have been updated with zero quality loss';

  @override
  String get dismiss => 'Dismiss';
}
