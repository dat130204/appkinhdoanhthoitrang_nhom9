import 'api_service.dart';
import '../models/admin_dashboard.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // GET /api/admin/dashboard/stats
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard/stats');
      return DashboardStats.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  // GET /api/admin/dashboard/revenue?period=week|month|year
  Future<RevenueData> getRevenue({String period = 'week'}) async {
    if (!['week', 'month', 'year'].contains(period)) {
      throw Exception('Invalid period. Must be: week, month, or year');
    }

    try {
      final response = await _apiService.get(
        '/admin/dashboard/revenue',
        queryParameters: {'period': period},
      );
      return RevenueData.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load revenue data: $e');
    }
  }

  // GET /api/admin/dashboard/top-products?limit=10
  Future<List<TopProduct>> getTopProducts({int limit = 10}) async {
    if (limit < 1 || limit > 100) {
      throw Exception('Limit must be between 1 and 100');
    }

    try {
      final response = await _apiService.get(
        '/admin/dashboard/top-products',
        queryParameters: {'limit': limit.toString()},
      );
      return (response['data'] as List<dynamic>)
          .map((e) => TopProduct.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load top products: $e');
    }
  }

  // GET /api/admin/dashboard/current-month
  Future<Map<String, dynamic>> getCurrentMonthStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard/current-month');
      return response['data'];
    } catch (e) {
      throw Exception('Failed to load month stats: $e');
    }
  }

  // GET /api/auth/admin/notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _apiService.get('/auth/admin/notifications');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
