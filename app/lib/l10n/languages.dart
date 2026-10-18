import 'package:flutter/material.dart';

/// Script families that decide which Noto Sans face the UI uses.
enum KmScript { latin, devanagari, bengali, gurmukhi, gujarati, oriya, tamil, telugu, kannada, malayalam, olChiki, arabic }

/// One row of GET /languages. Kept locally as the fallback and as the
/// source for the picker (handoff: 22 scheduled languages + en + hi-Latn).
class KmLanguage {
  const KmLanguage({
    required this.code,
    required this.nameEn,
    required this.nameNative,
    required this.script,
    this.rtl = false,
  });

  final String code;
  final String nameEn;
  final String nameNative;
  final KmScript script;
  final bool rtl;

  /// Flutter locale for this code; Hinglish is hi with the Latn script.
  Locale get locale => code == 'hi-Latn'
      ? const Locale.fromSubtags(languageCode: 'hi', scriptCode: 'Latn')
      : Locale(code);

  factory KmLanguage.fromJson(Map<String, dynamic> j) {
    final code = j['code'] as String? ?? 'en';
    final local = kLanguages.where((l) => l.code == code).firstOrNull;
    return KmLanguage(
      code: code,
      nameEn: j['name_en'] as String? ?? local?.nameEn ?? code,
      nameNative: j['name_native'] as String? ?? local?.nameNative ?? code,
      script: local?.script ?? _scriptFromName(j['script'] as String?),
      rtl: j['rtl'] as bool? ?? local?.rtl ?? false,
    );
  }

  static KmScript _scriptFromName(String? s) => switch ((s ?? '').toLowerCase()) {
        'devanagari' => KmScript.devanagari,
        'bengali' || 'bangla' => KmScript.bengali,
        'gurmukhi' => KmScript.gurmukhi,
        'gujarati' => KmScript.gujarati,
        'oriya' || 'odia' => KmScript.oriya,
        'tamil' => KmScript.tamil,
        'telugu' => KmScript.telugu,
        'kannada' => KmScript.kannada,
        'malayalam' => KmScript.malayalam,
        'ol chiki' || 'olchiki' => KmScript.olChiki,
        'arabic' || 'perso-arabic' || 'nastaliq' => KmScript.arabic,
        _ => KmScript.latin,
      };
}

/// The 22 scheduled languages plus English and Hinglish. Manipuri uses the
/// Bengali script here (the script most Manipuri speakers still read).
const List<KmLanguage> kLanguages = [
  KmLanguage(code: 'hi-Latn', nameEn: 'Hinglish', nameNative: 'Hinglish', script: KmScript.latin),
  KmLanguage(code: 'hi', nameEn: 'Hindi', nameNative: 'हिंदी', script: KmScript.devanagari),
  KmLanguage(code: 'en', nameEn: 'English', nameNative: 'English', script: KmScript.latin),
  KmLanguage(code: 'bn', nameEn: 'Bengali', nameNative: 'বাংলা', script: KmScript.bengali),
  KmLanguage(code: 'mr', nameEn: 'Marathi', nameNative: 'मराठी', script: KmScript.devanagari),
  KmLanguage(code: 'te', nameEn: 'Telugu', nameNative: 'తెలుగు', script: KmScript.telugu),
  KmLanguage(code: 'ta', nameEn: 'Tamil', nameNative: 'தமிழ்', script: KmScript.tamil),
  KmLanguage(code: 'gu', nameEn: 'Gujarati', nameNative: 'ગુજરાતી', script: KmScript.gujarati),
  KmLanguage(code: 'ur', nameEn: 'Urdu', nameNative: 'اردو', script: KmScript.arabic, rtl: true),
  KmLanguage(code: 'kn', nameEn: 'Kannada', nameNative: 'ಕನ್ನಡ', script: KmScript.kannada),
  KmLanguage(code: 'or', nameEn: 'Odia', nameNative: 'ଓଡ଼ିଆ', script: KmScript.oriya),
  KmLanguage(code: 'ml', nameEn: 'Malayalam', nameNative: 'മലയാളം', script: KmScript.malayalam),
  KmLanguage(code: 'pa', nameEn: 'Punjabi', nameNative: 'ਪੰਜਾਬੀ', script: KmScript.gurmukhi),
  KmLanguage(code: 'as', nameEn: 'Assamese', nameNative: 'অসমীয়া', script: KmScript.bengali),
  KmLanguage(code: 'mai', nameEn: 'Maithili', nameNative: 'मैथिली', script: KmScript.devanagari),
  KmLanguage(code: 'sa', nameEn: 'Sanskrit', nameNative: 'संस्कृतम्', script: KmScript.devanagari),
  KmLanguage(code: 'ne', nameEn: 'Nepali', nameNative: 'नेपाली', script: KmScript.devanagari),
  KmLanguage(code: 'kok', nameEn: 'Konkani', nameNative: 'कोंकणी', script: KmScript.devanagari),
  KmLanguage(code: 'doi', nameEn: 'Dogri', nameNative: 'डोगरी', script: KmScript.devanagari),
  KmLanguage(code: 'brx', nameEn: 'Bodo', nameNative: 'बड़ो', script: KmScript.devanagari),
  KmLanguage(code: 'sat', nameEn: 'Santali', nameNative: 'ᱥᱟᱱᱛᱟᱲᱤ', script: KmScript.olChiki),
  KmLanguage(code: 'mni', nameEn: 'Manipuri', nameNative: 'মৈতৈলোন্', script: KmScript.bengali),
  KmLanguage(code: 'ks', nameEn: 'Kashmiri', nameNative: 'کٲشُر', script: KmScript.arabic, rtl: true),
  KmLanguage(code: 'sd', nameEn: 'Sindhi', nameNative: 'سنڌي', script: KmScript.arabic, rtl: true),
];

KmLanguage languageFor(String code) =>
    kLanguages.where((l) => l.code == code).firstOrNull ?? kLanguages.first;

/// Maps a stored language code to a locale that has an .arb file.
Locale localeFor(String code) => languageFor(code).locale;
