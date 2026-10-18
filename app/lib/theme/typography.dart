import 'package:flutter/material.dart';

import 'tokens.dart';

/// Type scale from docs/design/handoff.md §2. Baloo 2 for display, titles,
/// numbers and nav labels; Noto Sans (+ Devanagari fallback) for body copy.
/// The three families are bundled as variable TTFs under app/fonts/ so the
/// app renders the same offline and on a cheap phone.
abstract final class KmText {
  static const _tabular = [FontFeature.tabularFigures()];

  static const balooFamily = 'Baloo 2';
  static const notoFamily = 'Noto Sans';
  static const devanagariFamily = 'Noto Sans Devanagari';

  static const List<String> _fallback = [devanagariFamily, notoFamily, 'sans-serif'];

  /// Variable fonts need the wght axis set explicitly on every platform.
  static double _wght(FontWeight w) => w.value.toDouble();

  static TextStyle _baloo({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = KmColors.ink,
    bool tabular = false,
  }) =>
      TextStyle(
        fontFamily: balooFamily,
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', _wght(weight))],
        height: height,
        color: color,
        fontFeatures: tabular ? _tabular : null,
      );

  static TextStyle _noto({
    required double size,
    required FontWeight weight,
    double height = 1.35,
    Color color = KmColors.ink,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: notoFamily,
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', _wght(weight))],
        height: height,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Baloo 2 roles.
  static TextStyle get display => _baloo(size: 40, weight: FontWeight.w800, height: 1.05);
  static TextStyle get ledgerAmount =>
      _baloo(size: 46, weight: FontWeight.w800, height: 1.0, tabular: true, color: KmColors.white);
  static TextStyle get title => _baloo(size: 28, weight: FontWeight.w700, height: 1.15);
  static TextStyle get sheetTitle => _baloo(size: 24, weight: FontWeight.w700, height: 1.15);
  static TextStyle get heading => _baloo(size: 22, weight: FontWeight.w700, height: 1.2);
  static TextStyle get numberL => _baloo(size: 32, weight: FontWeight.w800, height: 1.0, tabular: true);
  static TextStyle get numberM => _baloo(size: 26, weight: FontWeight.w800, height: 1.0, tabular: true);
  static TextStyle get numberS => _baloo(size: 24, weight: FontWeight.w800, height: 1.1, tabular: true);
  static TextStyle get timer =>
      _baloo(size: 34, weight: FontWeight.w800, height: 1.0, tabular: true, color: KmColors.terracotta);
  static TextStyle get tileLetter => _baloo(size: 20, weight: FontWeight.w800, height: 1.0);
  static TextStyle get peakValue => _baloo(size: 14, weight: FontWeight.w800, height: 1.0);
  static TextStyle get navLabel => _noto(size: 13, weight: FontWeight.w600, height: 1.0);

  // Noto Sans roles.
  static TextStyle get body => _noto(size: 18, weight: FontWeight.w400);
  static TextStyle get bodyBold => _noto(size: 18, weight: FontWeight.w700);
  static TextStyle get bodySemi => _noto(size: 18, weight: FontWeight.w600);
  static TextStyle get button => _noto(size: 19, weight: FontWeight.w600, height: 1.0);
  static TextStyle get buttonSmall => _noto(size: 17, weight: FontWeight.w600, height: 1.0);
  static TextStyle get chip => _noto(size: 17, weight: FontWeight.w600, height: 1.0);
  static TextStyle get rowTitle => _noto(size: 17, weight: FontWeight.w700, height: 1.2);
  static TextStyle get caption => _noto(size: 15, weight: FontWeight.w400, color: KmColors.inkSoft);
  static TextStyle get captionSemi => _noto(size: 15, weight: FontWeight.w600, color: KmColors.inkSoft);
  static TextStyle get caption14 => _noto(size: 14, weight: FontWeight.w400, color: KmColors.inkSoft);
  static TextStyle get caption14Semi => _noto(size: 14, weight: FontWeight.w600, color: KmColors.inkSoft);
  static TextStyle get label =>
      _noto(size: 14, weight: FontWeight.w700, height: 1.0, letterSpacing: 0.28);
  static TextStyle get labelSmall =>
      _noto(size: 12, weight: FontWeight.w700, height: 1.0, letterSpacing: 0.24);
  static TextStyle get sectionLabel =>
      _noto(size: 15, weight: FontWeight.w700, height: 1.0, color: KmColors.inkSoft, letterSpacing: 0.6);
  static TextStyle get status => _noto(size: 13, weight: FontWeight.w600, height: 1.2, color: KmColors.inkSoft);
  static TextStyle get meta => _noto(size: 14, weight: FontWeight.w400, color: KmColors.inkSoft);
  static TextStyle get micLabel => _noto(size: 14, weight: FontWeight.w600, height: 1.0, color: KmColors.saffron);
  static TextStyle get legend => _noto(size: 13, weight: FontWeight.w400, color: KmColors.inkSoft);
  static TextStyle get axis => _noto(size: 11, weight: FontWeight.w400, height: 1.0, color: KmColors.inkSoft);

  /// Wires the scale into the Material text theme so widgets we do not
  /// restyle (dialogs, tooltips) still look native.
  static TextTheme materialTheme() => TextTheme(
        displayLarge: display,
        displayMedium: title,
        headlineMedium: heading,
        titleLarge: sheetTitle,
        titleMedium: bodyBold,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label,
        labelSmall: status,
      );
}
