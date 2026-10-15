import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baddil/core/l10n/generated/app_localizations.dart';
import 'package:baddil/features/home/services/home_controller.dart';
import 'package:baddil/shared/models/file_item.dart';
import 'package:baddil/shared/widgets/file_fingerprint_comparison.dart';
import 'package:baddil/shared/widgets/queue_card.dart';

final _beforeSha = 'a' * 64;
final _afterSha = 'b' * 64;
final _beforeMd5 = 'c' * 32;
final _afterMd5 = 'd' * 32;

FileItem _item({FileStatus status = FileStatus.done, bool unchanged = false}) {
  return FileItem(
    id: 'test',
    name: 'sample.png',
    originalSize: 100,
    originalSha256: _beforeSha,
    originalMd5: _beforeMd5,
    processedSha256: status == FileStatus.done
        ? (unchanged ? _beforeSha : _afterSha)
        : null,
    processedMd5: status == FileStatus.done
        ? (unchanged ? _beforeMd5 : _afterMd5)
        : null,
    status: status,
  );
}

Future<void> _pumpComparison(
  WidgetTester tester,
  FileItem item, {
  String language = 'en',
  double width = 600,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: FileFingerprintComparison(item: item),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _QueueTestController extends HomeController {
  FileItem item = FileItem(id: 'test', name: 'sample.png', originalSize: 100);

  @override
  List<FileItem> get queue => [item];

  void publish(FileItem updated) {
    item = updated;
    notifyListeners();
  }
}

void main() {
  testWidgets('Queue and open report update with before and after hashes', (
    tester,
  ) async {
    final controller = _QueueTestController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => QueueCard(controller: controller),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FileFingerprintComparison), findsOneWidget);
    expect(find.text('Old fingerprint'), findsOneWidget);
    expect(find.text('New fingerprint'), findsNothing);
    controller.publish(_item(status: FileStatus.waiting));
    await tester.pumpAndSettle();
    expect(find.text(_beforeSha), findsOneWidget);
    expect(find.text(_beforeMd5), findsOneWidget);
    expect(find.text('New fingerprint'), findsNothing);
    await tester.tap(find.text('sample.png'));
    await tester.pumpAndSettle();

    controller.publish(_item(status: FileStatus.processing));
    await tester.pump();
    expect(find.text(_beforeSha), findsNWidgets(2));
    expect(find.text(_afterSha), findsNothing);

    controller.publish(_item());
    await tester.pumpAndSettle();
    for (final hash in [_beforeSha, _afterSha, _beforeMd5, _afterMd5]) {
      expect(find.text(hash), findsNWidgets(2));
    }
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'ar']) {
    for (final width in [280.0, 700.0]) {
      testWidgets('Full fingerprints render at $width in $language', (
        tester,
      ) async {
        await _pumpComparison(
          tester,
          _item(),
          language: language,
          width: width,
        );
        for (final hash in [_beforeSha, _afterSha, _beforeMd5, _afterMd5]) {
          expect(find.text(hash), findsOneWidget);
        }
        for (final text in tester.widgetList<SelectableText>(
          find.byType(SelectableText),
        )) {
          expect(text.textDirection, TextDirection.ltr);
        }
        expect(find.byIcon(Icons.copy_rounded), findsNWidgets(4));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Selection shows only the old fingerprint with Arabic labels', (
    tester,
  ) async {
    await _pumpComparison(
      tester,
      _item(status: FileStatus.waiting),
      language: 'ar',
      width: 280,
    );
    expect(find.text('البصمة القديمة'), findsOneWidget);
    expect(find.text('البصمة الجديدة'), findsNothing);
    expect(find.text(_beforeSha), findsOneWidget);
    expect(find.text(_beforeMd5), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Original is visible while new fingerprint is pending', (
    tester,
  ) async {
    await _pumpComparison(tester, _item(status: FileStatus.processing));
    expect(find.text(_beforeSha), findsOneWidget);
    expect(find.text(_beforeMd5), findsOneWidget);
    expect(find.text('Waiting for fingerprint…'), findsNWidgets(2));
    expect(find.text('File fingerprint changed'), findsNothing);
  });

  testWidgets('Failed processing does not claim a new fingerprint', (
    tester,
  ) async {
    await _pumpComparison(tester, _item(status: FileStatus.error));
    expect(find.text(_beforeSha), findsOneWidget);
    expect(find.text('Fingerprint unavailable'), findsNWidgets(2));
    expect(find.text('File fingerprint changed'), findsNothing);
  });

  testWidgets('Unchanged fingerprints are labelled accurately', (tester) async {
    await _pumpComparison(tester, _item(unchanged: true));
    expect(find.text('File fingerprint unchanged'), findsOneWidget);
    expect(find.text('File fingerprint changed'), findsNothing);
  });

  testWidgets('All four fingerprints can be copied in full', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
    await _pumpComparison(tester, _item());
    final buttons = find.byIcon(Icons.copy_rounded);
    final hashes = [_beforeSha, _beforeMd5, _afterSha, _afterMd5];
    for (var i = 0; i < hashes.length; i++) {
      await tester.tap(buttons.at(i));
      await tester.pump();
      expect(copied, hashes[i]);
    }
  });
}
