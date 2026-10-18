class Shop {
  const Shop({
    required this.shopId,
    required this.shopName,
    required this.ownerName,
    required this.language,
    this.createdAt,
  });

  final String shopId;
  final String shopName;
  final String ownerName;

  /// `hi`, `en` or `hi-Latn`.
  final String language;
  final String? createdAt;

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        shopId: json['shop_id'] as String,
        shopName: json['shop_name'] as String? ?? '',
        ownerName: json['owner_name'] as String? ?? '',
        language: json['language'] as String? ?? 'hi-Latn',
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'shop_id': shopId,
        'shop_name': shopName,
        'owner_name': ownerName,
        'language': language,
        if (createdAt != null) 'created_at': createdAt,
      };
}
