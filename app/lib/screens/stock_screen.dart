import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../theme.dart';
import '../widgets/async_body.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stock = ref.watch(stockProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.stockTitle)),
      body: AsyncBody<StockResponse>(
        value: stock,
        onRefresh: () => ref.refresh(stockProvider.future),
        builder: (data) {
          final items = [...data.items]
            ..sort((a, b) {
              if (a.lowStock != b.lowStock) return a.lowStock ? -1 : 1;
              return a.name.compareTo(b.name);
            });
          final low = items.where((i) => i.lowStock).length;
          if (items.isEmpty) return EmptyHint(text: l.emptyStock, icon: Icons.inventory_2_outlined);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        low > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: low > 0 ? KmColors.alert : KmColors.leaf,
                      ),
                      const SizedBox(width: 8),
                      Text(l.lowStockCount(low), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                );
              }
              return _StockTile(item: items[i - 1], lowLabel: l.lowStockBadge, reorderAt: l.reorderAt);
            },
          );
        },
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.item, required this.lowLabel, required this.reorderAt});

  final StockItem item;
  final String lowLabel;
  final String Function(String) reorderAt;

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.lowStock ? const Color(0xFFFFE5E2) : KmColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: item.lowStock ? KmColors.alert : KmColors.saffron,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.packSize == null || item.packSize!.isEmpty ? item.name : '${item.name} ${item.packSize}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(reorderAt('${item.reorderLevel}'), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: qty,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: item.lowStock ? KmColors.alert : KmColors.brown,
                        ),
                      ),
                      TextSpan(text: ' ${item.unit}', style: const TextStyle(fontSize: 15, color: KmColors.brownSoft)),
                    ],
                  ),
                ),
                if (item.lowStock)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KmColors.alert,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lowLabel,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
