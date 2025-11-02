class Review {
  final int id;
  final int userId;
  final int productId;
  final int rating;
  final String comment;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info
  final String userName;
  final String? userAvatar;

  // Product info (optional)
  final String? productName;
  final String? productImage;

  // Current user's helpful status
  final bool? isHelpfulByCurrentUser;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.helpfulCount,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    this.userAvatar,
    this.productName,
    this.productImage,
    this.isHelpfulByCurrentUser,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      helpfulCount: json['helpful_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      userName: json['user_name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'],
      productName: json['product_name'],
      productImage: json['product_image'],
      isHelpfulByCurrentUser: json['is_helpful_by_current_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
      'product_name': productName,
      'product_image': productImage,
      'is_helpful_by_current_user': isHelpfulByCurrentUser,
    };
  }

  Review copyWith({
    int? id,
    int? userId,
    int? productId,
    int? rating,
    String? comment,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    String? productName,
    String? productImage,
    bool? isHelpfulByCurrentUser,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      isHelpfulByCurrentUser:
          isHelpfulByCurrentUser ?? this.isHelpfulByCurrentUser,
    );
  }
}

class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 150, 4: 80, 3: 30, 2: 10, 1: 5}

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};

    if (json['rating_distribution'] != null) {
      if (json['rating_distribution'] is Map) {
        json['rating_distribution'].forEach((key, value) {
          distribution[int.parse(key.toString())] = value ?? 0;
        });
      } else if (json['rating_distribution'] is List) {
        for (var item in json['rating_distribution']) {
          distribution[item['rating'] ?? 0] = item['count'] ?? 0;
        }
      }
    }

    return ReviewStatistics(
      averageRating: _parseDouble(json['average_rating']),
      totalReviews: json['total_reviews'] ?? 0,
      ratingDistribution: distribution,
    );
  }

  int getRatingCount(int star) {
    return ratingDistribution[star] ?? 0;
  }

  double getRatingPercentage(int star) {
    if (totalReviews == 0) return 0.0;
    return (getRatingCount(star) / totalReviews) * 100;
  }
}

class ReviewsResponse {
  final List<Review> reviews;
  final ReviewStatistics statistics;
  final int currentPage;
  final int totalPages;
  final int totalReviews;

  ReviewsResponse({
    required this.reviews,
    required this.statistics,
    required this.currentPage,
    required this.totalPages,
    required this.totalReviews,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews:
          (json['reviews'] as List?)
              ?.map((item) => Review.fromJson(item))
              .toList() ??
          [],
      statistics: json['statistics'] != null
          ? ReviewStatistics.fromJson(json['statistics'])
          : ReviewStatistics(
              averageRating: 0,
              totalReviews: 0,
              ratingDistribution: {},
            ),
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
