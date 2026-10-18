import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

export 'script_fonts.dart';
export 'tokens.dart';
export 'typography.dart';

/// Light-only Material theme carrying the v2 tokens. Components are built in
/// lib/widgets/ from the tokens directly; this theme only covers what
/// Material draws on its own (fields, sheets, snackbars, progress).
ThemeData buildKmTheme() {
  final scheme = const ColorScheme.light(
    primary: KmColors.saffron,
    onPrimary: KmColors.white,
    secondary: KmColors.terracotta,
    onSecondary: KmColors.white,
    surface: KmColors.cream,
    onSurface: KmColors.ink,
    error: KmColors.mirchi,
    onError: KmColors.white,
    outline: KmColors.sand,
  ).copyWith(surfaceContainerHighest: KmColors.sand);

  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(KmRadius.field),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: KmColors.cream,
    canvasColor: KmColors.paper,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: KmText.materialTheme(),
    splashFactory: InkSparkle.splashFactory,
    iconTheme: const IconThemeData(color: KmColors.ink, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: KmColors.cream,
      foregroundColor: KmColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: KmSize.appBar,
      titleTextStyle: KmText.heading,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KmColors.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(KmColors.sand, 2),
      enabledBorder: border(KmColors.sand, 2),
      focusedBorder: border(KmColors.saffron, 2),
      errorBorder: border(KmColors.saffron, 2),
      focusedErrorBorder: border(KmColors.saffron, 2),
      labelStyle: KmText.status,
      floatingLabelStyle: KmText.status,
      hintStyle: KmText.body.copyWith(color: KmColors.inkFaint),
      errorStyle: KmText.caption.copyWith(color: KmColors.saffron, fontSize: 14),
      prefixIconColor: KmColors.inkSoft,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: KmColors.paper,
      modalBackgroundColor: KmColors.paper,
      modalBarrierColor: Color(0x732A1A10),
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KmRadius.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: KmColors.ink,
      contentTextStyle: KmText.body.copyWith(color: KmColors.white, fontSize: 16),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KmRadius.buttonSmall)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: KmColors.saffron),
    dividerTheme: const DividerThemeData(color: KmColors.sand, thickness: 1, space: 1),
    popupMenuTheme: PopupMenuThemeData(
      color: KmColors.paper,
      textStyle: KmText.body,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KmRadius.field)),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: KmText.caption.copyWith(color: KmColors.white),
      decoration: BoxDecoration(color: KmColors.ink, borderRadius: BorderRadius.circular(8)),
    ),
  );
}
