class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? parentId;
  final String? parentName;
  final bool isActive;
  final int displayOrder;
  final int productCount;
  final List<Category>? children;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    this.parentName,
    this.isActive = true,
    this.displayOrder = 0,
    this.productCount = 0,
    this.children,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<Category>? childrenList;
    if (json['children'] != null && json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((child) => Category.fromJson(child))
          .toList();
    }

    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      parentId: json['parent_id'],
      parentName: json['parent_name'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      displayOrder: json['display_order'] ?? 0,
      productCount: json['product_count'] ?? 0,
      children: childrenList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  bool get hasChildren => children != null && children!.isNotEmpty;
}
