import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../config/app_colors.dart';
import '../utils/constants.dart';
import '../config/app_config.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onCategoryTap;
  final int? selectedCategoryId;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;

          return GestureDetector(
            onTap: () => onCategoryTap(category),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category Icon/Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child:
                          category.image != null && category.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: '${AppConfig.baseUrl}${category.image}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.backgroundGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.backgroundGrey,
                                child: Icon(
                                  _getCategoryIcon(category.name),
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              _getCategoryIcon(category.name),
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category Name
                  Text(
                    category.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('nam') && name.contains('áo')) {
      return Icons.checkroom; // Men's shirts
    } else if (name.contains('nam') && name.contains('quần')) {
      return Icons.straighten; // Men's pants
    } else if (name.contains('nữ') && name.contains('áo')) {
      return Icons.checkroom_outlined; // Women's shirts
    } else if (name.contains('nữ') && name.contains('quần')) {
      return Icons.dry_cleaning; // Women's pants
    } else if (name.contains('đầm') || name.contains('váy')) {
      return Icons.girl; // Dresses
    } else if (name.contains('jean')) {
      return Icons.pan_tool; // Jeans
    } else if (name.contains('giày') || name.contains('dép')) {
      return Icons.shopping_bag; // Shoes
    } else if (name.contains('túi') || name.contains('balo')) {
      return Icons.work; // Bags
    } else if (name.contains('phụ kiện')) {
      return Icons.watch; // Accessories
    } else if (name.contains('trẻ em')) {
      return Icons.child_care; // Kids
    }

    return Icons.category; // Default icon
  }
}

// Grid Category List (for full screen category view)
class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.emptyCategoriesMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Card(
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category Image/Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: category.image != null && category.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${AppConfig.baseUrl}${category.image}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.backgroundGrey,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getCategoryIcon(category.name),
                              color: AppColors.primary,
                              size: 35,
                            ),
                          )
                        : Icon(
                            _getCategoryIcon(category.name),
                            color: AppColors.primary,
                            size: 35,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                // Category Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Product Count (if available)
                if (category.productCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${category.productCount} sản phẩm',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('nam') && name.contains('áo')) {
      return Icons.checkroom;
    } else if (name.contains('nam') && name.contains('quần')) {
      return Icons.straighten;
    } else if (name.contains('nữ') && name.contains('áo')) {
      return Icons.checkroom_outlined;
    } else if (name.contains('nữ') && name.contains('quần')) {
      return Icons.dry_cleaning;
    } else if (name.contains('đầm') || name.contains('váy')) {
      return Icons.girl;
    } else if (name.contains('jean')) {
      return Icons.pan_tool;
    } else if (name.contains('giày') || name.contains('dép')) {
      return Icons.shopping_bag;
    } else if (name.contains('túi') || name.contains('balo')) {
      return Icons.work;
    } else if (name.contains('phụ kiện')) {
      return Icons.watch;
    } else if (name.contains('trẻ em')) {
      return Icons.child_care;
    }

    return Icons.category;
  }
}
