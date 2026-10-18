class StockItem {
  const StockItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.lowStock,
    this.packSize,
    this.updatedAt,
  });

  final String itemId;
  final String name;
  final String? packSize;
  final num quantity;
  final String unit;
  final num reorderLevel;
  final bool lowStock;
  final String? updatedAt;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        itemId: json['item_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        packSize: json['pack_size'] as String?,
        quantity: json['quantity'] as num? ?? 0,
        unit: json['unit'] as String? ?? 'piece',
        reorderLevel: json['reorder_level'] as num? ?? 0,
        lowStock: json['low_stock'] as bool? ?? false,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'name': name,
        'pack_size': packSize,
        'quantity': quantity,
        'unit': unit,
        'reorder_level': reorderLevel,
        'low_stock': lowStock,
        'updated_at': updatedAt,
      };

  StockItem copyWith({num? quantity, bool? lowStock, String? updatedAt}) =>
      StockItem(
        itemId: itemId,
        name: name,
        packSize: packSize,
        quantity: quantity ?? this.quantity,
        unit: unit,
        reorderLevel: reorderLevel,
        lowStock: lowStock ?? this.lowStock,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class StockResponse {
  const StockResponse({required this.items});

  final List<StockItem> items;

  factory StockResponse.fromJson(Map<String, dynamic> json) => StockResponse(
        items: (json['items'] as List? ?? const [])
            .map((e) => StockItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() =>
      {'items': items.map((e) => e.toJson()).toList()};
}
