class AdminReview {
  final int id;
  final int userId;
  final int productId;
  final int rating;
  final String? comment;
  final String status;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final String productName;
  final double productPrice;
  final String? productImage;

  AdminReview({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.status,
    required this.helpfulCount,
    required this.createdAt,
    this.updatedAt,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.productName,
    required this.productPrice,
    this.productImage,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    return AdminReview(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      comment: json['comment'],
      status: json['status'],
      helpfulCount: json['helpful_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userName: json['user_name'] ?? 'Unknown',
      userEmail: json['user_email'] ?? '',
      userAvatar: json['user_avatar'],
      productName: json['product_name'] ?? 'Unknown Product',
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0.0,
      productImage: json['product_image'],
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class ReviewStatistics {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final double avgRating;

  ReviewStatistics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.avgRating,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    return ReviewStatistics(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReviewPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  ReviewPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory ReviewPagination.fromJson(Map<String, dynamic> json) {
    return ReviewPagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      itemsPerPage: json['itemsPerPage'],
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}
