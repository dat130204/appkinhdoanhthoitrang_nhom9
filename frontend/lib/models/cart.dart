class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int? variantId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final int stockQuantity;
  final bool productActive;
  final String? size;
  final String? color;
  final DateTime? createdAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.variantId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.stockQuantity,
    this.productActive = true,
    this.size,
    this.color,
    this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      quantity: json['quantity'],
      price: _parseDouble(json['price']),
      stockQuantity: json['stock_quantity'] ?? 0,
      productActive:
          json['product_active'] == 1 || json['product_active'] == true,
      size: json['size'],
      color: json['color'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  double get subtotal => price * quantity;

  bool get isAvailable => productActive && stockQuantity >= quantity;

  String? get variantInfo {
    if (size != null || color != null) {
      final parts = <String>[];
      if (size != null) parts.add('Size: $size');
      if (color != null) parts.add('Màu: $color');
      return parts.join(', ');
    }
    return null;
  }

  // Helper method to parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class Cart {
  final int id;
  final List<CartItem> items;
  final CartSummary summary;

  Cart({required this.id, required this.items, required this.summary});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] != null
        ? (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
        : <CartItem>[];

    return Cart(
      id: json['cart_id'],
      items: itemsList,
      summary: CartSummary.fromJson(json['summary']),
    );
  }

  bool get isEmpty => items.isEmpty;

  int get totalItems => items.length;
}

class CartSummary {
  final int itemCount;
  final int totalItems;
  final double subtotal;

  CartSummary({
    required this.itemCount,
    required this.totalItems,
    required this.subtotal,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemCount: _parseInt(json['item_count']),
      totalItems: _parseInt(json['total_items']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  // Helper method to parse int from various types
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method to parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
