// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بدّل';

  @override
  String get appSubtitle => 'تغيير بصمة الملفات محلياً دون أي فقد للجودة';

  @override
  String get onboardingTitle => 'مرحباً بك في بدّل';

  @override
  String get onboardingDescription =>
      'تطبيق لتغيير بصمة الملفات (الهاش وبيانات الـ metadata) محلياً 100% دون أي رفع سحابي وبأعلى معايير الخصوصية.';

  @override
  String get onboardingDisclaimer =>
      'تنبيه: التطبيق يغيّر بصمة الملف (الهاش + metadata) فقط، ولا يزيل العلامات المائية المضمنة في البكسلات (مثل SynthID). الإفصاح عن المحتوى المولّد بالذكاء الاصطناعي مسؤولية المستخدم حسب سياسات المنصات التي ينشر عليها.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get next => 'التالي';

  @override
  String get selectLanguage => 'اختيار اللغة';

  @override
  String get selectTheme => 'اختيار المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'نهاري';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get dropFilesHere => 'اسحب الملفات هنا';

  @override
  String get dropFilesSubtitle =>
      'صور، فيديو، وأي ملف عادي. المعالجة على جهازك فقط.';

  @override
  String get selectFiles => 'اختيار ملفات';

  @override
  String get selectFolder => 'اختيار مجلد';

  @override
  String get pickMobileTitle => 'اختر الصور أو الفيديوهات أو الملفات';

  @override
  String get optionsTitle => 'الخيارات';

  @override
  String get removeMetadata => 'حذف الـ metadata';

  @override
  String get changeHashWithoutReencode => 'تغيير الهاش بدون إعادة ضغط';

  @override
  String get reencodeImages => 'إعادة ترميز الصور';

  @override
  String get encodingQuality => 'جودة الترميز';

  @override
  String get customMetadata => 'metadata مخصصة (الشركة، المؤلف)';

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get authorName => 'المؤلف';

  @override
  String get copyright => 'حقوق النشر';

  @override
  String get customMetadataHint => 'أدخل بيانات الميتاداتا المخصصة';

  @override
  String get outputFilenamePattern => 'قالب اسم الملف الناتج';

  @override
  String outputFilenamePatternHint(Object ext, Object name) {
    return 'مثال: \'$name\'_baddil.\'$ext\'';
  }

  @override
  String get outputFolder => 'مجلد الإخراج';

  @override
  String get outputFolderSelect => 'تحديد مجلد الإخراج';

  @override
  String get outputFolderDefault => 'تلقائي (نفس مجلد الملف أو التنزيلات)';

  @override
  String get startProcessing => 'ابدأ التغيير';

  @override
  String get cancelProcessing => 'إلغاء المعالجة';

  @override
  String get processingQueue => 'قائمة المعالجة';

  @override
  String get queueEmpty =>
      'لا توجد ملفات في قائمة المعالجة. اسحب الملفات أو اخترها أعلاه.';

  @override
  String get statusDone => 'تم';

  @override
  String get statusProcessing => 'قيد المعالجة';

  @override
  String get statusWaiting => 'بانتظار';

  @override
  String get statusError => 'خطأ';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get clearQueue => 'مسح القائمة';

  @override
  String get exportCsv => 'تصدير التقرير (CSV)';

  @override
  String get fileDetailsTitle => 'تقرير معالجة الملف';

  @override
  String get fileName => 'اسم الملف';

  @override
  String get fileSize => 'الحجم';

  @override
  String get fileSizeBefore => 'الحجم الأصلي';

  @override
  String get fileSizeAfter => 'الحجم بعد المعالجة';

  @override
  String get fingerprintBefore => 'البصمة القديمة';

  @override
  String get fingerprintAfter => 'البصمة الجديدة';

  @override
  String get fingerprintPending => 'بانتظار حساب البصمة…';

  @override
  String get fingerprintUnavailable => 'البصمة غير متاحة';

  @override
  String get fingerprintChanged => 'تم تغيير بصمة الملف';

  @override
  String get fingerprintUnchanged => 'لم تتغير بصمة الملف';

  @override
  String get hashBefore => 'SHA-256 قبل';

  @override
  String get hashAfter => 'SHA-256 بعد';

  @override
  String get md5Before => 'MD5 قبل';

  @override
  String get md5After => 'MD5 بعد';

  @override
  String get changesApplied => 'ما الذي تغيّر';

  @override
  String get copyHash => 'نسخ الهاش';

  @override
  String get hashCopied => 'تم نسخ الهاش إلى الحافظة بنجاح';

  @override
  String get close => 'إغلاق';

  @override
  String get unsupportedFfmpegWeb =>
      'معالجة صيغ MKV و WebM و AVI عبر FFmpeg غير متاحة على الويب. يتم دعم صيغ MP4 و MOV مباشرة بـ Dart خالص.';

  @override
  String get unsupportedFfmpegIos =>
      'معالجة صيغ MKV و WebM و AVI عبر FFmpeg غير متاحة على iOS. يتم دعم صيغ MP4 و MOV مباشرة بـ Dart خالص.';

  @override
  String get genericFileNotice =>
      'معالجة الملفات العادية (PDF, ZIP, إلخ) تعمل بإلحاق ذيل عشوائي (best-effort). يُنصح بفتح الملف للتأكد منه.';

  @override
  String get folderPickUnsupportedOnWeb =>
      'اختيار مجلد كامل غير مدعوم في متصفح الويب؛ يرجى اختيار ملفات متعددة.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get privacyAndSecurity => 'الخصوصية والأمان';

  @override
  String get privacyDescription =>
      'يعمل هذا التطبيق محلياً بالكامل على جهازك (Offline 100%). لا يتم رفع أي ملف، ولا يتم جمع أو إرسال أي بيانات، ولا توجد أي تحليلات أو إعلانات.';

  @override
  String get disclaimerTitle => 'الحدود وإخلاء المسؤولية';

  @override
  String get disclaimerText =>
      'التطبيق يغيّر بصمة الملف (الهاش + metadata) فقط. لا يزيل العلامات المائية غير المرئية داخل البكسلات (مثل SynthID) ولا يعدّل البكسلات خلسة. الإفصاح عن المحتوى المولّد بالذكاء الاصطناعي مسؤولية المستخدم حسب سياسات المنصات التي ينشر عليها.';

  @override
  String get developerSection => 'المطور';

  @override
  String get developer => 'المطور';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get launchUrlError => 'تعذر فتح الرابط المطلوب';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get noFilesSelected => 'لم يتم اختيار أي ملفات';

  @override
  String get exportSuccess => 'تم تصدير التقرير بنجاح';

  @override
  String get processingComplete => 'اكتملت معالجة كافة الملفات بنجاح';

  @override
  String get processingFailed => 'فشلت معالجة بعض الملفات';

  @override
  String get batchProcessingTitle => 'جاري معالجة وتعديل الملفات...';

  @override
  String get batchProcessingSubtitle =>
      'يتم تعديل البصمة وحذف البيانات دون أي مساس بالجودة';

  @override
  String get allCompletedTitle => 'اكتملت المعالجة بنجاح!';

  @override
  String get allCompletedSubtitle =>
      'تم تغيير بصمات الملفات بالكامل وجاهزة للاستخدام';

  @override
  String get dismiss => 'إغلاق';
}
