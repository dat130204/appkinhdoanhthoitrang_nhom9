class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final double? salePrice;
  final bool inStock;
  final DateTime? createdAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.salePrice,
    this.inStock = true,
    this.createdAt,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      price: _parseDouble(json['price']),
      salePrice: json['sale_price'] != null
          ? _parseDouble(json['sale_price'])
          : null,
      inStock: json['in_stock'] == 1 || json['in_stock'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  double get finalPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  double? get discountPercent {
    if (!hasDiscount) return null;
    return ((price - salePrice!) / price * 100);
  }
}
