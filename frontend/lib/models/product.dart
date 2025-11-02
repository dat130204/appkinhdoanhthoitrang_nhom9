class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? salePrice;
  final int categoryId;
  final String? categoryName;
  final int stockQuantity;
  final int soldQuantity;
  final String? sku;
  final String? brand;
  final String? material;
  final bool isFeatured;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final List<String>? images;
  final String? primaryImage;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.salePrice,
    required this.categoryId,
    this.categoryName,
    required this.stockQuantity,
    this.soldQuantity = 0,
    this.sku,
    this.brand,
    this.material,
    this.isFeatured = false,
    this.isActive = true,
    this.rating = 0,
    this.reviewCount = 0,
    this.images,
    this.primaryImage,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String>? imagesList;
    if (json['images'] != null) {
      if (json['images'] is List) {
        // Handle both List<String> and List<Map> (with 'url' or 'image_url' field)
        imagesList = (json['images'] as List)
            .map((item) {
              if (item is String) {
                return item;
              } else if (item is Map) {
                // Check for various possible field names
                return item['url'] ?? item['image_url'] ?? item['path'] ?? '';
              }
              return '';
            })
            .where((url) => url.isNotEmpty)
            .cast<String>()
            .toList();
      } else if (json['images'] is String) {
        imagesList = [json['images']];
      }
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: _parseDouble(json['price']),
      salePrice: json['sale_price'] != null
          ? _parseDouble(json['sale_price'])
          : null,
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      stockQuantity: json['stock_quantity'] ?? 0,
      soldQuantity: json['sold_quantity'] ?? 0,
      sku: json['sku'],
      brand: json['brand'],
      material: json['material'],
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      rating: json['rating'] != null ? _parseDouble(json['rating']) : 0,
      reviewCount: json['review_count'] ?? 0,
      images: imagesList,
      primaryImage: json['primary_image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  double get finalPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  bool get inStock => stockQuantity > 0;

  String get displayImage => primaryImage ?? images?.first ?? '';

  // Helper method to parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
