class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.fromString(json['type']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      data: json['data'] != null
          ? (json['data'] is String
                ? {} // If data is string, use empty map (or parse JSON)
                : Map<String, dynamic>.from(json['data']))
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

enum NotificationType {
  order('order', 'Đơn hàng', '📦'),
  promotion('promotion', 'Khuyến mãi', '🎁'),
  system('system', 'Hệ thống', '🔔'),
  review('review', 'Đánh giá', '⭐'),
  account('account', 'Tài khoản', '👤');

  final String value;
  final String displayName;
  final String icon;

  const NotificationType(this.value, this.displayName, this.icon);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationListResponse {
  final List<AppNotification> notifications;
  final int unreadCount;
  final NotificationPagination pagination;

  NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    required this.pagination,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      notifications: (json['notifications'] as List)
          .map((item) => AppNotification.fromJson(item))
          .toList(),
      unreadCount: json['unreadCount'] ?? 0,
      pagination: NotificationPagination.fromJson(json['pagination']),
    );
  }
}

class NotificationPagination {
  final int limit;
  final int offset;
  final bool hasMore;

  NotificationPagination({
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      limit: json['limit'] ?? 50,
      offset: json['offset'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class NotificationStatistics {
  final int total;
  final int unread;
  final int read;
  final int orderNotifications;
  final int promotionNotifications;
  final int systemNotifications;
  final int reviewNotifications;
  final int accountNotifications;
  final int uniqueUsers;
  final DateTime date;

  NotificationStatistics({
    required this.total,
    required this.unread,
    required this.read,
    required this.orderNotifications,
    required this.promotionNotifications,
    required this.systemNotifications,
    required this.reviewNotifications,
    required this.accountNotifications,
    required this.uniqueUsers,
    required this.date,
  });

  factory NotificationStatistics.fromJson(Map<String, dynamic> json) {
    return NotificationStatistics(
      total: json['total'] ?? 0,
      unread: json['unread'] ?? 0,
      read: json['read'] ?? 0,
      orderNotifications: json['order_notifications'] ?? 0,
      promotionNotifications: json['promotion_notifications'] ?? 0,
      systemNotifications: json['system_notifications'] ?? 0,
      reviewNotifications: json['review_notifications'] ?? 0,
      accountNotifications: json['account_notifications'] ?? 0,
      uniqueUsers: json['unique_users'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }
}

class SendNotificationRequest {
  final List<int> userIds;
  final String title;
  final String message;
  final NotificationType type;
  final bool sendEmail;
  final Map<String, dynamic>? promotionData;

  SendNotificationRequest({
    required this.userIds,
    required this.title,
    required this.message,
    this.type = NotificationType.system,
    this.sendEmail = false,
    this.promotionData,
  });

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'title': title,
      'message': message,
      'type': type.value,
      'sendEmail': sendEmail,
      if (promotionData != null) 'promotionData': promotionData,
    };
  }
}
