import 'api_service.dart';
import '../models/admin_order.dart';
import '../config/app_config.dart';

class AdminOrderService {
  final ApiService _apiService = ApiService();

  // GET /api/admin/orders?page=1&limit=20&status=all&search=
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        '/admin/orders',
        queryParameters: queryParams,
      );

      final orders = (response['data']['orders'] as List<dynamic>)
          .map((e) => AdminOrderList.fromJson(e))
          .toList();

      final pagination = OrderPagination.fromJson(
        response['data']['pagination'],
      );

      return {'orders': orders, 'pagination': pagination};
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // GET /api/admin/orders/:id
  Future<AdminOrderDetail> getOrderById(int id) async {
    try {
      final response = await _apiService.get('/admin/orders/$id');
      return AdminOrderDetail.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load order detail: $e');
    }
  }

  // PUT /api/admin/orders/:id/status
  Future<void> updateOrderStatus(int id, String status, {String? notes}) async {
    try {
      await _apiService.put('/admin/orders/$id/status', {
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // DELETE /api/admin/orders/:id
  Future<void> deleteOrder(int id) async {
    try {
      await _apiService.delete('/admin/orders/$id');
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // GET /api/admin/orders/export?format=csv
  Future<String> getExportUrl({
    String format = 'csv',
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{'format': format};

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    // Build URL with query parameters
    final uri = Uri.parse('${AppConfig.baseUrl}/admin/orders/export');
    final finalUri = uri.replace(queryParameters: queryParams);

    return finalUri.toString();
  }
}
