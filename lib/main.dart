import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data.dart';
import 'settings.dart';
import 'surah_index_page.dart';
import 'search_page.dart';
import 'bookmarks_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MushafApp());
}

class MushafApp extends StatefulWidget {
  const MushafApp({super.key});
  @override
  State<MushafApp> createState() => _MushafAppState();
}

class _MushafAppState extends State<MushafApp> {
  final Settings settings = Settings();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.wait([QuranData.load(), settings.load()]).then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
    }
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'المصحف',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(colorSchemeSeed: const Color(0xFF1B5E20), brightness: Brightness.light, useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF1B5E20), brightness: Brightness.dark, useMaterial3: true),
        themeMode: mode,
        home: HomePage(settings: settings),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Settings settings;
  const HomePage({super.key, required this.settings});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SurahIndexPage(settings: widget.settings),
      SearchPage(settings: widget.settings),
      BookmarksPage(settings: widget.settings),
      SettingsPage(settings: widget.settings),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'المصحف'),
          NavigationDestination(icon: Icon(Icons.search), label: 'البحث'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'العلامات'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
