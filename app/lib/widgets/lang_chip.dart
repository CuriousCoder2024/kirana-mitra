import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/shop_prefs.dart';
import '../theme/theme.dart';

/// Handoff §4.12: 36 dp chip at the right of every app bar that opens the
/// language sheet.
class LangChip extends ConsumerWidget {
  const LangChip({super.key});

  static String labelFor(String code) => switch (code) {
        'hi' => 'हिंदी',
        'en' => 'English',
        _ => 'Hinglish',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(shopPrefsProvider.select((p) => p.language));
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KmColors.sand, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showLanguageSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 18, color: KmColors.saffron),
                const SizedBox(width: 6),
                Text(labelFor(code), style: KmText.label.copyWith(letterSpacing: 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(shopPrefsProvider.select((p) => p.language));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 12),
            Text(l.languageSheetTitle, style: KmText.sheetTitle),
            const SizedBox(height: 14),
            LanguageOptions(
              value: current,
              onChanged: (v) {
                ref.read(shopPrefsProvider.notifier).setLanguage(v);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 44 × 5 grab handle used at the top of every bottom sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: KmColors.inkFaint,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// The three language option cards (handoff §5.1), shared by onboarding and
/// the language sheet.
class LanguageOptions extends StatelessWidget {
  const LanguageOptions({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = [
      ('hi', l.langHindi, l.langSampleHindi),
      ('hi-Latn', l.langHinglish, l.langSampleHinglish),
      ('en', l.langEnglish, l.langSampleEnglish),
    ];
    return Column(
      children: [
        for (final (code, name, sample) in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionCard(
              selected: value == code,
              name: name,
              sample: sample,
              onTap: () => onChanged(code),
            ),
          ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.name,
    required this.sample,
    required this.onTap,
  });

  final bool selected;
  final String name;
  final String sample;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? KmColors.saffron : KmColors.inkFaint, width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(color: KmColors.saffron, shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: KmText.bodyBold, maxLines: 1),
                      Text(sample, style: KmText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
