import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<Product>> getProducts({
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? brand,
    bool? isFeatured,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null)
        queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (brand != null) queryParams['brand'] = brand;
      if (isFeatured != null)
        queryParams['is_featured'] = isFeatured.toString();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _api.get(
        '/products',
        queryParameters: queryParams,
        includeAuth: false,
      );

      if (response['success']) {
        final List<dynamic> productsData = response['data']['products'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      print('=== GET PRODUCT BY ID DEBUG ===');
      print('Product ID: $id');
      final response = await _api.get('/products/$id', includeAuth: false);

      print('Response success: ${response['success']}');
      print('Response data keys: ${response['data']?.keys}');

      if (response['success'] && response['data'] != null) {
        // Check if data contains 'product' key or is the product itself
        final productData = response['data']['product'] ?? response['data'];
        print('Product data exists: ${productData != null}');
        return Product.fromJson(productData);
      }

      print('Product not found in response');
      return null;
    } catch (e, stack) {
      print('=== ERROR LOADING PRODUCT BY ID ===');
      print('Error: $e');
      print('Stack: $stack');
      return null;
    }
  }

  Future<List<Product>> getFeaturedProducts({int limit = 8}) async {
    try {
      final response = await _api.get(
        '/products/featured',
        queryParameters: {'limit': limit.toString()},
        includeAuth: false,
      );

      print('=== FEATURED PRODUCTS DEBUG ===');
      print('Response success: ${response['success']}');
      print('Response data type: ${response['data'].runtimeType}');
      print('Response data length: ${(response['data'] as List).length}');

      if (response['success']) {
        final List<dynamic> productsData = response['data'];
        final products = productsData
            .map((json) => Product.fromJson(json))
            .toList();
        print('Parsed products: ${products.length}');
        return products;
      }

      print('Response not successful');
      return [];
    } catch (e, stack) {
      print('=== ERROR LOADING FEATURED PRODUCTS ===');
      print('Error: $e');
      print('Stack: $stack');
      return [];
    }
  }

  Future<List<String>> getBrands() async {
    try {
      final response = await _api.get('/products/brands', includeAuth: false);

      if (response['success']) {
        final List<dynamic> brandsData = response['data'];
        return brandsData.map((brand) => brand.toString()).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }
}
