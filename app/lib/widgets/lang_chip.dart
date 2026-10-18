import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../state/shop_prefs.dart';
import '../theme/theme.dart';
import 'language_grid.dart';

/// Handoff §4.12: 36 dp chip at the right of every app bar that opens the
/// language sheet.
class LangChip extends ConsumerWidget {
  const LangChip({super.key});

  static String labelFor(String code) => languageFor(code).nameNative;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(shopPrefsProvider.select((p) => p.language));
    // Narrow phones: icon only, so the title keeps its room.
    final compact = MediaQuery.sizeOf(context).width < 400;
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
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 18, color: KmColors.saffron),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(labelFor(code), style: KmText.label.copyWith(letterSpacing: 0)),
                ],
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
    isScrollControlled: true,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(shopPrefsProvider.select((p) => p.language));
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 12),
              Text(l.languageSheetTitle, style: KmText.sheetTitle),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: LanguageGrid(
                    value: current,
                    onChanged: (v) {
                      ref.read(shopPrefsProvider.notifier).setLanguage(v);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
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

