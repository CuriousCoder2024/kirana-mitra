import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/languages.dart';

/// Noto Sans face per script, fetched on demand through google_fonts so the
/// bundle stays small. Urdu, Kashmiri and Sindhi use Noto Nastaliq Urdu.
/// Manipuri is rendered in the Bengali script (see kLanguages).
TextStyle scriptStyle(KmScript script, {TextStyle? base}) => switch (script) {
      KmScript.devanagari => GoogleFonts.notoSansDevanagari(textStyle: base),
      KmScript.bengali => GoogleFonts.notoSansBengali(textStyle: base),
      KmScript.gurmukhi => GoogleFonts.notoSansGurmukhi(textStyle: base),
      KmScript.gujarati => GoogleFonts.notoSansGujarati(textStyle: base),
      KmScript.oriya => GoogleFonts.notoSansOriya(textStyle: base),
      KmScript.tamil => GoogleFonts.notoSansTamil(textStyle: base),
      KmScript.telugu => GoogleFonts.notoSansTelugu(textStyle: base),
      KmScript.kannada => GoogleFonts.notoSansKannada(textStyle: base),
      KmScript.malayalam => GoogleFonts.notoSansMalayalam(textStyle: base),
      KmScript.olChiki => GoogleFonts.notoSansOlChiki(textStyle: base),
      KmScript.arabic => GoogleFonts.notoNastaliqUrdu(textStyle: base),
      KmScript.latin => GoogleFonts.notoSans(textStyle: base),
    };

/// Family name for a script (triggers the font download on first use).
String scriptFamily(KmScript script) => scriptStyle(script).fontFamily!;

/// Fallback chain for a script: its own face first, then the bundled Noto
/// Sans Devanagari and Noto Sans so mixed Hinglish lines still render.
List<String> scriptFallback(KmScript script) => [
      scriptFamily(script),
      'Noto Sans Devanagari',
      'Noto Sans',
      'sans-serif',
    ];

/// Waits for the weights the type scale uses so nothing paints as boxes
/// while the download is still in flight. Latin and Devanagari are bundled.
Future<void> ensureScriptFont(KmScript script) async {
  if (script == KmScript.latin || script == KmScript.devanagari) return;
  await GoogleFonts.pendingFonts([
    for (final w in const [FontWeight.w400, FontWeight.w600, FontWeight.w700, FontWeight.w800])
      scriptStyle(script, base: TextStyle(fontWeight: w)),
  ]);
}

/// Preloads every script face once so the picker grid shows all names.
Future<void> preloadScriptFonts() async {
  await Future.wait([
    for (final script in KmScript.values) GoogleFonts.pendingFonts([scriptStyle(script)]),
  ]);
}
