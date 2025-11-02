class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalUsers;
  final OrdersByStatus ordersByStatus;
  final List<RecentOrder> recentOrders;
  final List<LowStockProduct> lowStockProducts;

  DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalUsers,
    required this.ordersByStatus,
    required this.recentOrders,
    required this.lowStockProducts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      ordersByStatus: OrdersByStatus.fromJson(json['ordersByStatus'] ?? {}),
      recentOrders:
          (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => RecentOrder.fromJson(e))
              .toList() ??
          [],
      lowStockProducts:
          (json['lowStockProducts'] as List<dynamic>?)
              ?.map((e) => LowStockProduct.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OrdersByStatus {
  final int pending;
  final int processing;
  final int shipped;
  final int delivered;
  final int cancelled;

  OrdersByStatus({
    required this.pending,
    required this.processing,
    required this.shipped,
    required this.delivered,
    required this.cancelled,
  });

  factory OrdersByStatus.fromJson(Map<String, dynamic> json) {
    return OrdersByStatus(
      pending: json['pending'] ?? 0,
      processing: json['processing'] ?? 0,
      shipped: json['shipped'] ?? 0,
      delivered: json['delivered'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }

  int get total => pending + processing + shipped + delivered + cancelled;
}

class RecentOrder {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final int itemCount;
  final DateTime createdAt;

  RecentOrder({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.customerName,
    required this.customerPhone,
    required this.itemCount,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      itemCount: json['itemCount'],
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

class LowStockProduct {
  final int id;
  final String name;
  final String sku;
  final int stockQuantity;
  final double price;
  final String? categoryName;
  final String? imageUrl;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.stockQuantity,
    required this.price,
    this.categoryName,
    this.imageUrl,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      stockQuantity: json['stockQuantity'],
      price: (json['price'] ?? 0).toDouble(),
      categoryName: json['categoryName'],
      imageUrl: json['imageUrl'],
    );
  }
}

class RevenueData {
  final List<String> labels;
  final List<double> data;
  final double total;
  final String period;

  RevenueData({
    required this.labels,
    required this.data,
    required this.total,
    required this.period,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      labels: (json['labels'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      data: (json['data'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
      period: json['period'] ?? 'week',
    );
  }

  String get periodText {
    switch (period) {
      case 'week':
        return '7 ngày qua';
      case 'month':
        return '30 ngày qua';
      case 'year':
        return '12 tháng qua';
      default:
        return period;
    }
  }
}

class TopProduct {
  final int productId;
  final String name;
  final String sku;
  final double price;
  final double? salePrice;
  final String? categoryName;
  final int totalSold;
  final double revenue;
  final String? imageUrl;

  TopProduct({
    required this.productId,
    required this.name,
    required this.sku,
    required this.price,
    this.salePrice,
    this.categoryName,
    required this.totalSold,
    required this.revenue,
    this.imageUrl,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'],
      name: json['name'],
      sku: json['sku'],
      price: (json['price'] ?? 0).toDouble(),
      salePrice: json['salePrice'] != null
          ? (json['salePrice'] as num).toDouble()
          : null,
      categoryName: json['categoryName'],
      totalSold: json['totalSold'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  double get effectivePrice => salePrice ?? price;
}
