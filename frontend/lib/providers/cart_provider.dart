import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  Cart? _cart;
  bool _isLoading = false;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart?.totalItems ?? 0;
  double get subtotal => _cart?.summary.subtotal ?? 0;
  bool get isEmpty => _cart?.isEmpty ?? true;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cart = await _cartService.getCart();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    try {
      _cart = await _cartService.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      notifyListeners();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateQuantity(int itemId, int quantity) async {
    try {
      _cart = await _cartService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeItem(int itemId) async {
    try {
      _cart = await _cartService.removeCartItem(itemId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final success = await _cartService.clearCart();
      if (success) {
        _cart = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    _cart = null;
    notifyListeners();
  }
}
