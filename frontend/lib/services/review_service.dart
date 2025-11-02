import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../models/product_review.dart';
import '../config/app_config.dart';

class ReviewService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    print(
      '🔑 ReviewService - Getting token: ${token != null ? "Found (${token.length} chars)" : "Not found"}',
    );
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get reviews for a product (using old Review model for backwards compatibility)
  Future<ReviewsResponse> getProductReviews({
    required int productId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/reviews/products/$productId').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'sort_by': sortBy,
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReviewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error loading reviews: $e');
    }
  }

  // Get reviews for product details page (new endpoint)
  Future<Map<String, dynamic>> getProductReviewsWithStats(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews = (data['reviews'] as List)
            .map((json) => ProductReview.fromJson(json))
            .toList();
        final stats = ProductReviewStats.fromJson(data['statistics']);

        return {'reviews': reviews, 'statistics': stats};
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Check if can review
  Future<Map<String, dynamic>> canReview(int productId) async {
    try {
      final headers = await _getHeaders();
      print('🔐 Can Review - Headers: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/reviews/products/$productId/can-review'),
        headers: headers,
      );

      print('🔐 Can Review - Status Code: ${response.statusCode}');
      print('🔐 Can Review - Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Cannot check review permission');
      }
    } catch (e) {
      print('❌ Can Review Error: $e');
      throw Exception('Error: $e');
    }
  }

  // Create review (new endpoint with pending status)
  Future<ProductReview> createProductReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Please login to submit a review');
      }

      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/products/$productId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ProductReview.fromJson(data['review']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  // Create review (old endpoint for backwards compatibility)
  Future<Review> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/products/$productId'),
        headers: headers,
        body: json.encode({'rating': rating, 'comment': comment}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Review.fromJson(data['review']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to create review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update review
  Future<Review> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: headers,
        body: json.encode({'rating': rating, 'comment': comment}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Review.fromJson(data['review']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to update review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete review
  Future<void> deleteReview(int reviewId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Toggle helpful
  Future<Map<String, dynamic>> toggleHelpful(int reviewId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/$reviewId/helpful'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to toggle helpful');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
