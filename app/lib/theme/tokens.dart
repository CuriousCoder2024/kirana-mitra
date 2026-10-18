import 'package:flutter/material.dart';

/// Colour tokens from docs/design/handoff.md §1. Use these names in code;
/// never an ad-hoc Color in a screen or widget.
abstract final class KmColors {
  static const saffron = Color(0xFFC85A0E);
  static const saffronBright = Color(0xFFF08A2C);
  static const saffronTint = Color(0xFFFFE6CC);
  static const saffronWash = Color(0xFFFFF4E6);
  static const saffronShadow = Color(0xFF8F3E07);
  static const terracotta = Color(0xFFA83E12);
  static const terracottaSpine = Color(0xFF8E3310);
  static const cream = Color(0xFFFBF1E2);
  static const paper = Color(0xFFFFFCF7);
  static const sand = Color(0xFFEBDAC1);
  static const ink = Color(0xFF2A1A10);
  static const inkSoft = Color(0xFF6E5240);
  static const inkFaint = Color(0xFFA58B77);
  static const leaf = Color(0xFF2F7A4B);
  static const leafShadow = Color(0xFF1F5533);
  static const leafTint = Color(0xFFDDF0E2);
  static const mirchi = Color(0xFFB3261E);
  static const mirchiTint = Color(0xFFFBE1DE);
  static const mirchiBorder = Color(0xFFEFC2BD);
  static const lowRowWash = Color(0xFFFFF7F3);
  static const haldi = Color(0xFFE9A826);
  static const haldiTint = Color(0xFFFFF1CF);
  static const haldiBorder = Color(0xFFF3D98F);
  static const haldiText = Color(0xFF8A5A00);
  static const haldiDeep = Color(0xFFB07400);
  static const whatsapp = Color(0xFF1FA855);
  static const whatsappShadow = Color(0xFF157A3C);
  static const white = Color(0xFFFFFFFF);

  /// Tile backgrounds for item rows, cycled by index.
  static const itemTiles = [saffronTint, leafTint, haldiTint, sand];

  /// Avatar fills for customer rows, cycled by index.
  static const avatarFills = [terracotta, saffron, haldiText, inkSoft, leaf];
}

/// Spacing on the 4 dp grid (§3).
abstract final class KmSpace {
  static const double gutter = 16;
  static const double card = 16;
  static const double chartCard = 14;
  static const double cardGap = 12;
  static const double section = 24;
  static const double bubbleGap = 10;
}

/// Corner radii (§3).
abstract final class KmRadius {
  static const double card = 20;
  static const double bubbleTight = 6;
  static const double button = 18;
  static const double buttonSmall = 14;
  static const double field = 16;
  static const double row = 18;
  static const double sheet = 28;
  static const double tile = 12;
  static const double khata = 22;
}

/// Tap target sizes (§3).
abstract final class KmSize {
  static const double chip = 48;
  static const double button = 56;
  static const double buttonSmall = 48;
  static const double buttonTall = 60;
  static const double micHero = 80;
  static const double micRecording = 92;
  static const double micFab = 60;
  static const double appBar = 64;
  static const double navBar = 72;
  static const double dock = 94;
  static const double micRaise = 30;
  static const double row = 72;
  static const double field = 60;
}

/// Shadows (§1): hard 2 dp bottom shadow under filled buttons, soft glow on
/// the mic, nothing on cards.
abstract final class KmShadow {
  static List<BoxShadow> hard(Color color) => [
        BoxShadow(color: color, offset: const Offset(0, 2), blurRadius: 0),
      ];

  static List<BoxShadow> get micGlow => [
        BoxShadow(
          color: KmColors.saffron.withValues(alpha: 0.35),
          blurRadius: 18,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
}
