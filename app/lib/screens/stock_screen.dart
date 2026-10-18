import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../state/shop_prefs.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import '../widgets/async_body.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/km_badge.dart';
import '../widgets/km_button.dart';
import '../widgets/km_row.dart';
import '../widgets/order_sheet.dart';
import '../widgets/tab_scaffold.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  bool _ordering = false;

  Future<void> _order() async {
    final l = AppLocalizations.of(context);
    setState(() => _ordering = true);
    try {
      final order = await ref.read(apiClientProvider).reorder(ref.read(shopPrefsProvider).shopId ?? '');
      ref.invalidate(ordersProvider);
      if (mounted) await showOrderSheet(context, order);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.networkError)));
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stock = ref.watch(stockProvider);
    final data = stock.value;
    final latest = data?.items.map((i) => Fmt.parse(i.updatedAt)).whereType<DateTime>().fold<DateTime?>(
          null,
          (a, b) => a == null || b.isAfter(a) ? b : a,
        );

    return TabScaffold(
      appBar: KmAppBar(
        title: l.stockTitle,
        subtitle: data == null ? null : l.stockSubtitle(data.items.length, latest == null ? '—' : Fmt.time(latest)),
      ),
      body: AsyncBody<StockResponse>(
        value: stock,
        onRefresh: () => ref.refresh(stockProvider.future),
        builder: (data) {
          final items = [...data.items]
            ..sort((a, b) {
              if (a.lowStock != b.lowStock) return a.lowStock ? -1 : 1;
              return a.name.compareTo(b.name);
            });
          if (items.isEmpty) return EmptyHint(text: l.emptyStock, icon: Icons.inventory_2_outlined);
          final low = items.where((i) => i.lowStock).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 120),
            children: [
              if (low.isNotEmpty)
                _LowBand(
                  title: l.lowBandTitle(low.length),
                  names: low.map((i) => i.name).join(', '),
                  buttonLabel: l.orderButton,
                  ordering: _ordering,
                  onOrder: _order,
                )
              else
                _AllGoodBand(label: l.allGoodBand),
              const SizedBox(height: KmSpace.cardGap),
              KmRowGroup(
                children: [
                  for (var i = 0; i < items.length; i++)
                    KmRow(
                      leading: ItemTile(name: items[i].name, index: i),
                      title: items[i].packSize == null || items[i].packSize!.isEmpty
                          ? items[i].name
                          : '${items[i].name} ${items[i].packSize}',
                      caption: l.reorderAt(Fmt.qty(items[i].reorderLevel)),
                      value: Fmt.qty(items[i].quantity),
                      valueColor: items[i].lowStock ? KmColors.mirchi : KmColors.ink,
                      valueCaption: items[i].unit,
                      badge: items[i].lowStock ? KmBadge(variant: KmBadgeVariant.low, label: l.lowStockBadge, inRow: true) : null,
                      low: items[i].lowStock,
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

class _LowBand extends StatelessWidget {
  const _LowBand({
    required this.title,
    required this.names,
    required this.buttonLabel,
    required this.ordering,
    required this.onOrder,
  });

  final String title;
  final String names;
  final String buttonLabel;
  final bool ordering;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KmColors.mirchiTint,
        borderRadius: BorderRadius.circular(KmRadius.row),
        border: Border.all(color: KmColors.mirchiBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_downward_rounded, size: 28, color: KmColors.mirchi),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KmText.bodyBold),
                const SizedBox(height: 2),
                Text(names, style: KmText.caption14, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          KmButton(
            size: KmButtonSize.small,
            label: buttonLabel,
            loading: ordering,
            onPressed: ordering ? null : onOrder,
          ),
        ],
      ),
    );
  }
}

class _AllGoodBand extends StatelessWidget {
  const _AllGoodBand({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KmColors.leafTint,
        borderRadius: BorderRadius.circular(KmRadius.row),
        border: Border.all(color: KmColors.leafTint),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 28, color: KmColors.leaf),
          const SizedBox(width: 10),
          Text(label, style: KmText.bodyBold.copyWith(color: KmColors.leaf)),
        ],
      ),
    );
  }
}
