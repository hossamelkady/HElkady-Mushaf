import 'package:flutter/material.dart';
import 'data.dart';
import 'settings.dart';
import 'reading_page.dart';

class SearchPage extends StatefulWidget {
  final Settings settings;
  const SearchPage({super.key, required this.settings});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Ayah> _results = [];
  bool _searched = false;

  void _search(String query) {
    final q = normAr(query);
    setState(() {
      _searched = true;
      if (q.length < 2) {
        _results = [];
        return;
      }
      _results = QuranData.ayahs
          .where((a) => normAr(a.e).contains(q) || normAr(a.t).contains(q))
          .take(200)
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث في المصحف')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث في آيات القرآن...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _searched && _controller.text.length >= 2 ? 'لا توجد نتائج' : 'اكتب كلمة أو جزءاً من آية',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final a = _results[i];
                      return ListTile(
                        dense: true,
                        title: Text(a.t, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'KfgqpcHafs', fontSize: 19, height: 1.8)),
                        subtitle: Text('سورة ${QuranData.surah(a.s).nameAr} • آية ${a.a} • صفحة ${a.p}'),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ReadingPage(settings: widget.settings, surahId: a.s, initialAyah: a.a))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
