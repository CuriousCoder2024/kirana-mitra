import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../state/shop_prefs.dart';
import '../theme.dart';
import '../widgets/async_body.dart';

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  int _selected = 0;
  bool _ordering = false;

  Future<void> _reorder() async {
    final l = AppLocalizations.of(context);
    setState(() => _ordering = true);
    try {
      final shopId = ref.read(shopPrefsProvider).shopId ?? '';
      final order = await ref.read(apiClientProvider).reorder(shopId);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: KmColors.cream,
        builder: (_) => _OrderSheet(order: order, l: l),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.isNetwork ? l.networkError : e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.networkError)));
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final forecast = ref.watch(forecastProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.forecastTitle)),
      body: AsyncBody<ForecastResponse>(
        value: forecast,
        onRefresh: () => ref.refresh(forecastProvider.future),
        builder: (data) {
          if (data.items.isEmpty) {
            return EmptyHint(text: l.errorLoading, icon: Icons.trending_up_rounded);
          }
          final idx = _selected.clamp(0, data.items.length - 1);
          final item = data.items[idx];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ChoiceChip(
                    label: Text(data.items[i].name),
                    selected: i == idx,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selected = i),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text('${item.name} · ${item.unit}/week', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240,
                        child: ForecastChart(item: item, weeks: data.weeks, festivals: data.festivals),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _Legend(color: KmColors.brownSoft, label: l.legendHistory),
                          _Legend(color: KmColors.saffron, label: l.legendForecast),
                          _Legend(color: KmColors.saffron.withValues(alpha: 0.22), label: l.legendBand, wide: true),
                          for (final f in data.festivals)
                            _Legend(color: KmColors.terracotta, label: f.name, dashed: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.onHand(_n(item.onHand), item.unit), style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 4),
                            Text(
                              l.suggestedReorder(_n(item.reorderQty), item.unit),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: KmColors.terracotta),
                            ),
                            if (item.reorderReason != null && item.reorderReason!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(item.reorderReason!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.celebration_outlined, color: KmColors.saffron, size: 36),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _ordering ? null : _reorder,
                icon: _ordering
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.shopping_cart_checkout_rounded),
                label: Text(_ordering ? l.reorderPreparing : l.reorderButton),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _n(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
}

/// History (grey) + forecast (saffron) with a shaded lower/upper band and
/// dashed vertical festival markers.
class ForecastChart extends StatelessWidget {
  const ForecastChart({
    super.key,
    required this.item,
    required this.weeks,
    required this.festivals,
  });

  final ForecastItem item;
  final List<String> weeks;
  final List<Festival> festivals;

  @override
  Widget build(BuildContext context) {
    final h = item.historyWeekly;
    final f = item.forecastWeekly;
    final lo = item.lower;
    final up = item.upper;
    final hn = h.length;
    final fn = f.length;
    final lastHist = hn == 0 ? (f.isEmpty ? 0.0 : f.first.toDouble()) : h.last.toDouble();

    final histSpots = [for (var i = 0; i < hn; i++) FlSpot(i.toDouble(), h[i].toDouble())];
    final fcSpots = [
      if (hn > 0) FlSpot((hn - 1).toDouble(), lastHist),
      for (var i = 0; i < fn; i++) FlSpot((hn + i).toDouble(), f[i].toDouble()),
    ];
    final loSpots = [
      if (hn > 0) FlSpot((hn - 1).toDouble(), lastHist),
      for (var i = 0; i < fn && i < lo.length; i++) FlSpot((hn + i).toDouble(), lo[i].toDouble()),
    ];
    final upSpots = [
      if (hn > 0) FlSpot((hn - 1).toDouble(), lastHist),
      for (var i = 0; i < fn && i < up.length; i++) FlSpot((hn + i).toDouble(), up[i].toDouble()),
    ];

    final all = [...h, ...f, ...lo, ...up].map((e) => e.toDouble()).toList();
    final maxY = all.isEmpty ? 10.0 : (all.reduce((a, b) => a > b ? a : b) * 1.15).ceilToDouble();
    final maxX = (hn + fn - 1).toDouble().clamp(1.0, double.infinity);

    DateTime? firstWeek;
    try {
      if (weeks.isNotEmpty) firstWeek = DateTime.parse(weeks.first);
    } catch (_) {}

    String labelFor(int x) {
      if (firstWeek == null) return x < hn ? 'W${x - hn}' : 'W+${x - hn + 1}';
      final d = firstWeek.add(Duration(days: 7 * (x - hn)));
      return DateFormat('d MMM').format(d);
    }

    final festivalLines = <VerticalLine>[];
    if (firstWeek != null) {
      for (final fest in festivals) {
        try {
          final d = DateTime.parse(fest.date);
          final x = hn + d.difference(firstWeek).inDays / 7;
          if (x < 0 || x > maxX) continue;
          festivalLines.add(
            VerticalLine(
              x: x,
              color: KmColors.terracotta,
              strokeWidth: 2,
              dashArray: [6, 4],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KmColors.terracotta),
                labelResolver: (_) => fest.name,
              ),
            ),
          );
        } catch (_) {}
      }
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.none(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(color: KmColors.creamDark, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxY / 4,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 12, color: KmColors.brownSoft),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final x = v.round();
                if ((v - x).abs() > 0.01 || x < 0 || x > maxX) return const SizedBox.shrink();
                if ((hn + fn) > 6 && x % 2 == 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labelFor(x),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: x >= hn ? FontWeight.w700 : FontWeight.w400,
                      color: x >= hn ? KmColors.saffron : KmColors.brownSoft,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(verticalLines: festivalLines),
        betweenBarsData: [
          BetweenBarsData(fromIndex: 1, toIndex: 2, color: KmColors.saffron.withValues(alpha: 0.18)),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => KmColors.brown,
            getTooltipItems: (spots) => spots
                .map((s) => s.barIndex == 1 || s.barIndex == 2
                    ? null
                    : LineTooltipItem(
                        '${labelFor(s.x.round())}: ${s.y.round()} ${item.unit}',
                        const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: histSpots,
            color: KmColors.brownSoft,
            barWidth: 3,
            isCurved: true,
            curveSmoothness: 0.25,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(spots: loSpots, color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: upSpots, color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(
            spots: fcSpots,
            color: KmColors.saffron,
            barWidth: 3.5,
            isCurved: true,
            curveSmoothness: 0.25,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.dashed = false, this.wide = false});

  final Color color;
  final String label;
  final bool dashed;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 3 : 22,
          height: wide ? 14 : (dashed ? 16 : 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.order, required this.l});

  final ReorderResponse order;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: KmColors.terracotta),
                const SizedBox(width: 8),
                Text(l.orderReady, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KmColors.creamDark),
              ),
              child: SingleChildScrollView(
                child: SelectableText(order.text, style: const TextStyle(fontSize: 17, height: 1.4, color: KmColors.brown)),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              onPressed: order.whatsappUrl.isEmpty
                  ? null
                  : () => launchUrl(Uri.parse(order.whatsappUrl), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.send_rounded),
              label: Text(l.shareWhatsapp),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: order.text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l.copy),
            ),
          ],
        ),
      ),
    );
  }
}
