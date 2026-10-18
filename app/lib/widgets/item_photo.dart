import 'package:flutter/material.dart';

import '../assets/item_photo_lookup.dart';
import '../theme/theme.dart';
import 'km_row.dart';

/// 44 dp item tile: the bundled product thumb when one matches, else the
/// letter tile. Thumbs are 120 px centre crops, so nothing large is decoded.
class ItemPhoto extends StatelessWidget {
  const ItemPhoto({
    super.key,
    required this.itemId,
    required this.name,
    required this.index,
    this.size = 44,
    this.badge,
  });

  final String itemId;
  final String name;
  final int index;
  final double size;

  /// Small overlay text (e.g. a rank) drawn at the bottom-right.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final asset = itemPhotoAsset(itemId, name);
    final fallback = ItemTile(name: name, index: index);
    Widget tile = asset == null
        ? fallback
        : ClipRRect(
            borderRadius: BorderRadius.circular(KmRadius.tile),
            child: Image.asset(
              asset,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 3).round(),
              errorBuilder: (_, _, _) => fallback,
            ),
          );
    if (size != 44) tile = SizedBox(width: size, height: size, child: FittedBox(child: tile));
    if (badge == null) return tile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: KmColors.saffron,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: KmColors.paper, width: 1.5),
            ),
            child: Text(badge!, style: KmText.labelSmall.copyWith(color: KmColors.white, letterSpacing: 0)),
          ),
        ),
      ],
    );
  }
}
