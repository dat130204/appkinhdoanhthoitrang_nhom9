import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;

  bool _isLoading = false;
  bool _isFeaturedLoading = false;
  String? _error;

  // Filters
  int? _selectedCategoryId;
  String? _searchQuery;
  double? _minPrice;
  double? _maxPrice;
  String? _sortBy; // price_asc, price_desc, name_asc, name_desc, newest

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get filteredProducts =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  Product? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  bool get isFeaturedLoading => _isFeaturedLoading;
  String? get error => _error;

  int? get selectedCategoryId => _selectedCategoryId;
  String? get searchQuery => _searchQuery;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get sortBy => _sortBy;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // Fetch all products
  Future<void> fetchProducts({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) {
      _currentPage = 1;
      _products = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getProducts(
        page: _currentPage,
        limit: 20,
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
      );

      if (loadMore) {
        _products.addAll(products);
      } else {
        _products = products;
      }

      // Note: API doesn't return pagination info, so we estimate
      _hasMore = products.length >= 20;
      if (_hasMore) {
        _currentPage++;
      }

      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    _isFeaturedLoading = true;
    _error = null;
    notifyListeners();

    try {
      _featuredProducts = await _productService.getFeaturedProducts(limit: 10);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFeaturedLoading = false;
      notifyListeners();
    }
  }

  // Fetch product by ID
  Future<void> fetchProductById(int id) async {
    _isLoading = true;
    _error = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    _products = [];

    if (query.isEmpty) {
      _filteredProducts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.searchProducts(query);
      _filteredProducts = _products;
      _hasMore = _products.length >= 20;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by category
  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    fetchProducts();
  }

  // Filter by price range
  void filterByPriceRange(double? minPrice, double? maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _currentPage = 1;
    fetchProducts();
  }

  // Sort products
  void sortProducts(String sortBy) {
    _sortBy = sortBy;
    _currentPage = 1;
    fetchProducts();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = null;
    _filteredProducts = [];
    _currentPage = 1;
    fetchProducts();
  }

  // Apply local filters (for client-side filtering)
  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(
              _searchQuery!.toLowerCase(),
            ) ||
            (product.description?.toLowerCase().contains(
                  _searchQuery!.toLowerCase(),
                ) ??
                false);
      }).toList();
    }

    // Filter by price range
    if (_minPrice != null) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.finalPrice >= _minPrice!;
      }).toList();
    }

    if (_maxPrice != null) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.finalPrice <= _maxPrice!;
      }).toList();
    }

    // Apply sorting
    if (_sortBy != null) {
      switch (_sortBy) {
        case 'price_asc':
          _filteredProducts.sort(
            (a, b) => a.finalPrice.compareTo(b.finalPrice),
          );
          break;
        case 'price_desc':
          _filteredProducts.sort(
            (a, b) => b.finalPrice.compareTo(a.finalPrice),
          );
          break;
        case 'name_asc':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'newest':
          _filteredProducts.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          break;
        case 'popular':
          _filteredProducts.sort(
            (a, b) => b.soldQuantity.compareTo(a.soldQuantity),
          );
          break;
        case 'rating':
          _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(int categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  // Get related products (same category, different product)
  List<Product> getRelatedProducts(
    int productId,
    int categoryId, {
    int limit = 6,
  }) {
    return _products
        .where(
          (product) =>
              product.id != productId && product.categoryId == categoryId,
        )
        .take(limit)
        .toList();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
