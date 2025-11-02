import 'package:flutter/material.dart';
import 'category_list_screen.dart';

/// Wrapper screen for admin categories
/// Redirects to the full-featured CategoryListScreen
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryListScreen();
  }
}
