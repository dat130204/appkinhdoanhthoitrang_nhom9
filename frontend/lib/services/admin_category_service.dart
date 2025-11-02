import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/admin_category.dart';

class AdminCategoryService {
  final String baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  // Get category stats
  Future<List<CategoryStats>> getCategoryStats() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories/admin/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> statsJson = data['data'];
          return statsJson.map((json) => CategoryStats.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy thống kê danh mục');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Get all categories
  Future<List<CategoryListItem>> getCategories() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson
              .map((json) => CategoryListItem.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy danh sách danh mục');
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Get category by ID
  Future<CategoryFormData> getCategoryById(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return CategoryFormData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy thông tin danh mục');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Danh mục không tồn tại');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Create category
  Future<CategoryListItem> createCategory(
    CategoryFormData formData,
    File? imageFile,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/categories'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['name'] = formData.name;
      if (formData.description != null && formData.description!.isNotEmpty) {
        request.fields['description'] = formData.description!;
      }
      if (formData.parentId != null) {
        request.fields['parent_id'] = formData.parentId.toString();
      }
      request.fields['display_order'] = formData.displayOrder.toString();

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return CategoryListItem.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi tạo danh mục');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Update category
  Future<CategoryListItem> updateCategory(
    int id,
    CategoryFormData formData,
    File? imageFile,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/categories/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['name'] = formData.name;
      if (formData.description != null && formData.description!.isNotEmpty) {
        request.fields['description'] = formData.description!;
      }
      if (formData.parentId != null) {
        request.fields['parent_id'] = formData.parentId.toString();
      }
      request.fields['display_order'] = formData.displayOrder.toString();

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return CategoryListItem.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi cập nhật danh mục');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Danh mục không tồn tại');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Lỗi xóa danh mục');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Danh mục không tồn tại');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Không thể xóa danh mục';
        final productCount = data['productCount'];
        if (productCount != null) {
          throw Exception('$message ($productCount sản phẩm)');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
