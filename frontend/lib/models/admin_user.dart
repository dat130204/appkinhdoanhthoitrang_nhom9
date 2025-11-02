class AdminUserList {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String? avatar;
  final DateTime createdAt;
  final int ordersCount;
  final double totalSpent;
  final DateTime? lastOrderDate;

  AdminUserList({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.avatar,
    required this.createdAt,
    required this.ordersCount,
    required this.totalSpent,
    this.lastOrderDate,
  });

  factory AdminUserList.fromJson(Map<String, dynamic> json) {
    return AdminUserList(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      ordersCount: json['ordersCount'],
      totalSpent: (json['totalSpent'] as num).toDouble(),
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
    );
  }

  String get roleText {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'user':
        return 'Người dùng';
      default:
        return role;
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'blocked':
        return 'Bị chặn';
      default:
        return status;
    }
  }

  bool get isActive => status == 'active';
  bool get isAdmin => role == 'admin';
}

class AdminUserDetail {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String? avatar;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdminUserDetail({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.avatar,
    this.address,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    return AdminUserDetail(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      avatar: json['avatar'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  String get fullAddress {
    return address ?? '';
  }

  String get roleText {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'user':
        return 'Người dùng';
      default:
        return role;
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'blocked':
        return 'Bị chặn';
      default:
        return status;
    }
  }

  bool get isActive => status == 'active';
  bool get isAdmin => role == 'admin';
}

class UserStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalSpent;
  final double averageOrderValue;
  final DateTime? lastOrderDate;

  UserStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    this.lastOrderDate,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalOrders: json['totalOrders'],
      pendingOrders: json['pendingOrders'],
      processingOrders: json['processingOrders'],
      shippedOrders: json['shippedOrders'],
      deliveredOrders: json['deliveredOrders'],
      cancelledOrders: json['cancelledOrders'],
      totalSpent: (json['totalSpent'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
    );
  }

  int get completedOrders => deliveredOrders;
  int get activeOrders => pendingOrders + processingOrders + shippedOrders;
  double get successRate =>
      totalOrders > 0 ? (deliveredOrders / totalOrders) * 100 : 0;
}

class UserOrderHistory {
  final int id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final int itemsCount;

  UserOrderHistory({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.itemsCount,
  });

  factory UserOrderHistory.fromJson(Map<String, dynamic> json) {
    return UserOrderHistory(
      id: json['id'],
      orderNumber: json['orderNumber'],
      status: json['status'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      itemsCount: json['itemsCount'],
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

class MonthlySpending {
  final String month;
  final double total;
  final int ordersCount;

  MonthlySpending({
    required this.month,
    required this.total,
    required this.ordersCount,
  });

  factory MonthlySpending.fromJson(Map<String, dynamic> json) {
    return MonthlySpending(
      month: json['month'],
      total: (json['total'] as num).toDouble(),
      ordersCount: json['ordersCount'],
    );
  }

  String get monthName {
    try {
      final parts = month.split('-');
      if (parts.length == 2) {
        final monthNum = int.parse(parts[1]);
        const months = [
          'Tháng 1',
          'Tháng 2',
          'Tháng 3',
          'Tháng 4',
          'Tháng 5',
          'Tháng 6',
          'Tháng 7',
          'Tháng 8',
          'Tháng 9',
          'Tháng 10',
          'Tháng 11',
          'Tháng 12',
        ];
        return months[monthNum - 1];
      }
    } catch (_) {}
    return month;
  }
}

class FavoriteCategory {
  final int id;
  final String name;
  final int ordersCount;
  final double totalSpent;

  FavoriteCategory({
    required this.id,
    required this.name,
    required this.ordersCount,
    required this.totalSpent,
  });

  factory FavoriteCategory.fromJson(Map<String, dynamic> json) {
    return FavoriteCategory(
      id: json['id'],
      name: json['name'],
      ordersCount: json['ordersCount'],
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }
}

class UserPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  UserPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    return UserPagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      itemsPerPage: json['itemsPerPage'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }
}

class AdminUserDetailResponse {
  final AdminUserDetail user;
  final UserStatistics statistics;
  final List<UserOrderHistory> orders;
  final List<MonthlySpending> monthlySpending;
  final List<FavoriteCategory> favoriteCategories;

  AdminUserDetailResponse({
    required this.user,
    required this.statistics,
    required this.orders,
    required this.monthlySpending,
    required this.favoriteCategories,
  });

  factory AdminUserDetailResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserDetailResponse(
      user: AdminUserDetail.fromJson(json['user']),
      statistics: UserStatistics.fromJson(json['statistics']),
      orders: (json['orders'] as List)
          .map((item) => UserOrderHistory.fromJson(item))
          .toList(),
      monthlySpending: (json['monthlySpending'] as List)
          .map((item) => MonthlySpending.fromJson(item))
          .toList(),
      favoriteCategories: (json['favoriteCategories'] as List)
          .map((item) => FavoriteCategory.fromJson(item))
          .toList(),
    );
  }
}
