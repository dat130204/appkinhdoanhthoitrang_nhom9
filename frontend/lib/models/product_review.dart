class ProductReview {
  final int id;
  final int userId;
  final int productId;
  final int rating;
  final String? comment;
  final String status;
  final int helpfulCount;
  final DateTime createdAt;
  final String userName;
  final String userEmail;
  final String? userAvatar;

  ProductReview({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.status,
    required this.helpfulCount,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      comment: json['comment'],
      status: json['status'] ?? 'approved',
      helpfulCount: json['helpful_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'] ?? 'Anonymous',
      userEmail: json['user_email'] ?? '',
      userAvatar: json['user_avatar'],
    );
  }
}

class ProductReviewStats {
  final int totalReviews;
  final double averageRating;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  ProductReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory ProductReviewStats.fromJson(Map<String, dynamic> json) {
    return ProductReviewStats(
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      fiveStar: json['five_star'] ?? 0,
      fourStar: json['four_star'] ?? 0,
      threeStar: json['three_star'] ?? 0,
      twoStar: json['two_star'] ?? 0,
      oneStar: json['one_star'] ?? 0,
    );
  }

  int getStarCount(int star) {
    switch (star) {
      case 5:
        return fiveStar;
      case 4:
        return fourStar;
      case 3:
        return threeStar;
      case 2:
        return twoStar;
      case 1:
        return oneStar;
      default:
        return 0;
    }
  }

  double getStarPercentage(int star) {
    if (totalReviews == 0) return 0.0;
    return (getStarCount(star) / totalReviews) * 100;
  }
}
