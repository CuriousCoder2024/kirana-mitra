import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Snackbar-style toast anchored to the top of the screen; never a dialog.
class TopToast {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String text, {Duration duration = const Duration(seconds: 3)}) {
    _entry?.remove();
    _entry = null;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: KmColors.ink,
              borderRadius: BorderRadius.circular(KmRadius.buttonSmall),
              boxShadow: [BoxShadow(color: KmColors.ink.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: KmColors.saffronBright, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: KmText.body.copyWith(color: KmColors.white, fontSize: 16))),
              ],
            ),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    Future<void>.delayed(duration, () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }
}
