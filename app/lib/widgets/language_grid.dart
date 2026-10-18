import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../theme/theme.dart';

/// Searchable grid of the 24 language tiles: native name in its own script,
/// English name small beneath. Used by onboarding and the language sheet.
class LanguageGrid extends StatefulWidget {
  const LanguageGrid({
    super.key,
    required this.value,
    required this.onChanged,
    this.languages = kLanguages,
    this.shrinkWrap = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<KmLanguage> languages;
  final bool shrinkWrap;

  @override
  State<LanguageGrid> createState() => _LanguageGridState();
}

class _LanguageGridState extends State<LanguageGrid> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final shown = widget.languages.where((lang) {
      if (q.isEmpty) return true;
      return lang.nameEn.toLowerCase().contains(q) ||
          lang.nameNative.toLowerCase().contains(q) ||
          lang.code.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: KmText.body,
          decoration: InputDecoration(
            hintText: l.languageSearchHint,
            prefixIcon: const Icon(Icons.search_rounded, size: 24),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.languageNoMatch, style: KmText.caption, textAlign: TextAlign.center),
          )
        else
          GridView.builder(
            shrinkWrap: widget.shrinkWrap,
            physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisExtent: 72,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: shown.length,
            itemBuilder: (context, i) => _LanguageTile(
              language: shown[i],
              selected: shown[i].code == widget.value,
              onTap: () => widget.onChanged(shown[i].code),
            ),
          ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language, required this.selected, required this.onTap});

  final KmLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: language.nameEn,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? KmColors.saffronWash : KmColors.paper,
          borderRadius: BorderRadius.circular(KmRadius.field),
          border: Border.all(color: selected ? KmColors.saffron : KmColors.sand, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(KmRadius.field),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.nameNative,
                    style: KmText.bodyBold.copyWith(fontFamilyFallback: scriptFallback(language.script)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: language.rtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  const SizedBox(height: 2),
                  Text(language.nameEn, style: KmText.status, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
