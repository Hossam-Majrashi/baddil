# بدّل — Baddil

[العربية](#arabic) · [English](#english)

<a id="arabic"></a>

## العربية

**بدّل** تطبيق Flutter لتغيير بصمة الملفات محلياً، مع عرض البصمة القديمة والجديدة ومقارنتهما. يعمل على Android وiOS وLinux وWindows وmacOS والويب، وتتم المعالجة على جهازك دون رفع الملفات إلى خادم.

<a id="home-screen"></a>

### الصفحة الرئيسية

<img width="1920" height="1039" alt="الصفحة الرئيسية لتطبيق بدّل — Baddil home screen" src="https://github.com/user-attachments/assets/fe267468-b0b8-477e-89b5-a84a19feaa44" />

### المميزات

- عرض **البصمة القديمة** بمجرد اختيار الملف، بعد اكتمال حسابها.
- عرض **البصمة الجديدة** بعد المعالجة، مع إبقاء القديمة للمقارنة.
- عرض قيم **SHA-256 وMD5** كاملة، مع إمكانية تحديدها ونسخها.
- إزالة بيانات metadata المدعومة، وتغيير الهاش دون إعادة ضغط للصيغ المدعومة.
- معالجة JPEG وPNG وWebP وMP4 وMOV بخوارزميات Dart محلية.
- إعادة ترميز الصور اختيارياً، مع ضبط جودة JPEG.
- معالجة عدة ملفات، واختيار المجلدات على المنصات الأصلية، والسحب والإفلات على سطح المكتب والويب.
- تقرير لكل ملف يعرض الأحجام والبصمات والتغييرات ومسار الإخراج.
- تخصيص اسم الملف الناتج ومجلد الحفظ، وتصدير تقرير CSV على المنصات الأصلية.
- واجهة عربية وإنجليزية، مع المظهر الفاتح والداكن ومظهر النظام.
- إنشاء ملف جديد بدلاً من استبدال الملف الأصلي.

### طريقة الاستخدام

1. اختر الملفات أو اسحبها إلى التطبيق.
2. انتظر ظهور **البصمة القديمة** لكل ملف؛ لا تحتاج إلى بدء المعالجة لحسابها.
3. اضبط خيارات حذف metadata وتغيير الهاش وإعادة الترميز حسب الحاجة.
4. اضغط **«ابدأ التغيير»**.
5. بعد المعالجة، تظهر **البصمة القديمة** و**البصمة الجديدة** للمقارنة والنسخ.
6. انقر على الملف لفتح تقرير التفاصيل. على المنصات الأصلية، يُحفظ الناتج في مجلد المصدر أو المجلد الذي اخترته، مع اسم جديد.

### الصيغ والحدود

| الصيغة | طريقة المعالجة |
| --- | --- |
| JPEG | إزالة كتل metadata المدعومة وإضافة تعليق فريد لتغيير الهاش |
| PNG | إزالة كتل metadata المدعومة وإضافة chunk مخصص مع CRC32 |
| WebP | معالجة كتل RIFF المدعومة وإضافة chunk فريد |
| MP4 / MOV | معالجة صناديق الحاوية المدعومة وتعديل بياناتها دون إعادة ترميز الفيديو |
| PDF وZIP والملفات الأخرى | إلحاق بيانات فريدة بنهاية الملف بطريقة best-effort؛ يجب التحقق من الملف الناتج |

**ملاحظات مهمة:**

- تغيير الهاش دون إعادة ضغط لا يتطلب إعادة ترميز المحتوى في الصيغ المدعومة. تفعيل إعادة ترميز الصور قد يؤثر في الجودة.
- المعالجة العامة ليست ضماناً لتوافق كل صيغة؛ افتح الملف الناتج وتحقق منه قبل استخدامه.
- الويب يدعم اختيار عدة ملفات ومعالجتها محلياً، لكن اختيار مجلد والحفظ إلى مسار على القرص وتصدير ملف CSV غير متاحة في التنفيذ الحالي.
- التطبيق لا يزيل العلامات المائية غير المرئية داخل البكسلات، مثل SynthID.
- الإفصاح عن المحتوى المولّد بالذكاء الاصطناعي مسؤولية المستخدم وفق سياسات المنصات التي ينشر عليها.

### الخصوصية

تتم معالجة الملفات محلياً داخل التطبيق، دون رفع سحابي أو تحليلات أو إعلانات. الملفات الأصلية لا تُستبدل أثناء المعالجة.

### التشغيل للتطوير

يتطلب المشروع Flutter مع دعم المنصة المطلوبة وDart المتوافق مع `pubspec.yaml`، الذي يحدد حالياً `^3.13.5`.

```bash
flutter pub get
flutter gen-l10n
flutter run -d linux
```

لعرض الأجهزة والمنصات المتاحة واختيار هدف آخر:

```bash
flutter devices
flutter run -d <device-id>
```

### البناء

#### Linux

```bash
bash ./build_linux.sh
```

يعيد السكربت توليد الترجمات وبناء نسخة **Release من الكود الحالي في كل تشغيل**، ثم ينتج الحزم داخل `dist/` حسب أدوات التغليف المثبتة:

- `.tar.gz`
- `.deb`
- `.rpm`
- `.pkg.tar.zst`
- `.AppImage`

يتوقف السكربت دون تغليف إذا فشل البناء. يتطلب بناء Linux أدوات `clang` و`cmake` و`ninja` و`pkg-config` ومكتبات تطوير GTK3. تتوفر تفاصيل أدوات التغليف في [توثيق البناء](BUILD_NOTES.md).

مثال التثبيت على Arch Linux بمعمارية x86_64:

```bash
sudo pacman -U dist/baddil-1.0.0-1-x86_64.pkg.tar.zst
```

أغلق التطبيق القديم قبل فتح النسخة الجديدة. عند بقاء رقم الإصدار نفسه، يكون تحذير pacman بشأن إعادة التثبيت طبيعياً.

#### المنصات الأخرى

نفّذ كل أمر على جهاز مجهّز بأدوات المنصة المطلوبة؛ بناء iOS وmacOS يتطلب macOS وXcode، وبناء Windows يتطلب Windows وأدوات Visual Studio C++.

```bash
# Android APK
flutter build apk --release --split-per-abi

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# iOS
flutter build ipa --release
```

### الاختبارات

```bash
flutter test
flutter analyze
bash test/build_linux_script_test.sh
```

تشمل الاختبارات حساب البصمة عند اختيار الملف، والمقارنة بعد المعالجة، والنسخ، والعرض بالعربية والإنجليزية، ومنع تغليف نسخة Linux قديمة.

### توثيق المشروع

- [معمارية المشروع وقرارات التنفيذ](PROJECT_NOTES.md)
- [أوامر البناء ومتطلبات المنصات](BUILD_NOTES.md)
- [قرارات التصميم](DESIGN_DECISIONS.md)

### المطور

**حسام حسن مجرشي**

- البريد الإلكتروني: [Hossam.Majrashi@gmail.com](mailto:Hossam.Majrashi@gmail.com)
- الموقع: [أعمال المطور](https://hossam-majrashi.github.io/Works/)
- معرّف التطبيق: `com.h.baddil`

---

<a id="english"></a>

## English

**Baddil** is a Flutter application for modifying file fingerprints locally and comparing the old and new fingerprints. It targets Android, iOS, Linux, Windows, macOS, and the web. Files are processed on your device without uploading them to a server.

[View the home screen screenshot](#home-screen).

### Features

- Show the **old fingerprint** as soon as a selected file's hashes have been calculated.
- Show the **new fingerprint** after processing, keeping the old one visible for comparison.
- Display full **SHA-256 and MD5** values with selection and copy actions.
- Remove supported metadata and alter hashes without recompression for supported formats.
- Process JPEG, PNG, WebP, MP4, and MOV locally using Dart algorithms.
- Optionally re-encode images and adjust JPEG quality.
- Process multiple files, select folders on native platforms, and drag and drop files on desktop and web.
- Open a report for each file with sizes, fingerprints, applied changes, and the output path.
- Customize output filenames and folders, and export CSV reports on native platforms.
- Arabic and English interfaces with light, dark, and system themes.
- Create a new output file rather than overwrite the original.

### How to use

1. Select files or drag them into the application.
2. Wait for each file's **old fingerprint** to appear; processing is not required to calculate it.
3. Configure metadata removal, hash modification, and optional image re-encoding.
4. Select **Start Processing**.
5. Once processing finishes, compare and copy the **old fingerprint** and **new fingerprint**.
6. Select a file to open its detailed report. On native platforms, the output is saved under a new name in the source folder or your chosen output folder.

### Formats and limitations

| Format | Processing method |
| --- | --- |
| JPEG | Remove supported metadata segments and add a unique comment to alter the hash |
| PNG | Remove supported metadata chunks and add a custom chunk with CRC32 |
| WebP | Process supported RIFF chunks and add a unique chunk |
| MP4 / MOV | Process supported container boxes and modify their data without re-encoding video |
| PDF, ZIP, and other files | Append unique data using a best-effort approach; verify the output file |

**Important notes:**

- Hash modification without recompression does not require content re-encoding for supported formats. Enabling image re-encoding may affect quality.
- Generic processing does not guarantee compatibility with every format. Open and verify the output before using it.
- Web supports selecting multiple files and local processing, but folder selection, saving to a disk path, and CSV file export are unavailable in the current implementation.
- The application does not remove invisible in-pixel watermarks such as SynthID.
- Disclosing AI-generated content remains your responsibility under the policies of the platforms where you publish it.

### Privacy

Files are processed locally, with no cloud uploads, analytics, or advertisements. Processing does not overwrite the original files.

### Development setup

Install Flutter with support for your target platform and a Dart version compatible with `pubspec.yaml`, which currently specifies `^3.13.5`.

```bash
flutter pub get
flutter gen-l10n
flutter run -d linux
```

To list available devices and select another target:

```bash
flutter devices
flutter run -d <device-id>
```

### Building

#### Linux

```bash
bash ./build_linux.sh
```

On every invocation, the script regenerates localizations and builds a **Release bundle from the current sources** before producing packages in `dist/`, depending on the installed packaging tools:

- `.tar.gz`
- `.deb`
- `.rpm`
- `.pkg.tar.zst`
- `.AppImage`

Packaging stops if the build fails. Linux builds require `clang`, `cmake`, `ninja`, `pkg-config`, and GTK3 development libraries. See [build documentation](BUILD_NOTES.md) for packaging tool requirements.

Example installation on Arch Linux x86_64:

```bash
sudo pacman -U dist/baddil-1.0.0-1-x86_64.pkg.tar.zst
```

Close the old application before launching the new version. If the version number is unchanged, pacman's reinstall warning is expected.

#### Other platforms

Run each command on a machine configured for that platform. iOS and macOS builds require macOS and Xcode; Windows builds require Windows and Visual Studio C++ tools.

```bash
# Android APK
flutter build apk --release --split-per-abi

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# iOS
flutter build ipa --release
```

### Tests

```bash
flutter test
flutter analyze
bash test/build_linux_script_test.sh
```

Tests cover fingerprint calculation on selection, post-processing comparisons, copying, Arabic and English layouts, and preventing stale Linux bundles from being packaged.

### Project documentation

- [Architecture and implementation decisions](PROJECT_NOTES.md)
- [Build commands and platform requirements](BUILD_NOTES.md)
- [Design decisions](DESIGN_DECISIONS.md)

### Developer

**Hossam Majrashi**

- Email: [Hossam.Majrashi@gmail.com](mailto:Hossam.Majrashi@gmail.com)
- Website: [Developer portfolio](https://hossam-majrashi.github.io/Works/)
- Application ID: `com.h.baddil`
