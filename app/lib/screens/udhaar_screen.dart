import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../state/history_store.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import '../widgets/async_body.dart';
import '../widgets/khata_card.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/km_badge.dart';
import '../widgets/km_row.dart';
import '../widgets/tab_scaffold.dart';

class UdhaarScreen extends ConsumerWidget {
  const UdhaarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ledger = ref.watch(ledgerProvider);
    final history = ref.watch(historyStoreProvider.notifier).live;
    final count = ledger.value?.customers.length;

    // Today's movement from the local history (the ledger has no sign).
    final today = history.where((e) => e.isUdhaar && Fmt.sameDay(e.at, DateTime.now()));
    final given = today.where((e) => e.intent == 'udhaar_given').fold<num>(0, (a, e) => a + (e.amount ?? 0));
    final received = today.where((e) => e.intent == 'udhaar_paid').fold<num>(0, (a, e) => a + (e.amount ?? 0));
    final movement = [
      if (given > 0) l.todayGiven(Fmt.int(given)),
      if (received > 0) l.todayReceived(Fmt.int(received)),
    ].join(' · ');

    String caption(LedgerCustomer c) {
      final date = Fmt.parse(c.lastEntryAt);
      final last = history.where((e) => e.isUdhaar && (e.customerName ?? '').toLowerCase() == c.customerName.toLowerCase()).firstOrNull;
      final d = last?.at ?? date;
      if (d == null) return '';
      if (last != null && last.amount != null) {
        return last.intent == 'udhaar_paid'
            ? l.lastMovementPaid(Fmt.dayMonth(d), Fmt.int(last.amount!))
            : l.lastMovementGiven(Fmt.dayMonth(d), Fmt.int(last.amount!));
      }
      return Fmt.dayMonth(d);
    }

    return TabScaffold(
      appBar: KmAppBar(title: l.udhaarTitle, subtitle: count == null ? null : l.udhaarSubtitle(count)),
      body: AsyncBody<LedgerResponse>(
        value: ledger,
        onRefresh: () => ref.refresh(ledgerProvider.future),
        builder: (data) {
          final customers = [...data.customers]
            ..sort((a, b) {
              final aSettled = a.balance <= 0;
              final bSettled = b.balance <= 0;
              if (aSettled != bSettled) return aSettled ? 1 : -1;
              return b.balance.compareTo(a.balance);
            });
          return ListView(
            padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 120),
            children: [
              KhataCard(
                label: l.totalOutstanding,
                amount: Fmt.rupee(data.totalOutstanding),
                line: movement.isEmpty ? null : movement,
              ),
              const SizedBox(height: KmSpace.cardGap),
              if (customers.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(l.emptyLedger, textAlign: TextAlign.center, style: KmText.body),
                )
              else
                KmRowGroup(
                  children: [
                    for (var i = 0; i < customers.length; i++)
                      KmRow(
                        leading: CustomerAvatar(name: customers[i].customerName, index: i),
                        title: customers[i].customerName,
                        caption: caption(customers[i]),
                        value: customers[i].balance > 0 ? Fmt.rupee(customers[i].balance) : null,
                        valueColor: KmColors.terracotta,
                        valueCaption: customers[i].balance > 0 ? l.owedCaption : null,
                        badge: customers[i].balance > 0 ? null : KmBadge(variant: KmBadgeVariant.ok, label: l.settledBadge),
                        onTap: () => context.go('/udhaar/customer/${Uri.encodeComponent(customers[i].customerName)}'),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
