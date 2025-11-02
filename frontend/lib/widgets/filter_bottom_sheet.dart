import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../config/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double? _minPrice;
  double? _maxPrice;
  int? _selectedCategoryId;
  String? _sortBy;

  // Price range constants
  static const double minPriceLimit = 0;
  static const double maxPriceLimit = 10000000; // 10 triệu

  @override
  void initState() {
    super.initState();
    final productProvider = context.read<ProductProvider>();
    _minPrice = productProvider.minPrice ?? minPriceLimit;
    _maxPrice = productProvider.maxPrice ?? maxPriceLimit;
    _selectedCategoryId = productProvider.selectedCategoryId;
    _sortBy = productProvider.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    'Đặt lại',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  _buildSectionTitle('Danh mục'),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(),

                  const SizedBox(height: 24),

                  // Price Range Filter
                  _buildSectionTitle('Khoảng giá'),
                  const SizedBox(height: 12),
                  _buildPriceRangeFilter(),

                  const SizedBox(height: 24),

                  // Sort Options
                  _buildSectionTitle('Sắp xếp theo'),
                  const SizedBox(height: 12),
                  _buildSortOptions(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng bộ lọc',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = categoryProvider.categories;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All categories chip
            ChoiceChip(
              label: const Text('Tất cả'),
              selected: _selectedCategoryId == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedCategoryId == null
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: _selectedCategoryId == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            // Category chips
            ...categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              return ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId = selected ? category.id : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        // Price labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatCurrency(_minPrice ?? minPriceLimit),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              _formatCurrency(_maxPrice ?? maxPriceLimit),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Range Slider
        RangeSlider(
          values: RangeValues(
            _minPrice ?? minPriceLimit,
            _maxPrice ?? maxPriceLimit,
          ),
          min: minPriceLimit,
          max: maxPriceLimit,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.2),
          labels: RangeLabels(
            _formatCurrency(_minPrice ?? minPriceLimit),
            _formatCurrency(_maxPrice ?? maxPriceLimit),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),

        // Quick price filters
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPriceFilter('Dưới 500K', 0, 500000),
            _buildQuickPriceFilter('500K - 1M', 500000, 1000000),
            _buildQuickPriceFilter('1M - 3M', 1000000, 3000000),
            _buildQuickPriceFilter('Trên 3M', 3000000, maxPriceLimit),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPriceFilter(String label, double min, double max) {
    final isSelected = _minPrice == min && _maxPrice == max;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _minPrice = min;
          _maxPrice = max;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    final sortOptions = {
      null: 'Mặc định',
      'price_asc': 'Giá: Thấp đến cao',
      'price_desc': 'Giá: Cao đến thấp',
      'name_asc': 'Tên: A - Z',
      'name_desc': 'Tên: Z - A',
      'newest': 'Mới nhất',
    };

    return Column(
      children: sortOptions.entries.map((entry) {
        final isSelected = _sortBy == entry.key;

        return RadioListTile<String?>(
          title: Text(
            entry.value,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          value: entry.key,
          groupValue: _sortBy,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _sortBy = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  void _resetFilters() {
    setState(() {
      _minPrice = minPriceLimit;
      _maxPrice = maxPriceLimit;
      _selectedCategoryId = null;
      _sortBy = null;
    });
  }

  void _applyFilters() {
    final productProvider = context.read<ProductProvider>();

    // Apply filters
    if (_selectedCategoryId != null) {
      productProvider.filterByCategory(_selectedCategoryId);
    }

    if (_minPrice != minPriceLimit || _maxPrice != maxPriceLimit) {
      productProvider.filterByPriceRange(_minPrice, _maxPrice);
    }

    if (_sortBy != null) {
      productProvider.sortProducts(_sortBy!);
    }

    // If all filters are default, clear filters
    if (_selectedCategoryId == null &&
        _minPrice == minPriceLimit &&
        _maxPrice == maxPriceLimit &&
        _sortBy == null) {
      productProvider.clearFilters();
    }

    Navigator.pop(context);
  }
}

// Helper function to show filter bottom sheet
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: const FilterBottomSheet(),
    ),
  );
}
