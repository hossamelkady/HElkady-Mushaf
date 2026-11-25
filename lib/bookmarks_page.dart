import 'package:flutter/material.dart';
import 'data.dart';
import 'settings.dart';
import 'reading_page.dart';

class BookmarksPage extends StatefulWidget {
  final Settings settings;
  const BookmarksPage({super.key, required this.settings});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    final marks = widget.settings.bookmarks;
    return Scaffold(
      appBar: AppBar(title: const Text('العلامات')),
      body: marks.isEmpty
          ? Center(
              child: Text('لا توجد علامات بعد.\nاضغط على أي آية أثناء القراءة ثم «حفظ علامة».',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge))
          : ListView.separated(
              itemCount: marks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final parts = marks[i].split(':');
                final s = int.parse(parts[0]);
                final a = int.parse(parts[1]);
                final ayah = QuranData.ofSurah(s).firstWhere((x) => x.a == a, orElse: () => QuranData.ofSurah(s).first);
                return Dismissible(
                  key: ValueKey(marks[i]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) async {
                    await widget.settings.toggleBookmark(s, a);
                    setState(() {});
                  },
                  child: ListTile(
                    title: Text(ayah.t, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'KfgqpcHafs', fontSize: 19)),
                    subtitle: Text('سورة ${QuranData.surah(s).nameAr} • آية $a'),
                    trailing: const Icon(Icons.bookmark),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReadingPage(settings: widget.settings, surahId: s, initialAyah: a))),
                  ),
                );
              },
            ),
    );
  }
}
