import 'package:flutter/material.dart';
import 'data.dart';
import 'settings.dart';
import 'reading_page.dart';

class SurahIndexPage extends StatelessWidget {
  final Settings settings;
  const SurahIndexPage({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final lastRead = settings.lastRead;
    return Scaffold(
      appBar: AppBar(title: const Text('المصحف الشريف')),
      body: Column(
        children: [
          if (lastRead != null) _ContinueBanner(settings: settings, lastRead: lastRead),
          Expanded(
            child: ListView.separated(
              itemCount: QuranData.surahs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = QuranData.surahs[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${s.id}')),
                  title: Text('سورة ${s.nameAr}', style: const TextStyle(fontFamily: 'KfgqpcHafs', fontSize: 22)),
                  subtitle: Text('${s.revelation} • ${s.ayahs} آية • صفحة ${s.page}'),
                  trailing: Text(s.nameEn, style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ReadingPage(settings: settings, surahId: s.id))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueBanner extends StatelessWidget {
  final Settings settings;
  final String lastRead;
  const _ContinueBanner({required this.settings, required this.lastRead});

  @override
  Widget build(BuildContext context) {
    final parts = lastRead.split(':');
    final s = int.parse(parts[0]);
    final a = int.parse(parts[1]);
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.play_arrow),
        title: Text('متابعة القراءة: سورة ${QuranData.surah(s).nameAr}، آية $a'),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReadingPage(settings: settings, surahId: s, initialAyah: a))),
      ),
    );
  }
}
