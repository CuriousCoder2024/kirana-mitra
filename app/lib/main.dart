import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_provider.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_delegates.dart';
import 'l10n/languages.dart';
import 'router.dart';
import 'state/shop_prefs.dart';
import 'theme/theme.dart';
import 'widgets/logo_mark.dart';

/// Resolves once prefs, the backend probe and the script face for the
/// stored language are all ready, so the root switches from the splash to
/// the router exactly once (and once more after a language change).
final appReadyProvider = FutureProvider<String>((ref) async {
  await ref.watch(sharedPreferencesProvider.future);
  await ref.watch(apiClientFutureProvider.future);
  final code = ref.watch(shopPrefsProvider.select((p) => p.language));
  await ensureScriptFont(languageFor(code).script);
  return code;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // No automatic retries: a failed request shows its error state with a
      // retry button instead of a spinner while Riverpod backs off.
      retry: (retryCount, error) => null,
      child: const KiranaMitraApp(),
    ),
  );
}

class KiranaMitraApp extends ConsumerWidget {
  const KiranaMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(appReadyProvider);
    if (!ready.hasValue) {
      KmText.scriptFamily = null;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildKmTheme(),
        home: const _Splash(),
      );
    }

    final code = ready.requireValue;
    final language = languageFor(code);
    // Latin and Devanagari use the bundled fonts; other scripts fetch their
    // Noto Sans face through google_fonts on first use.
    KmText.scriptFamily = switch (language.script) {
      KmScript.latin || KmScript.devanagari => null,
      final s => scriptFamily(s),
    };
    final theme = buildKmTheme();
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      key: ValueKey(code),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: theme,
      locale: language.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
      ],
      supportedLocales: [for (final l in kLanguages) l.locale],
      localeResolutionCallback: (requested, supported) {
        if (requested == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == requested.languageCode && s.scriptCode == requested.scriptCode) return s;
        }
        for (final s in supported) {
          if (s.languageCode == requested.languageCode) return s;
        }
        return const Locale('en');
      },
      routerConfig: router,
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: KmColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoMark(size: 84),
            SizedBox(height: 20),
            Text('Kirana Mitra', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: KmColors.ink)),
            SizedBox(height: 24),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: KmColors.saffron, strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
