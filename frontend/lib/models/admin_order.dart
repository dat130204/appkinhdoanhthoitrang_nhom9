class AdminOrderList {
  final int id;
  final String orderNumber;
  final AdminOrderUser user;
  final List<AdminOrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String shippingAddress;
  final String? shippingCity;
  final String? shippingDistrict;
  final String? shippingWard;
  final String? notes;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminOrderList({
    required this.id,
    required this.orderNumber,
    required this.user,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.shippingAddress,
    this.shippingCity,
    this.shippingDistrict,
    this.shippingWard,
    this.notes,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminOrderList.fromJson(Map<String, dynamic> json) {
    return AdminOrderList(
      id: json['id'],
      orderNumber: json['orderNumber'],
      user: AdminOrderUser.fromJson(json['user']),
      items: (json['items'] as List<dynamic>)
          .map((e) => AdminOrderItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      shippingAddress: json['shippingAddress'],
      shippingCity: json['shippingCity'],
      shippingDistrict: json['shippingDistrict'],
      shippingWard: json['shippingWard'],
      notes: json['notes'],
      itemCount: json['itemCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String get fullAddress {
    final parts = [
      shippingAddress,
      shippingWard,
      shippingDistrict,
      shippingCity,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }
}

class AdminOrderDetail extends AdminOrderList {
  final List<OrderHistoryItem> history;

  AdminOrderDetail({
    required super.id,
    required super.orderNumber,
    required super.user,
    required super.items,
    required super.subtotal,
    required super.shippingFee,
    required super.discountAmount,
    required super.totalAmount,
    required super.status,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.customerName,
    required super.customerPhone,
    required super.customerEmail,
    required super.shippingAddress,
    super.shippingCity,
    super.shippingDistrict,
    super.shippingWard,
    super.notes,
    required super.itemCount,
    required super.createdAt,
    required super.updatedAt,
    required this.history,
  });

  factory AdminOrderDetail.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetail(
      id: json['id'],
      orderNumber: json['orderNumber'],
      user: AdminOrderUser.fromJson(json['user']),
      items: (json['items'] as List<dynamic>)
          .map((e) => AdminOrderItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      shippingAddress: json['shippingAddress'],
      shippingCity: json['shippingCity'],
      shippingDistrict: json['shippingDistrict'],
      shippingWard: json['shippingWard'],
      notes: json['notes'],
      itemCount: json['itemCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => OrderHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AdminOrderUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final DateTime? memberSince;

  AdminOrderUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.memberSince,
  });

  factory AdminOrderUser.fromJson(Map<String, dynamic> json) {
    return AdminOrderUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      memberSince: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'])
          : null,
    );
  }
}

class AdminOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productSku;
  final String? variantInfo;
  final int quantity;
  final double price;
  final double subtotal;
  final String? productImage;

  AdminOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    this.variantInfo,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.productImage,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productSku: json['productSku'],
      variantInfo: json['variantInfo'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      productImage: json['productImage'],
    );
  }
}

class OrderHistoryItem {
  final int? id;
  final String status;
  final String? notes;
  final int? createdBy;
  final DateTime createdAt;

  OrderHistoryItem({
    this.id,
    required this.status,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id'],
      status: json['status'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}

class OrderPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  OrderPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) {
    return OrderPagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
