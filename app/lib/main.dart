import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_provider.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'state/shop_prefs.dart';
import 'theme/theme.dart';
import 'widgets/logo_mark.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KiranaMitraApp()));
}

class KiranaMitraApp extends ConsumerWidget {
  const KiranaMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsReady = ref.watch(sharedPreferencesProvider).hasValue;
    final apiReady = ref.watch(apiClientFutureProvider).hasValue;
    final theme = buildKmTheme();

    if (!prefsReady || !apiReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const _Splash(),
      );
    }

    final locale = ref.watch(shopPrefsProvider.select((p) => p.locale));
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
