import '../models/cart.dart';
import 'api_service.dart';

class CartService {
  final ApiService _api = ApiService();

  Future<Cart?> getCart() async {
    try {
      final response = await _api.get('/cart');

      if (response['success']) {
        return Cart.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Cart?> addToCart({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    try {
      final response = await _api.post('/cart/items', {
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'quantity': quantity,
      });

      if (response['success']) {
        return Cart.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Cart?> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await _api.put('/cart/items/$itemId', {
        'quantity': quantity,
      });

      if (response['success']) {
        return Cart.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Cart?> removeCartItem(int itemId) async {
    try {
      final response = await _api.delete('/cart/items/$itemId');

      if (response['success']) {
        return Cart.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _api.delete('/cart/clear');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
