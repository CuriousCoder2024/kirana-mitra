import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum KmBadgeVariant { low, ok, warn, demo }

/// Handoff §4.3. Every colour signal carries an icon and a word.
class KmBadge extends StatelessWidget {
  const KmBadge({
    super.key,
    required this.variant,
    required this.label,
    this.inRow = false,
  });

  final KmBadgeVariant variant;
  final String label;
  final bool inRow;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color fg, IconData? icon) = switch (variant) {
      KmBadgeVariant.low => (KmColors.mirchi, KmColors.white, Icons.arrow_downward_rounded),
      KmBadgeVariant.ok => (KmColors.leafTint, KmColors.leaf, Icons.check_rounded),
      KmBadgeVariant.warn => (KmColors.haldiTint, KmColors.haldiText, Icons.warning_amber_rounded),
      KmBadgeVariant.demo => (KmColors.sand, KmColors.inkSoft, null),
    };
    final style = (inRow ? KmText.labelSmall : KmText.label).copyWith(color: fg);
    return Container(
      height: inRow ? 24 : 28,
      padding: EdgeInsets.symmetric(horizontal: inRow ? 8 : 10),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: inRow ? 14 : 16, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}
