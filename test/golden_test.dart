import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf/data.dart';
import 'package:mushaf/settings.dart';
import 'package:mushaf/reading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders mushaf pages with KFGQPC font', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = Settings();
    await QuranData.load();
    await settings.load();
    final loader = FontLoader('KfgqpcHafs')
      ..addFont(rootBundle.load('assets/fonts/kfgqpc_hafs.ttf'));
    await loader.load();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(width: 400, height: 800, child: ReadingPage(key: const ValueKey('s1'), settings: settings, surahId: 1)),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ReadingPage), matchesGoldenFile('fatihah.png'));

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(width: 400, height: 800, child: ReadingPage(key: const ValueKey('s2'), settings: settings, surahId: 2, initialAyah: 150)),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ReadingPage), matchesGoldenFile('baqarah_p23.png'));
  });
}
