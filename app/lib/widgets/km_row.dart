import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'km_badge.dart';

/// Rounded container that holds [KmRow]s separated by 1 dp sand borders.
class KmRowGroup extends StatelessWidget {
  const KmRowGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: BorderRadius.circular(KmRadius.row),
        border: Border.all(color: KmColors.sand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Handoff §4.7 list row: 44 dp tile, title + caption, number + unit or badge.
class KmRow extends StatelessWidget {
  const KmRow({
    super.key,
    required this.leading,
    required this.title,
    this.caption,
    this.value,
    this.valueColor = KmColors.ink,
    this.valueCaption,
    this.badge,
    this.trailing,
    this.low = false,
    this.onTap,
    this.minHeight = KmSize.row,
  });

  final Widget leading;
  final String title;
  final String? caption;
  final String? value;
  final Color valueColor;
  final String? valueCaption;
  final KmBadge? badge;
  final Widget? trailing;
  final bool low;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: low ? KmColors.lowRowWash : KmColors.paper,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: KmText.bodyBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (caption != null && caption!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(caption!, style: KmText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (trailing != null)
                  trailing!
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value != null) Text(value!, style: KmText.numberM.copyWith(color: valueColor)),
                      if (badge != null) ...[
                        const SizedBox(height: 4),
                        badge!,
                      ] else if (valueCaption != null) ...[
                        const SizedBox(height: 2),
                        Text(valueCaption!, style: KmText.caption14),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 44 dp square tile with the item's first letter (radius 12).
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.name, required this.index});

  final String name;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KmColors.itemTiles[index % KmColors.itemTiles.length],
        borderRadius: BorderRadius.circular(KmRadius.tile),
      ),
      child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(), style: KmText.tileLetter),
    );
  }
}

/// 44 dp round avatar with the customer's initials in white.
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({super.key, required this.name, required this.index, this.size = 44});

  final String name;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KmColors.avatarFills[index % KmColors.avatarFills.length],
        shape: BoxShape.circle,
      ),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: KmText.tileLetter.copyWith(color: KmColors.white, fontSize: size * 0.4),
      ),
    );
  }
}
