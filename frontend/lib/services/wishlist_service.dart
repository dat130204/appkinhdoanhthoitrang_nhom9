import '../models/wishlist.dart';
import 'api_service.dart';

class WishlistService {
  final ApiService _api = ApiService();

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _api.get('/wishlists');

      if (response['success']) {
        final items = (response['data']['items'] as List)
            .map((item) => WishlistItem.fromJson(item))
            .toList();
        return items;
      }

      throw Exception(response['message'] ?? 'Lỗi lấy danh sách yêu thích');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Lỗi kết nối server');
    }
  }

  Future<bool> addToWishlist(int productId) async {
    try {
      final response = await _api.post('/wishlists', {'product_id': productId});

      return response['success'] == true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Lỗi kết nối server');
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    try {
      final response = await _api.delete('/wishlists/$productId');
      return response['success'] == true;
    } catch (e) {
      if (e is ApiException) rethrow;
      return false;
    }
  }

  Future<bool> isInWishlist(int productId) async {
    try {
      final response = await _api.get('/wishlists/check/$productId');
      return response['data']['isInWishlist'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearWishlist() async {
    try {
      final response = await _api.delete('/wishlists/clear');
      return response['success'] == true;
    } catch (e) {
      if (e is ApiException) rethrow;
      return false;
    }
  }
}
