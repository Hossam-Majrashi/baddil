import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Baddil'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local file fingerprint modifier with zero quality loss'**
  String get appSubtitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Baddil'**
  String get onboardingTitle;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Modify file fingerprints (hash and metadata) 100% locally with zero cloud upload and complete privacy.'**
  String get onboardingDescription;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Notice: This app modifies file fingerprints (hash + metadata) only. It does not strip deep in-pixel watermarks (e.g. SynthID). Disclosing AI-generated content is your responsibility according to the policies of the platforms you publish to.'**
  String get onboardingDisclaimer;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @dropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here'**
  String get dropFilesHere;

  /// No description provided for @dropFilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Images, videos, and regular files. Processed on your device only.'**
  String get dropFilesSubtitle;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose Files'**
  String get selectFiles;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get selectFolder;

  /// No description provided for @pickMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Images, Videos or Files'**
  String get pickMobileTitle;

  /// No description provided for @optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsTitle;

  /// No description provided for @removeMetadata.
  ///
  /// In en, this message translates to:
  /// **'Remove metadata'**
  String get removeMetadata;

  /// No description provided for @changeHashWithoutReencode.
  ///
  /// In en, this message translates to:
  /// **'Change hash without recompression'**
  String get changeHashWithoutReencode;

  /// No description provided for @reencodeImages.
  ///
  /// In en, this message translates to:
  /// **'Re-encode images'**
  String get reencodeImages;

  /// No description provided for @encodingQuality.
  ///
  /// In en, this message translates to:
  /// **'Encoding quality'**
  String get encodingQuality;

  /// No description provided for @customMetadata.
  ///
  /// In en, this message translates to:
  /// **'Custom metadata (Company, Author)'**
  String get customMetadata;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Author Name'**
  String get authorName;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @customMetadataHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom metadata values'**
  String get customMetadataHint;

  /// No description provided for @outputFilenamePattern.
  ///
  /// In en, this message translates to:
  /// **'Output filename template'**
  String get outputFilenamePattern;

  /// No description provided for @outputFilenamePatternHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \'{name}\'_baddil.\'{ext}\''**
  String outputFilenamePatternHint(Object ext, Object name);

  /// No description provided for @outputFolder.
  ///
  /// In en, this message translates to:
  /// **'Output Folder'**
  String get outputFolder;

  /// No description provided for @outputFolderSelect.
  ///
  /// In en, this message translates to:
  /// **'Choose output folder'**
  String get outputFolderSelect;

  /// No description provided for @outputFolderDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (Source folder or Downloads)'**
  String get outputFolderDefault;

  /// No description provided for @startProcessing.
  ///
  /// In en, this message translates to:
  /// **'Start Processing'**
  String get startProcessing;

  /// No description provided for @cancelProcessing.
  ///
  /// In en, this message translates to:
  /// **'Cancel Processing'**
  String get cancelProcessing;

  /// No description provided for @processingQueue.
  ///
  /// In en, this message translates to:
  /// **'Processing Queue'**
  String get processingQueue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No files in the queue yet. Drag and drop or choose files above.'**
  String get queueEmpty;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear Queue'**
  String get clearQueue;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Report (CSV)'**
  String get exportCsv;

  /// No description provided for @fileDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'File Processing Report'**
  String get fileDetailsTitle;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fileSize;

  /// No description provided for @fileSizeBefore.
  ///
  /// In en, this message translates to:
  /// **'Original Size'**
  String get fileSizeBefore;

  /// No description provided for @fileSizeAfter.
  ///
  /// In en, this message translates to:
  /// **'Processed Size'**
  String get fileSizeAfter;

  /// No description provided for @fingerprintBefore.
  ///
  /// In en, this message translates to:
  /// **'Old fingerprint'**
  String get fingerprintBefore;

  /// No description provided for @fingerprintAfter.
  ///
  /// In en, this message translates to:
  /// **'New fingerprint'**
  String get fingerprintAfter;

  /// No description provided for @fingerprintPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for fingerprint…'**
  String get fingerprintPending;

  /// No description provided for @fingerprintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint unavailable'**
  String get fingerprintUnavailable;

  /// No description provided for @fingerprintChanged.
  ///
  /// In en, this message translates to:
  /// **'File fingerprint changed'**
  String get fingerprintChanged;

  /// No description provided for @fingerprintUnchanged.
  ///
  /// In en, this message translates to:
  /// **'File fingerprint unchanged'**
  String get fingerprintUnchanged;

  /// No description provided for @hashBefore.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 Before'**
  String get hashBefore;

  /// No description provided for @hashAfter.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 After'**
  String get hashAfter;

  /// No description provided for @md5Before.
  ///
  /// In en, this message translates to:
  /// **'MD5 Before'**
  String get md5Before;

  /// No description provided for @md5After.
  ///
  /// In en, this message translates to:
  /// **'MD5 After'**
  String get md5After;

  /// No description provided for @changesApplied.
  ///
  /// In en, this message translates to:
  /// **'Changes Applied'**
  String get changesApplied;

  /// No description provided for @copyHash.
  ///
  /// In en, this message translates to:
  /// **'Copy Hash'**
  String get copyHash;

  /// No description provided for @hashCopied.
  ///
  /// In en, this message translates to:
  /// **'Hash copied to clipboard'**
  String get hashCopied;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unsupportedFfmpegWeb.
  ///
  /// In en, this message translates to:
  /// **'MKV, WebM, and AVI container stripping via FFmpeg is unavailable on Web. MP4 and MOV are supported natively.'**
  String get unsupportedFfmpegWeb;

  /// No description provided for @unsupportedFfmpegIos.
  ///
  /// In en, this message translates to:
  /// **'MKV, WebM, and AVI container stripping via FFmpeg is unavailable on iOS. MP4 and MOV are supported natively.'**
  String get unsupportedFfmpegIos;

  /// No description provided for @genericFileNotice.
  ///
  /// In en, this message translates to:
  /// **'Generic files (PDF, ZIP, docs) are processed by appending a safe trailer (best-effort). Please verify the file after processing.'**
  String get genericFileNotice;

  /// No description provided for @folderPickUnsupportedOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Folder selection is not supported in web browsers; please pick files directly.'**
  String get folderPickUnsupportedOnWeb;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'This application runs entirely on your local machine (100% Offline). No files are uploaded, no telemetry or analytics are collected, and no ads are displayed.'**
  String get privacyDescription;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Boundaries & Disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Baddil modifies file fingerprints (hash + metadata) only. It does not remove imperceptible in-pixel watermarks (such as SynthID) and does not silently alter pixels. Disclosure of AI-generated content is user responsibility according to the policies of the platforms you publish to.'**
  String get disclaimerText;

  /// No description provided for @developerSection.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerSection;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @launchUrlError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch link'**
  String get launchUrlError;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No files selected'**
  String get noFilesSelected;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get exportSuccess;

  /// No description provided for @processingComplete.
  ///
  /// In en, this message translates to:
  /// **'Processing completed for all files'**
  String get processingComplete;

  /// No description provided for @processingFailed.
  ///
  /// In en, this message translates to:
  /// **'Processing failed for one or more files'**
  String get processingFailed;

  /// No description provided for @batchProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing files...'**
  String get batchProcessingTitle;

  /// No description provided for @batchProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applying fingerprint modifications without loss'**
  String get batchProcessingSubtitle;

  /// No description provided for @allCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Completed Successfully!'**
  String get allCompletedTitle;

  /// No description provided for @allCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All fingerprints have been updated with zero quality loss'**
  String get allCompletedSubtitle;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
