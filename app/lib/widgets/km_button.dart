import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum KmButtonVariant { primary, leaf, whatsapp, outline, undo, ghost }

enum KmButtonSize { regular, small, tall }

/// Handoff §4.1. One `primary` per screen at most.
class KmButton extends StatelessWidget {
  const KmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KmButtonVariant.primary,
    this.size = KmButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.block = false,
    this.loading = false,
  });

  const KmButton.undo({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = KmButtonSize.small,
    this.block = false,
    this.loading = false,
  })  : variant = KmButtonVariant.undo,
        icon = Icons.undo_rounded,
        trailingIcon = null;

  final String label;
  final VoidCallback? onPressed;
  final KmButtonVariant variant;
  final KmButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool block;
  final bool loading;

  double get _height => switch (size) {
        KmButtonSize.regular => KmSize.button,
        KmButtonSize.small => KmSize.buttonSmall,
        KmButtonSize.tall => KmSize.buttonTall,
      };

  @override
  Widget build(BuildContext context) {
    final small = size == KmButtonSize.small;
    final ghost = variant == KmButtonVariant.ghost;
    final (Color fill, Color fg, Color? borderColor, Color? shadow) = switch (variant) {
      KmButtonVariant.primary => (KmColors.saffron, KmColors.white, null, KmColors.saffronShadow),
      KmButtonVariant.leaf => (KmColors.leaf, KmColors.white, null, KmColors.leafShadow),
      KmButtonVariant.whatsapp => (KmColors.whatsapp, KmColors.white, null, KmColors.whatsappShadow),
      KmButtonVariant.outline => (KmColors.paper, KmColors.ink, KmColors.sand, null),
      KmButtonVariant.undo => (KmColors.paper, KmColors.terracotta, KmColors.terracotta, null),
      KmButtonVariant.ghost => (Colors.transparent, KmColors.saffron, null, null),
    };
    final enabled = onPressed != null && !loading;
    final radius = BorderRadius.circular(small ? KmRadius.buttonSmall : KmRadius.button);
    final textStyle = (small ? KmText.buttonSmall : KmText.button).copyWith(color: fg);
    final leading = variant == KmButtonVariant.whatsapp && icon == null ? Icons.send_rounded : icon;

    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        else if (leading != null)
          Icon(leading, size: 24, color: fg),
        if (loading || leading != null) const SizedBox(width: 10),
        Flexible(
          child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 10),
          Icon(trailingIcon, size: 24, color: fg),
        ],
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        height: ghost ? KmSize.buttonSmall : _height,
        width: block ? double.infinity : null,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: radius,
          border: borderColor == null ? null : Border.all(color: borderColor, width: 2),
          boxShadow: shadow == null || !enabled ? null : KmShadow.hard(shadow),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: small ? (block ? 12 : 16) : 22),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
