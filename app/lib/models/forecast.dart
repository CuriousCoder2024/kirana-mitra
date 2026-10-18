class Festival {
  const Festival({required this.name, required this.date});

  final String name;

  /// YYYY-MM-DD
  final String date;

  factory Festival.fromJson(Map<String, dynamic> json) => Festival(
        name: json['name'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'date': date};
}

class ForecastItem {
  const ForecastItem({
    required this.itemId,
    required this.name,
    required this.unit,
    required this.historyWeekly,
    required this.forecastWeekly,
    required this.lower,
    required this.upper,
    required this.onHand,
    required this.reorderQty,
    this.reorderReason,
  });

  final String itemId;
  final String name;
  final String unit;
  final List<num> historyWeekly;
  final List<num> forecastWeekly;
  final List<num> lower;
  final List<num> upper;
  final num onHand;
  final num reorderQty;
  final String? reorderReason;

  static List<num> _nums(dynamic v) =>
      (v as List? ?? const []).map((e) => (e as num?) ?? 0).toList();

  factory ForecastItem.fromJson(Map<String, dynamic> json) => ForecastItem(
        itemId: json['item_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        unit: json['unit'] as String? ?? 'piece',
        historyWeekly: _nums(json['history_weekly']),
        forecastWeekly: _nums(json['forecast_weekly']),
        lower: _nums(json['lower']),
        upper: _nums(json['upper']),
        onHand: json['on_hand'] as num? ?? 0,
        reorderQty: json['reorder_qty'] as num? ?? 0,
        reorderReason: json['reorder_reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'name': name,
        'unit': unit,
        'history_weekly': historyWeekly,
        'forecast_weekly': forecastWeekly,
        'lower': lower,
        'upper': upper,
        'on_hand': onHand,
        'reorder_qty': reorderQty,
        'reorder_reason': reorderReason,
      };
}

class ForecastResponse {
  const ForecastResponse({
    required this.generatedAt,
    required this.weeks,
    required this.festivals,
    required this.items,
  });

  final String generatedAt;

  /// Monday dates of the forecast weeks, YYYY-MM-DD.
  final List<String> weeks;
  final List<Festival> festivals;
  final List<ForecastItem> items;

  factory ForecastResponse.fromJson(Map<String, dynamic> json) =>
      ForecastResponse(
        generatedAt: json['generated_at'] as String? ?? '',
        weeks: (json['weeks'] as List? ?? const []).cast<String>(),
        festivals: (json['festivals'] as List? ?? const [])
            .map((e) => Festival.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        items: (json['items'] as List? ?? const [])
            .map((e) =>
                ForecastItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'generated_at': generatedAt,
        'weeks': weeks,
        'festivals': festivals.map((e) => e.toJson()).toList(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}
