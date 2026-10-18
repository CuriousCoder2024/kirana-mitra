import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../theme.dart';
import '../widgets/async_body.dart';

class UdhaarScreen extends ConsumerWidget {
  const UdhaarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ledger = ref.watch(ledgerProvider);
    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: Text(l.udhaarTitle)),
      body: AsyncBody<LedgerResponse>(
        value: ledger,
        onRefresh: () => ref.refresh(ledgerProvider.future),
        builder: (data) {
          final customers = [...data.customers]..sort((a, b) => b.balance.compareTo(a.balance));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: customers.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [KmColors.saffron, KmColors.terracotta],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.totalOutstanding, style: const TextStyle(fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        rupee.format(data.totalOutstanding),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(l.customersCount(customers.length), style: const TextStyle(fontSize: 15, color: Colors.white70)),
                    ],
                  ),
                );
              }
              if (customers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(l.emptyLedger, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                );
              }
              final c = customers[i - 1];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: KmColors.userBubble,
                    child: Text(
                      c.customerName.isEmpty ? '?' : c.customerName.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: KmColors.terracotta),
                    ),
                  ),
                  title: Text(c.customerName, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: c.lastEntryAt == null
                      ? null
                      : Text(l.lastEntry(_fmtDate(c.lastEntryAt!)), style: Theme.of(context).textTheme.bodySmall),
                  trailing: Text(
                    rupee.format(c.balance),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: c.balance > 0 ? KmColors.terracotta : KmColors.leaf,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _fmtDate(String iso) {
    try {
      return DateFormat('d MMM').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}
