# توثيق البناء والمعماريات (BUILD_NOTES.md) — بدّل (Baddil)

## 1. جدول المنصات والمعماريات المدعومة

| المنصة | المعماريات المدعومة رسمياً من Flutter | حالة الدعم في بدّل | ملاحظات ومتطلبات جهاز البناء |
|---|---|---|---|
| **Android** | x86_64, Arm64 (arm64-v8a), Arm32 (armeabi-v7a) | ✅ مدعومة بالكامل عبر split-per-abi | يتطلب Android SDK و JDK 17. |
| **Linux** | x86_64, Arm64 (aarch64) | ✅ مدعومة عبر CMake و `build_linux.sh` | يتطلب clang, cmake, ninja, gtk3. |
| **Flatpak** | x86_64, Arm64 | ✅ مدعومة عبر `flatpak_linux.sh` | يتطلب `flatpak-builder` و runtime 23.08. |
| **Windows** | x86_64, Arm64 | ✅ مدعومة عبر Visual Studio | يتطلب نظام تشغيل Windows مع VS C++ tools. |
| **macOS** | x86_64, Arm64 (Universal Binary) | ✅ مدعومة عبر Xcode | يتطلب جهاز macOS مع تثبيت Xcode. |
| **iOS** | Arm64 | ✅ مدعومة عبر Xcode | يتطلب جهاز macOS مع Xcode وشهادات توقيع آبل. |
| **Web** | WebAssembly (Wasm) / JavaScript | ✅ مدعومة بالكامل | يتطلب متصفح حديث، مترجم عبر Flutter Web. |

### المعماريات غير المدعومة:
- **ARMv7 (32-bit):** مدعومة على Android فقط. غير مدعومة من محرك Flutter على سطح المكتب (Linux/Win/Mac) أو iOS أو الويب.
- **x86-32 (32-bit):** ملغاة تماماً من محرك Flutter الحديث على كافة المنصات بدون استثناء.

---

## 2. أوامر البناء لكل منصة (Build Commands)

### 1. Linux
```bash
# بناء نسخة الإصدار القياسية (x86_64)
flutter build linux --release

# إعادة بناء Release من الكود الحالي ثم إنتاج حزم التوزيع داخل مجلد /dist
# لا حاجة لتنفيذ flutter build يدوياً قبل هذا الأمر
bash ./build_linux.sh

# إنتاج حزمة Flatpak داخل مجلد /dist
./flatpak_linux.sh
```
**مهم عند اختبار التغييرات على Linux:**
- يقوم `build_linux.sh` بتوليد الترجمات وتشغيل `flutter build linux --release` في كل مرة، حتى لو كان مجلد Release موجوداً؛ ويتوقف دون تغليف إذا فشل البناء.
- يستخدم مجلد `build/linux/x64/release/bundle` أو `build/linux/arm64/release/bundle` حسب معمارية الجهاز. نسخة `flutter run -d linux` موجودة في مجلد Debug منفصل ولا تُستخدم للتغليف.
- بعد البناء، أغلق التطبيق القديم بالكامل ثم أعد تثبيت الحزمة الجديدة. بقاء رقم الإصدار `1.0.0-1` يعني أن pacman سيعرض «إعادة تثبيت»، ولا يعني أن محتوى الحزمة لم يتغيّر.

```bash
# مثال على Arch Linux (x86_64)
bash ./build_linux.sh
sudo pacman -U dist/baddil-1.0.0-1-x86_64.pkg.tar.zst

# اختبار نسخة Release الجديدة مباشرة دون تثبيت
./build/linux/x64/release/bundle/baddil
```

**متطلبات جهاز البناء:**
- `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `liblzma-dev`
- لأدوات التغليف: `dpkg-deb`, `rpmbuild` أو `fpm`, `zstd`, `appimagetool`, `flatpak-builder`

### 2. Android
```bash
# بناء APK مقسم لكل معمارية (Split per ABI: Arm64, Arm32, x64) بالإضافة إلى Universal APK
flutter build apk --release --split-per-abi

# أو بناء App Bundle للمتجر (Google Play):
flutter build appbundle --release
```
**متطلبات جهاز البناء:**
- JDK 17
- Android SDK Platform 34+ و Build-Tools و NDK

### 3. Web
```bash
# بناء الويب بتقنية WebAssembly و CanvasKit
flutter build web --release --wasm

# أو بناء الويب القياسي:
flutter build web --release
```

### 4. Windows (من جهاز Windows)
```bash
# بناء تطبيق سطح المكتب 64-bit
flutter build windows --release
```
**متطلبات جهاز البناء:**
- Windows 10/11
- Visual Studio 2022 مع حزمة Desktop development with C++

### 5. macOS (من جهاز Mac)
```bash
# بناء تطبيق universal (x64 + arm64)
flutter build macos --release
```
**متطلبات جهاز البناء:**
- macOS 13+
- Xcode 15+ مع الأدوات الطرفية (Command Line Tools)

### 6. iOS (من جهاز Mac)
```bash
# بناء تطبيق iOS
flutter build ipa --release
```
**متطلبات جهاز البناء:**
- macOS و Xcode وحساب مطور Apple

---

## 3. قيود المنصات والبدائل الآمنة
- **معالجة حاويات MKV/WebM/AVI (FFmpeg):** تعمل على Linux/Windows/Android؛ وتُعطل بوضوح على iOS وWeb برسالة مترجمة صريحة لعدم توفر بيئة باينري معزولة وآمنة.
- **معالجة MP4/MOV:** تعمل بـ Dart خالص 100% بدون أي أدوات خارجية على **كافة المنصات** السبع.
- **اختيار مجلد كامل (Batch Folder):** مدعوم على أنظمة سطح المكتب والجوال، بينما في الويب يتم اختيار ملفات متعددة دفعة واحدة.
