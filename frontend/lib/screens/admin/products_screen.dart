import 'package:flutter/material.dart';
import '../../widgets/admin/admin_card.dart';
import '../../widgets/admin/admin_filter_bar.dart';
import '../../services/admin_product_service.dart';
import '../../services/category_service.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../config/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final AdminProductService _productService = AdminProductService();
  final CategoryService _categoryService = CategoryService();

  String _searchQuery = '';
  String? _selectedFilter;
  int? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> _products = [];
  Map<String, dynamic>? _pagination;
  Map<String, dynamic> _stats = {
    'total': 0,
    'in_stock': 0,
    'out_of_stock': 0,
    'low_stock': 0,
  };

  int _currentPage = 1;
  final int _itemsPerPage = 20;

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProducts(), _loadStats(), _loadCategories()]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build filters
      bool? isFeatured;
      bool? isActive;

      if (_selectedFilter == 'featured') {
        isFeatured = true;
      } else if (_selectedFilter == 'active') {
        isActive = true;
      } else if (_selectedFilter == 'inactive') {
        isActive = false;
      }

      final result = await _productService.getProducts(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
        isFeatured: isFeatured,
        isActive: isActive,
      );

      if (mounted) {
        setState(() {
          _products = result['products'] as List<Product>;
          _pagination = result['pagination'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
          _products = [];
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _productService.getProductStats();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa sản phẩm thành công'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _navigateToProductForm({Product? product}) {
    Navigator.pushNamed(
      context,
      '/admin/product-form',
      arguments: product,
    ).then((_) => _loadData());
  }

  Future<void> _exportProducts() async {
    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang xuất dữ liệu...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Prepare filters
      bool? isFeatured;
      bool? isActive;
      if (_selectedFilter == 'featured') {
        isFeatured = true;
      } else if (_selectedFilter == 'active') {
        isActive = true;
      } else if (_selectedFilter == 'inactive') {
        isActive = false;
      }

      await _productService.exportProducts(
        categoryId: _selectedCategoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isFeatured: isFeatured,
        isActive: isActive,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xuất dữ liệu thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  final List<FilterChipData> _filters = [
    FilterChipData(label: 'Tất cả', value: 'all', icon: Icons.apps),
    FilterChipData(label: 'Nổi bật', value: 'featured', icon: Icons.star),
    FilterChipData(
      label: 'Hoạt động',
      value: 'active',
      icon: Icons.check_circle,
    ),
    FilterChipData(
      label: 'Tạm ẩn',
      value: 'inactive',
      icon: Icons.remove_circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AdminFilterBar(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
                _currentPage = 1;
              });
              _loadProducts();
            },
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
                _currentPage = 1;
              });
              _loadProducts();
            },
            onClearFilters: () {
              setState(() {
                _selectedFilter = null;
                _searchQuery = '';
                _selectedCategoryId = null;
                _currentPage = 1;
              });
              _loadProducts();
            },
            additionalActions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category filter dropdown
                if (_categories.isNotEmpty)
                  PopupMenuButton<int?>(
                    icon: Icon(
                      Icons.category_outlined,
                      color: _selectedCategoryId != null
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                    tooltip: 'Lọc theo danh mục',
                    onSelected: (categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                        _currentPage = 1;
                      });
                      _loadProducts();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int?>(
                        value: null,
                        child: Text('Tất cả danh mục'),
                      ),
                      const PopupMenuDivider(),
                      ..._categories.map((category) {
                        return PopupMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  color: Colors.green[700],
                  tooltip: 'Xuất danh sách',
                  onPressed: _exportProducts,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Thêm sản phẩm mới',
                  onPressed: () => _navigateToProductForm(),
                ),
              ],
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AdminMiniCard(
                    label: 'Tổng sản phẩm',
                    value: _stats['total'].toString(),
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminMiniCard(
                    label: 'Còn hàng',
                    value: _stats['in_stock'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminMiniCard(
                    label: 'Hết hàng',
                    value: _stats['out_of_stock'].toString(),
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminMiniCard(
                    label: 'Sắp hết',
                    value: _stats['low_stock'].toString(),
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != null
                  ? 'Thử thay đổi bộ lọc'
                  : 'Bấm nút + để thêm sản phẩm mới',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ),
        if (_pagination != null) _buildPagination(),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final imageUrl = product.primaryImage ?? product.images?.firstOrNull;
    final stockColor = product.stockQuantity == 0
        ? Colors.red
        : product.stockQuantity < 10
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToProductForm(product: product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.amber),
                                SizedBox(width: 2),
                                Text(
                                  'Nổi bật',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName ?? 'Chưa phân loại',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)}₫',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.salePrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${product.salePrice!.toStringAsFixed(0)}₫',
                            style: const TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stockColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 14,
                                color: stockColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.stockQuantity}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: stockColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToProductForm(product: product);
                  } else if (value == 'delete') {
                    _deleteProduct(product);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = _pagination!['total_pages'] as int;
    final currentPage = _pagination!['current_page'] as int;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() => _currentPage = currentPage - 1);
                    _loadProducts();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            'Trang $currentPage / $totalPages',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => _currentPage = currentPage + 1);
                    _loadProducts();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
