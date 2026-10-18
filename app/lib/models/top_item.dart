/// One row of GET /top-items/{shop_id}.
class TopItem {
  const TopItem({
    required this.itemId,
    required this.name,
    required this.unit,
    required this.rank,
    required this.forecastUnits,
    required this.historyUnits,
    required this.trendPct,
    required this.onHand,
    required this.coverDays,
    required this.demandRatio,
    required this.reorderQty,
    required this.autoRestockEligible,
    this.reorderReason,
  });

  final String itemId;
  final String name;
  final String unit;
  final int rank;
  final num forecastUnits;
  final num historyUnits;
  final num trendPct;
  final num onHand;
  final num coverDays;
  /// 0 when the backend omits it.
  final num demandRatio;
  final num reorderQty;
  final String? reorderReason;
  final bool autoRestockEligible;

  factory TopItem.fromJson(Map<String, dynamic> j) => TopItem(
        itemId: j['item_id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        unit: j['unit'] as String? ?? 'piece',
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        forecastUnits: j['forecast_units'] as num? ?? 0,
        historyUnits: j['history_units'] as num? ?? 0,
        trendPct: j['trend_pct'] as num? ?? 0,
        onHand: j['on_hand'] as num? ?? 0,
        coverDays: j['cover_days'] as num? ?? 0,
        demandRatio: j['demand_ratio'] as num? ?? 0,
        reorderQty: j['reorder_qty'] as num? ?? 0,
        reorderReason: j['reorder_reason'] as String?,
        autoRestockEligible: j['auto_restock_eligible'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'name': name,
        'unit': unit,
        'rank': rank,
        'forecast_units': forecastUnits,
        'history_units': historyUnits,
        'trend_pct': trendPct,
        'on_hand': onHand,
        'cover_days': coverDays,
        'demand_ratio': demandRatio,
        'reorder_qty': reorderQty,
        'reorder_reason': reorderReason,
        'auto_restock_eligible': autoRestockEligible,
      };
}

class TopItemsResponse {
  const TopItemsResponse({required this.generatedAt, required this.items});

  final String generatedAt;
  final List<TopItem> items;

  factory TopItemsResponse.fromJson(Map<String, dynamic> j) => TopItemsResponse(
        generatedAt: j['generated_at'] as String? ?? '',
        items: (j['items'] as List? ?? const [])
            .map((e) => TopItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
