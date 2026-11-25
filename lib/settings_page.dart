import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsPage extends StatelessWidget {
  final Settings settings;
  const SettingsPage({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('التفسير', style: Theme.of(context).textTheme.titleMedium),
          ValueListenableBuilder<String>(
            valueListenable: settings.tafsir,
            builder: (context, current, _) => Column(
              children: Settings.tafsirNames.entries
                  .map((e) => RadioListTile<String>(
                        value: e.key,
                        groupValue: current,
                        title: Text(e.value),
                        onChanged: (v) => settings.setTafsir(v!),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 32),
          Text('حجم خط المصحف', style: Theme.of(context).textTheme.titleMedium),
          ValueListenableBuilder<double>(
            valueListenable: settings.fontSize,
            builder: (context, size, _) => Column(
              children: [
                Slider(
                  value: size,
                  min: 18,
                  max: 40,
                  divisions: 11,
                  label: size.round().toString(),
                  onChanged: (v) => settings.setFontSize(v),
                ),
                Text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'KfgqpcHafs', fontSize: size, height: 1.8)),
              ],
            ),
          ),
          const Divider(height: 32),
          Text('المظهر', style: Theme.of(context).textTheme.titleMedium),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: settings.themeMode,
            builder: (context, mode, _) => SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('تلقائي'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('فاتح'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('داكن'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {mode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          const Divider(height: 32),
          Text('عن التطبيق والمصادر', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SelectableText(
            'المصحف v1.0.0\n\n'
            'نص القرآن الكريم: النص الرقمي الرسمي لمجمع الملك فهد لطباعة المصحف الشريف، رواية حفص عن عاصم (qurancomplex.gov.sa).\n\n'
            'الخط: KFGQPC Uthmanic Script HAFS من مجمع الملك فهد لطباعة المصحف الشريف — مرخص مجاناً للاستخدام والنسخ والتوزيع دون تعديل أو بيع.\n\n'
            'التفاسير: التفسير الميسّر (مجمع الملك فهد)، تفسير الجلالين، تفسير السعدي، تفسير ابن كثير — عبر مصدر tafsir.app.\n\n'
            'ملاحظة: هذه نسخة أولى للتجربة، ويُنصح بمراجعة النص من متخصص معتمد قبل النشر الرسمي.',
            style: TextStyle(fontSize: 14, height: 1.8),
          ),
        ],
      ),
    );
  }
}
