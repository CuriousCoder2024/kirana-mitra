import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Handoff §4.2: 48 dp navigation / filter chip. Never carries confirm or undo.
class KmChip extends StatelessWidget {
  const KmChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
    this.quiet = false,
    this.stretch = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool selected;
  final bool quiet;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? KmColors.white : KmColors.ink;
    final iconColor = selected ? KmColors.white : KmColors.saffron;
    final border = selected
        ? KmColors.saffron
        : quiet
            ? KmColors.sand
            : KmColors.saffron;
    return Container(
      height: KmSize.chip,
      decoration: BoxDecoration(
        color: selected ? KmColors.saffron : KmColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: KmText.chip.copyWith(color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Icon for a contract quick-action name.
  static IconData iconFor(String action) => switch (action) {
        'open_stock' => Icons.inventory_2_outlined,
        'open_udhaar' => Icons.account_balance_wallet_outlined,
        'open_forecast' => Icons.trending_up_rounded,
        'open_orders' => Icons.receipt_long_outlined,
        'send_order' => Icons.send_rounded,
        _ => Icons.arrow_forward_rounded,
      };
}
