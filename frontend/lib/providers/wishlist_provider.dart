import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  // Check if product is in wishlist
  bool isInWishlist(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Load all wishlist items
  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _wishlistService.getWishlist();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product to wishlist
  Future<bool> addToWishlist(int productId) async {
    try {
      final success = await _wishlistService.addToWishlist(productId);
      if (success) {
        await loadWishlist(); // Reload to get updated list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove product from wishlist
  Future<bool> removeFromWishlist(int productId) async {
    try {
      final success = await _wishlistService.removeFromWishlist(productId);
      if (success) {
        _items.removeWhere((item) => item.productId == productId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle wishlist (add if not exist, remove if exist)
  Future<bool> toggleWishlist(int productId) async {
    if (isInWishlist(productId)) {
      return await removeFromWishlist(productId);
    } else {
      return await addToWishlist(productId);
    }
  }

  // Clear all wishlist
  Future<bool> clearWishlist() async {
    try {
      final success = await _wishlistService.clearWishlist();
      if (success) {
        _items = [];
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reset state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
