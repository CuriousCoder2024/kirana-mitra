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
import '../widgets/demand_chart.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/km_button.dart';
import '../widgets/km_chip.dart';
import '../widgets/order_sheet.dart';
import '../widgets/tab_scaffold.dart';

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  int _selected = 0;
  bool _ordering = false;

  Future<void> _order() async {
    final l = AppLocalizations.of(context);
    setState(() => _ordering = true);
    try {
      final order = await ref.read(apiClientProvider).reorder(ref.read(shopPrefsProvider).shopId ?? '');
      if (mounted) await showOrderSheet(context, order);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.isNetwork ? l.networkError : e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.networkError)));
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final forecast = ref.watch(forecastProvider);
    final data = forecast.value;
    final festival = data?.festivals.firstOrNull;
    final festivalDate = festival == null ? null : Fmt.parse(festival.date);
    final subtitle = data == null
        ? null
        : festival == null || festivalDate == null
            ? l.forecastSubtitlePlain
            : l.forecastSubtitle(festival.name, Fmt.dayMonth(festivalDate));

    return TabScaffold(
      appBar: KmAppBar(title: l.forecastTitle, subtitle: subtitle),
      body: AsyncBody<ForecastResponse>(
        value: forecast,
        onRefresh: () => ref.refresh(forecastProvider.future),
        builder: (data) {
          if (data.items.isEmpty) return EmptyHint(text: l.errorLoading, icon: Icons.trending_up_rounded);
          final idx = _selected.clamp(0, data.items.length - 1);
          final item = data.items[idx];
          return ListView(
            padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 24),
            children: [
              SizedBox(
                height: KmSize.chip,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => KmChip(
                    label: data.items[i].name,
                    selected: i == idx,
                    quiet: i != idx,
                    onTap: () => setState(() => _selected = i),
                  ),
                ),
              ),
              const SizedBox(height: KmSpace.cardGap),
              Container(
                padding: const EdgeInsets.all(KmSpace.chartCard),
                decoration: BoxDecoration(
                  color: KmColors.paper,
                  borderRadius: BorderRadius.circular(KmRadius.card),
                  border: Border.all(color: KmColors.sand),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item.name, style: KmText.bodyBold),
                        const SizedBox(width: 8),
                        Text(l.perWeek(item.unit), style: KmText.caption14),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DemandChart(
                      item: item,
                      weeks: data.weeks,
                      festivals: data.festivals,
                      futureLabel: l.forecastFuture,
                    ),
                    const SizedBox(height: 10),
                    ChartLegend(
                      history: l.legendHistory,
                      forecast: l.legendForecast,
                      band: l.legendBand,
                      festivals: data.festivals.map((f) => f.name).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KmSpace.cardGap),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KmColors.haldiTint,
                  borderRadius: BorderRadius.circular(KmRadius.row),
                  border: Border.all(color: KmColors.haldiBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, size: 28, color: KmColors.haldiDeep),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.reorderReason != null && item.reorderReason!.isNotEmpty)
                            Text(item.reorderReason!, style: KmText.bodyBold),
                          const SizedBox(height: 2),
                          Text(
                            l.onHandReorder(Fmt.qty(item.onHand), Fmt.qty(item.reorderQty), item.unit),
                            style: KmText.caption14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomBar: data == null || data.items.isEmpty
          ? null
          : KmButton(
              size: KmButtonSize.tall,
              icon: Icons.shopping_cart_checkout_rounded,
              label: l.orderButtonQty(
                Fmt.qty(data.items[_selected.clamp(0, data.items.length - 1)].reorderQty),
                data.items[_selected.clamp(0, data.items.length - 1)].unit,
              ),
              block: true,
              loading: _ordering,
              onPressed: _ordering ? null : _order,
            ),
    );
  }
}
