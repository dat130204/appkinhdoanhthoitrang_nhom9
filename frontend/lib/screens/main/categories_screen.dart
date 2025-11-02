import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../config/app_colors.dart';
import '../../widgets/category_list.dart';
import '../../widgets/product_card.dart';
import '../../widgets/filter_bottom_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int? _selectedCategoryId;
  String _selectedView = 'grid'; // 'grid' or 'list'
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchCategories();
      }

      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load when 80% scrolled

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final productProvider = context.read<ProductProvider>();

    if (!productProvider.hasMore || productProvider.isLoading) {
      return;
    }

    setState(() => _isLoadingMore = true);

    await productProvider.fetchProducts(loadMore: true);

    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterBottomSheet(context);
            },
            tooltip: 'Bộ lọc',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              _selectedView == 'grid' ? Icons.grid_view : Icons.view_list,
            ),
            onSelected: (value) {
              setState(() {
                _selectedView = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'grid',
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view,
                      size: 20,
                      color: _selectedView == 'grid' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lưới',
                      style: TextStyle(
                        color: _selectedView == 'grid'
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'list',
                child: Row(
                  children: [
                    Icon(
                      Icons.view_list,
                      size: 20,
                      color: _selectedView == 'list' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Danh sách',
                      style: TextStyle(
                        color: _selectedView == 'list'
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading &&
              categoryProvider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error != null &&
              categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải danh mục',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.fetchCategories();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (categoryProvider.categories.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có danh mục nào',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return Column(
            children: [
              // Category horizontal list
              Container(
                color: Colors.white,
                child: CategoryList(
                  categories: categoryProvider.categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategoryTap: (category) {
                    setState(() {
                      if (_selectedCategoryId == category.id) {
                        _selectedCategoryId = null;
                        context.read<ProductProvider>().fetchProducts();
                      } else {
                        _selectedCategoryId = category.id;
                        context.read<ProductProvider>().filterByCategory(
                          category.id,
                        );
                      }
                    });
                  },
                ),
              ),

              // Selected category info
              if (_selectedCategoryId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getSelectedCategoryName(categoryProvider.categories),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                            context.read<ProductProvider>().fetchProducts();
                          });
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Xóa lọc'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Products list
              Expanded(child: _buildProductsList()),
            ],
          );
        },
      ),
    );
  }

  String _getSelectedCategoryName(List<Category> categories) {
    final category = categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => Category(id: 0, name: 'Tất cả', createdAt: DateTime.now()),
    );
    return category.name;
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && productProvider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error != null && productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải sản phẩm',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedCategoryId != null) {
                      productProvider.filterByCategory(_selectedCategoryId!);
                    } else {
                      productProvider.fetchProducts();
                    }
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final products = productProvider.filteredProducts.isNotEmpty
            ? productProvider.filteredProducts
            : productProvider.products;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy sản phẩm nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_selectedCategoryId != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = null;
                        productProvider.fetchProducts();
                      });
                    },
                    child: const Text('Xem tất cả sản phẩm'),
                  ),
                ],
              ],
            ),
          );
        }

        if (_selectedView == 'grid') {
          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedCategoryId != null) {
                productProvider.filterByCategory(_selectedCategoryId!);
              } else {
                await productProvider.fetchProducts();
              }
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == products.length) {
                  // Loading indicator at bottom
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: product.id,
                    );
                  },
                );
              },
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedCategoryId != null) {
                productProvider.filterByCategory(_selectedCategoryId!);
              } else {
                await productProvider.fetchProducts();
              }
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: products.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == products.length) {
                  // Loading indicator at bottom
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCardHorizontal(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: product.id,
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
