import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'km_badge.dart';
import 'lang_chip.dart';
import 'logo_mark.dart';

/// Handoff §4.15: 64 dp cream bar, Baloo title, status subtitle, logo or back
/// circle on the left, Demo badge and LangChip on the right.
class KmAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const KmAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = false,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final bool showLogo;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(KmSize.appBar);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final demo = ref.watch(isDemoModeProvider);
    return AppBar(
      toolbarHeight: KmSize.appBar,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: KmSpace.gutter),
        child: Row(
          children: [
            if (showLogo) ...[
              const LogoMark(size: 36),
              const SizedBox(width: 12),
            ] else if (onBack != null) ...[
              Semantics(
                button: true,
                label: l.backLabel,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: KmColors.paper,
                    shape: BoxShape.circle,
                    border: Border.all(color: KmColors.sand),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onBack,
                      child: const Icon(Icons.arrow_back_rounded, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: KmText.heading, maxLines: 1),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(subtitle!, style: KmText.status, maxLines: 1),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (demo) ...[
          KmBadge(variant: KmBadgeVariant.demo, label: l.demoMode),
          const SizedBox(width: 8),
        ],
        const LangChip(),
        ...actions,
        const SizedBox(width: KmSpace.gutter),
      ],
    );
  }
}
