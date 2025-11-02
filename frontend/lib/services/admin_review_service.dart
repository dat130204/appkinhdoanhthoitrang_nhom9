import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_review.dart';
import '../config/app_config.dart';

class AdminReviewService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final uri = Uri.parse(
        '$baseUrl/admin/reviews',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews = (data['reviews'] as List)
            .map((json) => AdminReview.fromJson(json))
            .toList();
        final pagination = ReviewPagination.fromJson(data['pagination']);

        return {'reviews': reviews, 'pagination': pagination};
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<ReviewStatistics> getReviewStats() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/reviews/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns data, not stats
        return ReviewStatistics.fromJson(data['data'] ?? {});
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

  Future<void> approveReview(int reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/admin/reviews/$reviewId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to approve review');
      }
    } catch (e) {
      throw Exception('Failed to approve review: $e');
    }
  }

  Future<void> rejectReview(int reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/admin/reviews/$reviewId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to reject review');
      }
    } catch (e) {
      throw Exception('Failed to reject review: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
