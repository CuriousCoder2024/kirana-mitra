import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_provider.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'state/shop_prefs.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KiranaMitraApp()));
}

class KiranaMitraApp extends ConsumerWidget {
  const KiranaMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final api = ref.watch(apiClientFutureProvider);
    final theme = buildKmTheme();

    // Never spin forever: a failed startup provider is reported on the splash
    // (and in the log) rather than leaving the user on a spinner.
    final startupError = prefs.error ?? api.error;
    if (startupError != null) {
      debugPrint('Kirana Mitra: startup failed: $startupError');
    }
    if (prefs.isLoading || api.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: _Splash(error: startupError?.toString()),
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
  const _Splash({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KmColors.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: KmColors.saffron,
                child: Icon(Icons.storefront_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('Kirana Mitra', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: KmColors.brown)),
              const SizedBox(height: 24),
              if (error == null)
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: KmColors.saffron, strokeWidth: 3))
              else
                Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: KmColors.terracotta, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
