import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(int? categoryId) {
    if (categoryId == null) {
      _selectedCategory = null;
    } else {
      _selectedCategory = _categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => _categories.first,
      );
    }
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void reset() {
    _categories = [];
    _selectedCategory = null;
    _error = null;
    notifyListeners();
  }
}
