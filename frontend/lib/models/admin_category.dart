class CategoryStats {
  final int categoryId;
  final String name;
  final String? image;
  final int productCount;
  final int totalStock;
  final double totalRevenue;
  final int orderCount;
  final double averageRevenue;

  CategoryStats({
    required this.categoryId,
    required this.name,
    this.image,
    required this.productCount,
    required this.totalStock,
    required this.totalRevenue,
    required this.orderCount,
    required this.averageRevenue,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      productCount: json['productCount'] ?? 0,
      totalStock: json['totalStock'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      orderCount: json['orderCount'] ?? 0,
      averageRevenue: (json['averageRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'image': image,
      'productCount': productCount,
      'totalStock': totalStock,
      'totalRevenue': totalRevenue,
      'orderCount': orderCount,
      'averageRevenue': averageRevenue,
    };
  }

  bool get hasProducts => productCount > 0;
  bool get hasRevenue => totalRevenue > 0;
  bool get isPopular => orderCount > 10;

  String get performanceLabel {
    if (totalRevenue > 10000000) return 'Xuất sắc';
    if (totalRevenue > 5000000) return 'Tốt';
    if (totalRevenue > 1000000) return 'Trung bình';
    return 'Mới';
  }
}

class CategoryFormData {
  final int? id;
  final String name;
  final String? description;
  final String? image;
  final int? parentId;
  final int displayOrder;

  CategoryFormData({
    this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    this.displayOrder = 0,
  });

  factory CategoryFormData.fromJson(Map<String, dynamic> json) {
    return CategoryFormData(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      parentId: json['parent_id'],
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'name': name, 'display_order': displayOrder};

    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }

    if (parentId != null) {
      data['parent_id'] = parentId;
    }

    // Image will be handled separately via multipart upload

    return data;
  }

  CategoryFormData copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? parentId,
    int? displayOrder,
  }) {
    return CategoryFormData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      parentId: parentId ?? this.parentId,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  bool get isValid => name.isNotEmpty;
}

class CategoryListItem {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? parentId;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CategoryListItem({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    required this.displayOrder,
    required this.createdAt,
    this.updatedAt,
  });

  factory CategoryListItem.fromJson(Map<String, dynamic> json) {
    return CategoryListItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      parentId: json['parent_id'],
      displayOrder: json['display_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'parent_id': parentId,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get hasImage => image != null && image!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get isSubCategory => parentId != null;
}
