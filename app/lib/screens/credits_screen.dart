import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/tab_scaffold.dart';

/// Image credits, rendered from the bundled copy of ATTRIBUTION.md with a
/// deliberately small Markdown subset: headings, paragraphs and tables.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TabScaffold(
      showFab: false,
      appBar: KmAppBar(title: l.imageCredits, onBack: () => context.go('/chat')),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/ATTRIBUTION.md'),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 40),
            children: _render(snap.data!),
          );
        },
      ),
    );
  }

  static List<Widget> _render(String md) {
    final out = <Widget>[];
    final para = StringBuffer();
    void flush() {
      if (para.isNotEmpty) {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SelectableText(_plain(para.toString().trim()), style: KmText.caption),
        ));
        para.clear();
      }
    }

    for (final raw in md.split('\n')) {
      final line = raw.trimRight();
      if (line.startsWith('#')) {
        flush();
        final level = line.indexOf(' ');
        out.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(line.substring(level + 1), style: level <= 1 ? KmText.sheetTitle : KmText.bodyBold),
        ));
      } else if (line.startsWith('|')) {
        final cells = line.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
        if (cells.isEmpty || cells.every((c) => RegExp(r'^-+$').hasMatch(c))) continue;
        if (cells.first == 'File') continue; // header row
        flush();
        out.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: KmColors.paper,
            borderRadius: BorderRadius.circular(KmRadius.buttonSmall),
            border: Border.all(color: KmColors.sand),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cells.length > 1) Text(_plain(cells[1]), style: KmText.rowTitle),
              Text(_plain(cells.first), style: KmText.caption14),
              for (final c in cells.skip(2)) Text(_plain(c), style: KmText.caption14),
            ],
          ),
        ));
      } else if (line.isEmpty) {
        flush();
      } else {
        para.write('$line ');
      }
    }
    flush();
    return out;
  }

  /// Strips Markdown links, emphasis and code ticks, keeping the visible text
  /// and the URL in brackets.
  static String _plain(String s) => s
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), (m) => '${m[1]} (${m[2]})')
      .replaceAll('**', '')
      .replaceAll('`', '');
}
