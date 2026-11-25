import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final ValueNotifier<double> fontSize = ValueNotifier(24);
  final ValueNotifier<String> tafsir = ValueNotifier('muyassar');
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  late final SharedPreferences _prefs;

  static const tafsirNames = {
    'muyassar': 'التفسير الميسّر (مجمع الملك فهد)',
    'jalalayn': 'تفسير الجلالين',
    'saadi': 'تفسير السعدي',
    'ibnkathir': 'تفسير ابن كثير',
  };

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    fontSize.value = _prefs.getDouble('fontSize') ?? 24;
    tafsir.value = _prefs.getString('tafsir') ?? 'muyassar';
    themeMode.value = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
  }

  Future<void> setFontSize(double v) async {
    fontSize.value = v;
    await _prefs.setDouble('fontSize', v);
  }

  Future<void> setTafsir(String v) async {
    tafsir.value = v;
    await _prefs.setString('tafsir', v);
  }

  Future<void> setThemeMode(ThemeMode v) async {
    themeMode.value = v;
    await _prefs.setInt('themeMode', v.index);
  }

  List<String> get bookmarks => _prefs.getStringList('bookmarks') ?? [];
  bool isBookmarked(int s, int a) => bookmarks.contains('$s:$a');

  Future<void> toggleBookmark(int s, int a) async {
    final list = bookmarks;
    final key = '$s:$a';
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
    await _prefs.setStringList('bookmarks', list);
  }

  String? get lastRead => _prefs.getString('lastRead');
  Future<void> setLastRead(int s, int a) => _prefs.setString('lastRead', '$s:$a');
}
