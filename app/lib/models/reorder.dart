class ReorderLine {
  const ReorderLine({required this.name, required this.qty, required this.unit});

  final String name;
  final num qty;
  final String unit;

  factory ReorderLine.fromJson(Map<String, dynamic> json) => ReorderLine(
        name: json['name'] as String? ?? '',
        qty: json['qty'] as num? ?? 0,
        unit: json['unit'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'unit': unit};
}

/// Response of POST /reorder/{shop_id}.
class ReorderResponse {
  const ReorderResponse({
    required this.orderId,
    required this.lines,
    required this.text,
    required this.whatsappUrl,
  });

  final String orderId;
  final List<ReorderLine> lines;
  final String text;
  final String whatsappUrl;

  factory ReorderResponse.fromJson(Map<String, dynamic> json) =>
      ReorderResponse(
        orderId: json['order_id'] as String? ?? '',
        lines: (json['lines'] as List? ?? const [])
            .map((e) => ReorderLine.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        text: json['text'] as String? ?? '',
        whatsappUrl: json['whatsapp_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'lines': lines.map((e) => e.toJson()).toList(),
        'text': text,
        'whatsapp_url': whatsappUrl,
      };
}
