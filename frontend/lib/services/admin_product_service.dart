import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';
import '../models/product.dart';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    as file_download;

/// Service for admin product management
/// Handles CRUD operations for products in admin panel
class AdminProductService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  /// Get all products with pagination and filters (admin view)
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    int? categoryId,
    String? brand,
    bool? isFeatured,
    bool? isActive,
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (brand != null && brand.isNotEmpty) {
        queryParams['brand'] = brand;
      }
      if (isFeatured != null) {
        queryParams['is_featured'] = isFeatured.toString();
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final uri = Uri.parse(
        '$_baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> productsJson = data['data']['products'];
          final products = productsJson
              .map((json) => Product.fromJson(json))
              .toList();

          return {
            'products': products,
            'pagination': data['data']['pagination'],
          };
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy danh sách sản phẩm');
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

  /// Get product by ID (admin view with full details)
  Future<Product> getProductById(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Handle both 'product' key and direct data
          final productData = data['data']['product'] ?? data['data'];
          return Product.fromJson(productData);
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy thông tin sản phẩm');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Sản phẩm không tồn tại');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Create new product
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Product.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi tạo sản phẩm');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        // Handle validation errors
        if (data['errors'] != null && data['errors'] is List) {
          final errors = (data['errors'] as List)
              .map((e) => e['msg'] ?? e['message'] ?? e.toString())
              .join(', ');
          throw Exception(errors);
        }
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Update existing product
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final response = await http.put(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(productData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Product.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi cập nhật sản phẩm');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        if (data['errors'] != null && data['errors'] is List) {
          final errors = (data['errors'] as List)
              .map((e) => e['msg'] ?? e['message'] ?? e.toString())
              .join(', ');
          throw Exception(errors);
        }
        throw Exception(data['message'] ?? 'Dữ liệu không hợp lệ');
      } else if (response.statusCode == 404) {
        throw Exception('Sản phẩm không tồn tại');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Lỗi xóa sản phẩm');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Sản phẩm không tồn tại');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Get product statistics (for admin dashboard)
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      // Get all products without pagination to calculate stats
      final response = await http.get(
        Uri.parse('$_baseUrl/products?limit=1000'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> productsJson = data['data']['products'];
          final products = productsJson
              .map((json) => Product.fromJson(json))
              .toList();

          final total = products.length;
          final inStock = products.where((p) => p.stockQuantity > 0).length;
          final outOfStock = products.where((p) => p.stockQuantity == 0).length;
          final lowStock = products
              .where((p) => p.stockQuantity > 0 && p.stockQuantity < 10)
              .length;
          final featured = products.where((p) => p.isFeatured).length;
          final active = products.where((p) => p.isActive).length;

          return {
            'total': total,
            'in_stock': inStock,
            'out_of_stock': outOfStock,
            'low_stock': lowStock,
            'featured': featured,
            'active': active,
          };
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy thống kê sản phẩm');
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Get all brands for filter dropdown
  Future<List<String>> getBrands() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final response = await http.get(
        Uri.parse('$_baseUrl/products/brands'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> brandsJson = data['data'];
          return brandsJson.map((b) => b.toString()).toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy danh sách thương hiệu');
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Upload product images (returns list of image URLs)
  /// NOTE: This method is deprecated and not used in mobile builds
  /// Web-based file upload should use image_picker_web or similar packages
  @Deprecated('Use web-specific file upload implementation')
  Future<List<String>> uploadImages(List<dynamic> imageFiles) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token không tồn tại');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/products/upload-images'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add image files
      for (final imageFile in imageFiles) {
        // This will fail on mobile - method is deprecated
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFile.path?.toString() ?? '',
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> imagesJson = data['data']['images'];
          return imagesJson.map((url) => url.toString()).toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi upload ảnh');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Không có file nào được upload');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Export products to CSV
  Future<void> exportProducts({
    int? categoryId,
    String? search,
    String? brand,
    bool? isFeatured,
    bool? isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Build query params
      final queryParams = <String, String>{'format': 'csv'};

      if (categoryId != null)
        queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
      if (isFeatured != null)
        queryParams['is_featured'] = isFeatured ? '1' : '0';
      if (isActive != null) queryParams['is_active'] = isActive ? '1' : '0';

      final uri = Uri.parse(
        '$_baseUrl/products/admin/export',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web: Download file using platform-specific implementation
          final filename =
              'products_${DateTime.now().millisecondsSinceEpoch}.csv';
          file_download.downloadFile(response.bodyBytes, filename);
        } else {
          // Mobile/Desktop: Not supported
          throw Exception('Export chỉ khả dụng trên web browser');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xuất dữ liệu: $e');
    }
  }
}
