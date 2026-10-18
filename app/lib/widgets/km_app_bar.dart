import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'feedback_sheet.dart';
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
              child: LayoutBuilder(
                builder: (context, c) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // With the logo present the mark stands for the app name
                    // when a narrow bar leaves no room for the title text.
                    if (!(showLogo && c.maxWidth < 110))
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(title, style: KmText.heading, maxLines: 1),
                      ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subtitle!,
                          style: showLogo && c.maxWidth < 110
                              ? KmText.status.copyWith(color: KmColors.ink)
                              : KmText.status,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (demo) ...[
          KmBadge(variant: KmBadgeVariant.demo, label: l.demoMode),
          const SizedBox(width: 6),
        ],
        _FeedbackAction(label: l.feedbackButton),
        const SizedBox(width: 6),
        const LangChip(),
        ...actions,
        const SizedBox(width: KmSpace.gutter),
      ],
    );
  }
}

/// Icon + short label that opens the feedback sheet for the current route.
class _FeedbackAction extends StatelessWidget {
  const _FeedbackAction({required this.label});

  final String label;

  static String _screenName(BuildContext context) {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (_) {
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showFeedbackSheet(context, screen: _screenName(context)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.thumbs_up_down_outlined,
                  size: 22,
                  color: KmColors.saffron,
                ),
                Text(
                  label,
                  style: KmText.status.copyWith(
                    fontSize: 11,
                    color: KmColors.saffron,
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
