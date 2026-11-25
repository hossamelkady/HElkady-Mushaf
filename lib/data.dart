import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class Ayah {
  final int s, a, p, j;
  final String t, e;
  const Ayah(this.s, this.a, this.t, this.e, this.p, this.j);
}

class Surah {
  final int id, ayahs, page, juz;
  final String nameAr, nameEn, revelation;
  const Surah(this.id, this.nameAr, this.nameEn, this.ayahs, this.page, this.juz, this.revelation);
}

class QuranData {
  static List<Ayah> ayahs = [];
  static List<Surah> surahs = [];
  static bool loaded = false;

  static Future<void> load() async {
    if (loaded) return;
    final qBytes = await rootBundle.load('assets/data/quran.json.gz');
    final qStr = utf8.decode(GZipCodec().decode(qBytes.buffer.asUint8List()));
    final qList = jsonDecode(qStr) as List;
    ayahs = qList
        .map((e) => Ayah(e['s'] as int, e['a'] as int, e['t'] as String, e['e'] as String, e['p'] as int, e['j'] as int))
        .toList();
    final sStr = await rootBundle.loadString('assets/data/surahs.json');
    final sList = jsonDecode(sStr) as List;
    surahs = sList
        .map((e) => Surah(e['id'] as int, e['name_ar'] as String, e['name_en'] as String, e['ayahs'] as int,
            e['page'] as int, e['juz'] as int, e['revelation'] as String))
        .toList();
    loaded = true;
  }

  static List<Ayah> ofSurah(int s) => ayahs.where((a) => a.s == s).toList();
  static Surah surah(int id) => surahs.firstWhere((s) => s.id == id);
}

class Tafsir {
  static final Map<String, Map<String, Map<String, String>>> _cache = {};

  static Future<Map<String, String>> ofSurah(String edition, int surah) async {
    if (!_cache.containsKey(edition)) {
      final bytes = await rootBundle.load('assets/data/tafsir/$edition.json.gz');
      final str = utf8.decode(GZipCodec().decode(bytes.buffer.asUint8List()));
      final map = jsonDecode(str) as Map<String, dynamic>;
      _cache[edition] = map.map((k, v) =>
          MapEntry(k, (v as Map<String, dynamic>).map((k2, v2) => MapEntry(k2, v2.toString()))));
    }
    return _cache[edition]![surah.toString()] ?? const {};
  }
}

String normAr(String s) {
  return s
      .replaceAll(RegExp(r'[ً-ٰٟۖ-ۭـ]'), '')
      .replaceAll(RegExp(r'[أإآٱا]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
