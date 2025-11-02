import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/admin_user.dart';

class AdminUserService {
  final String baseUrl = '${AppConfig.baseUrl}/admin/users';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/admin/users - Get all users with pagination and filters
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String role = 'all',
    String status = 'all',
    String search = '',
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'role': role,
        'status': status,
        'search': search,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final users = (data['data']['users'] as List)
              .map((item) => AdminUserList.fromJson(item))
              .toList();
          final pagination = UserPagination.fromJson(
            data['data']['pagination'],
          );

          return {'users': users, 'pagination': pagination};
        } else {
          throw Exception(
            data['message'] ?? 'Lỗi khi lấy danh sách người dùng',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách người dùng');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // GET /api/admin/users/:id - Get user detail with statistics
  Future<AdminUserDetailResponse> getUserById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return AdminUserDetailResponse.fromJson(data['data']);
        } else {
          throw Exception(
            data['message'] ?? 'Lỗi khi lấy thông tin người dùng',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Lỗi khi lấy thông tin người dùng');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // PUT /api/admin/users/:id/role - Update user role
  Future<void> updateUserRole(int id, String role) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id/role'),
        headers: headers,
        body: json.encode({'role': role}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Lỗi khi cập nhật quyền');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Không có quyền thực hiện');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Lỗi khi cập nhật quyền');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // PUT /api/admin/users/:id/status - Update user status
  Future<void> updateUserStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id/status'),
        headers: headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Lỗi khi cập nhật trạng thái');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Không có quyền thực hiện');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Lỗi khi cập nhật trạng thái');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // DELETE /api/admin/users/:id - Delete user
  Future<void> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Lỗi khi xóa người dùng');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Không thể xóa người dùng này');
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Không có quyền thực hiện');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Lỗi khi xóa người dùng');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
