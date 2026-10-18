import 'stock.dart';

/// Response of GET /summary/{shop_id}?date=YYYY-MM-DD.
class DaySummary {
  const DaySummary({
    required this.date,
    required this.salesTotal,
    required this.entries,
    required this.lowStock,
    required this.udhaarGiven,
    required this.udhaarReceived,
    required this.totalOutstanding,
    required this.replyText,
  });

  final String date;
  final num salesTotal;
  final int entries;
  final List<StockItem> lowStock;
  final num udhaarGiven;
  final num udhaarReceived;
  final num totalOutstanding;
  final String replyText;

  factory DaySummary.fromJson(Map<String, dynamic> json) => DaySummary(
        date: json['date'] as String? ?? '',
        salesTotal: json['sales_total'] as num? ?? 0,
        entries: (json['entries'] as num?)?.toInt() ?? 0,
        lowStock: (json['low_stock'] as List? ?? const [])
            .map((e) => StockItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        udhaarGiven: json['udhaar_given'] as num? ?? 0,
        udhaarReceived: json['udhaar_received'] as num? ?? 0,
        totalOutstanding: json['total_outstanding'] as num? ?? 0,
        replyText: json['reply_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'sales_total': salesTotal,
        'entries': entries,
        'low_stock': lowStock.map((e) => e.toJson()).toList(),
        'udhaar_given': udhaarGiven,
        'udhaar_received': udhaarReceived,
        'total_outstanding': totalOutstanding,
        'reply_text': replyText,
      };
}
