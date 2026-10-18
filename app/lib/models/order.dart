class OrderLine {
  const OrderLine({
    required this.name,
    required this.qty,
    required this.unit,
    this.rank,
    this.coverDays,
    this.demandRatio,
  });

  final String name;
  final num qty;
  final String unit;
  final int? rank;
  final num? coverDays;
  final num? demandRatio;

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        name: j['name'] as String? ?? '',
        qty: j['qty'] as num? ?? 0,
        unit: j['unit'] as String? ?? '',
        rank: (j['rank'] as num?)?.toInt(),
        coverDays: j['cover_days'] as num?,
        demandRatio: j['demand_ratio'] as num?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'unit': unit,
        'rank': rank,
        'cover_days': coverDays,
        'demand_ratio': demandRatio,
      };
}

/// Order from GET /orders/{shop_id}.
class Order {
  const Order({
    required this.orderId,
    required this.shopId,
    required this.createdAt,
    required this.status,
    required this.source,
    required this.lines,
    required this.text,
    required this.whatsappUrl,
    this.messageId,
  });

  final String orderId;
  final String shopId;
  final String createdAt;

  /// placed | cancelled
  final String status;

  /// auto | manual
  final String source;

  /// For POST /undo on an auto order.
  final String? messageId;
  final List<OrderLine> lines;
  final String text;
  final String whatsappUrl;

  bool get isAuto => source == 'auto';
  bool get isPlaced => status == 'placed';

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        orderId: j['order_id'] as String? ?? '',
        shopId: j['shop_id'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
        status: j['status'] as String? ?? 'placed',
        source: j['source'] as String? ?? 'manual',
        messageId: j['message_id'] as String?,
        lines: (j['lines'] as List? ?? const [])
            .map((e) => OrderLine.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        text: j['text'] as String? ?? '',
        whatsappUrl: j['whatsapp_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'shop_id': shopId,
        'created_at': createdAt,
        'status': status,
        'source': source,
        'message_id': messageId,
        'lines': lines.map((e) => e.toJson()).toList(),
        'text': text,
        'whatsapp_url': whatsappUrl,
      };

  Order copyWith({String? status}) => Order(
        orderId: orderId,
        shopId: shopId,
        createdAt: createdAt,
        status: status ?? this.status,
        source: source,
        messageId: messageId,
        lines: lines,
        text: text,
        whatsappUrl: whatsappUrl,
      );
}

class OrdersResponse {
  const OrdersResponse({required this.orders});

  final List<Order> orders;

  factory OrdersResponse.fromJson(Map<String, dynamic> j) => OrdersResponse(
        orders: (j['orders'] as List? ?? const [])
            .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
