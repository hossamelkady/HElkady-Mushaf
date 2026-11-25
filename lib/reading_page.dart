import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'data.dart';
import 'settings.dart';

class ReadingPage extends StatefulWidget {
  final Settings settings;
  final int surahId;
  final int? initialAyah;
  const ReadingPage({super.key, required this.settings, required this.surahId, this.initialAyah});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final ItemScrollController _scrollController = ItemScrollController();
  final List<TapGestureRecognizer> _recognizers = [];
  List<List<Ayah>> _pages = [];

  @override
  void initState() {
    super.initState();
    final ayahs = QuranData.ofSurah(widget.surahId);
    final map = <int, List<Ayah>>{};
    for (final a in ayahs) {
      map.putIfAbsent(a.p, () => []).add(a);
    }
    _pages = map.values.toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAyah != null) {
        final idx = _pages.indexWhere((pg) => pg.any((a) => a.a == widget.initialAyah));
        if (idx >= 0 && _scrollController.isAttached) _scrollController.jumpTo(index: idx);
      }
      if (ayahs.isNotEmpty) {
        widget.settings.setLastRead(widget.surahId, widget.initialAyah ?? ayahs.first.a);
      }
    });
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _showTafsir(Ayah ayah) {
    final settings = widget.settings;
    bool bookmarked = settings.isBookmarked(ayah.s, ayah.a);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Text(ayah.t,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'KfgqpcHafs', fontSize: 24, height: 2, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 4),
              Center(
                child: TextButton.icon(
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(bookmarked ? 'إزالة العلامة' : 'حفظ علامة'),
                  onPressed: () async {
                    await settings.toggleBookmark(ayah.s, ayah.a);
                    setSheetState(() => bookmarked = !bookmarked);
                  },
                ),
              ),
              const Divider(height: 24),
              ValueListenableBuilder<String>(
                valueListenable: settings.tafsir,
                builder: (context, edition, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(Settings.tafsirNames[edition] ?? edition,
                        style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, String>>(
                      future: Tafsir.ofSurah(edition, ayah.s),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final text = snap.data![ayah.a.toString()];
                        return SelectableText(
                          text == null || text.isEmpty ? 'لا يوجد تفسير لهذه الآية في هذا التفسير.' : text,
                          style: const TextStyle(fontSize: 17, height: 1.9),
                          textAlign: TextAlign.start,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _surahHeader(BuildContext context) {
    final s = QuranData.surah(widget.surahId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text('سُورَةُ ${s.nameAr}',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'KfgqpcHafs', fontSize: 30, color: Theme.of(context).colorScheme.primary)),
          Text('${s.revelation} • ${s.ayahs} آية', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = QuranData.surah(widget.surahId);
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${s.nameAr}')),
      body: ValueListenableBuilder<double>(
        valueListenable: widget.settings.fontSize,
        builder: (context, size, _) => ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemCount: _pages.length,
          itemBuilder: (context, i) {
            final ayahs = _pages[i];
            final spans = <TextSpan>[];
            for (final a in ayahs) {
              final rec = TapGestureRecognizer()..onTap = () => _showTafsir(a);
              _recognizers.add(rec);
              spans.add(TextSpan(text: '${a.t} ', recognizer: rec));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (i == 0) ...[
                    _surahHeader(context),
                    if (widget.surahId != 1 && widget.surahId != 9)
                      Text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'KfgqpcHafs', fontSize: size, height: 2, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                  ],
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontFamily: 'KfgqpcHafs', fontSize: size, height: 2.1, color: Theme.of(context).colorScheme.onSurface),
                      children: spans,
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Center(child: Text('صفحة ${ayahs.first.p}', style: Theme.of(context).textTheme.bodySmall)),
                  const Divider(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
