import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/chat_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/udhaar_screen.dart';
import 'state/shop_prefs.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    redirect: (context, state) {
      final onboarded = ref.read(shopPrefsProvider).isOnboarded;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/chat';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/chat', builder: (_, _) => const ChatScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/stock', builder: (_, _) => const StockScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/udhaar', builder: (_, _) => const UdhaarScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/forecast', builder: (_, _) => const ForecastScreen())]),
        ],
      ),
    ],
  );
});

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.mic_none_rounded), selectedIcon: const Icon(Icons.mic_rounded), label: l.navChat),
          NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2_rounded), label: l.navStock),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet_rounded), label: l.navUdhaar),
          NavigationDestination(icon: const Icon(Icons.trending_up_rounded), selectedIcon: const Icon(Icons.insights_rounded), label: l.navForecast),
        ],
      ),
    );
  }
}
