import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _api = ApiService();

  Future<List<Category>> getCategories({int? parentId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (parentId != null) {
        queryParams['parent_id'] = parentId.toString();
      }

      final response = await _api.get(
        '/categories',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        includeAuth: false,
      );

      print('=== CATEGORIES DEBUG ===');
      print('Response success: ${response['success']}');
      print('Response data type: ${response['data'].runtimeType}');

      if (response['success']) {
        final List<dynamic> categoriesData = response['data'];
        final categories = categoriesData
            .map((json) => Category.fromJson(json))
            .toList();
        print('Parsed categories: ${categories.length}');
        return categories;
      }

      print('Response not successful');
      return [];
    } catch (e, stack) {
      print('=== ERROR LOADING CATEGORIES ===');
      print('Error: $e');
      print('Stack: $stack');
      return [];
    }
  }

  Future<List<Category>> getCategoryTree() async {
    try {
      final response = await _api.get('/categories/tree', includeAuth: false);

      if (response['success']) {
        final List<dynamic> categoriesData = response['data'];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Category?> getCategoryById(int id) async {
    try {
      final response = await _api.get('/categories/$id', includeAuth: false);

      if (response['success']) {
        return Category.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Category>> getMainCategories() async {
    return getCategories(parentId: null);
  }
}
