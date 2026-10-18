import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'km_button.dart';

/// Loading / error / data with pull-to-refresh, shared by the list screens.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.builder,
  });

  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      color: KmColors.saffron,
      onRefresh: () async {
        try {
          await onRefresh();
        } catch (_) {
          // The provider surfaces the error state; nothing to do here.
        }
      },
      child: value.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            EmptyHint(text: l.errorLoading, icon: Icons.cloud_off_rounded),
            const SizedBox(height: 12),
            Center(
              child: KmButton(
                variant: KmButtonVariant.ghost,
                icon: Icons.refresh_rounded,
                label: l.retry,
                onPressed: onRefresh,
              ),
            ),
          ],
        ),
        data: (d) => builder(d),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 64, color: KmColors.inkFaint),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center, style: KmText.body),
        ),
      ],
    );
  }
}
