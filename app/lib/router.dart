import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/chat_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/udhaar_screen.dart';
import 'state/shop_prefs.dart';
import 'widgets/km_nav_bar.dart';

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
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/udhaar',
              builder: (_, _) => const UdhaarScreen(),
              routes: [
                GoRoute(
                  path: 'customer/:name',
                  builder: (_, state) => CustomerScreen(name: Uri.decodeComponent(state.pathParameters['name'] ?? '')),
                ),
              ],
            ),
          ]),
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
      bottomNavigationBar: KmNavBar(
        selectedIndex: shell.currentIndex,
        onSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          KmNavItem(icon: Icons.mic_none_rounded, selectedIcon: Icons.mic_rounded, label: l.navChat),
          KmNavItem(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2_rounded, label: l.navStock),
          KmNavItem(icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet_rounded, label: l.navUdhaar),
          KmNavItem(icon: Icons.trending_up_rounded, selectedIcon: Icons.insights_rounded, label: l.navForecast),
        ],
      ),
    );
  }
}
