import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'languages.dart';

/// Flutter ships Material/Cupertino strings for ~80 locales; several of the
/// 22 scheduled languages (brx, doi, kok, ks, mai, mni, sa, sat, sd) are not
/// among them. These delegates accept every locale and fall back to English
/// for the framework's own strings, while the app's strings still come from
/// the matching .arb. Text direction follows the language table.
class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    const global = GlobalMaterialLocalizations.delegate;
    return global.load(global.isSupported(locale) ? locale : const Locale('en'));
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    const global = GlobalCupertinoLocalizations.delegate;
    return global.load(global.isSupported(locale) ? locale : const Locale('en'));
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    const global = GlobalWidgetsLocalizations.delegate;
    if (global.isSupported(locale)) return global.load(locale);
    final rtl = kLanguages.any((l) => l.locale.languageCode == locale.languageCode && l.rtl);
    return Future.value(rtl ? const _RtlWidgetsLocalizations() : const DefaultWidgetsLocalizations());
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

class _RtlWidgetsLocalizations extends DefaultWidgetsLocalizations {
  const _RtlWidgetsLocalizations();

  @override
  TextDirection get textDirection => TextDirection.rtl;
}
