import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_order.dart';
import '../../services/admin_order_service.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final AdminOrderService _orderService = AdminOrderService();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<AdminOrderList> _orders = [];
  OrderPagination? _pagination;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedStatus = 'all';
  int _currentPage = 1;
  final int _limit = 20;

  final List<Map<String, dynamic>> _statusFilters = [
    {'value': 'all', 'label': 'Tất cả', 'color': Colors.grey},
    {'value': 'pending', 'label': 'Chờ xác nhận', 'color': Colors.orange},
    {'value': 'processing', 'label': 'Đang xử lý', 'color': Colors.blue},
    {'value': 'shipped', 'label': 'Đang giao', 'color': Colors.purple},
    {'value': 'delivered', 'label': 'Đã giao', 'color': Colors.green},
    {'value': 'cancelled', 'label': 'Đã hủy', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _orderService.getOrders(
        page: _currentPage,
        limit: _limit,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        _orders = result['orders'] as List<AdminOrderList>;
        _pagination = result['pagination'] as OrderPagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadOrders();
  }

  void _onSearch() {
    setState(() {
      _currentPage = 1;
    });
    _loadOrders();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadOrders();
  }

  Color _getStatusColor(String status) {
    final filter = _statusFilters.firstWhere(
      (f) => f['value'] == status,
      orElse: () => _statusFilters.first,
    );
    return filter['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Quản Lý Đơn Hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Xuất danh sách',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadOrders(isRefresh: true),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF2196F3),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn, tên, SĐT...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),

          // Status Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatus == filter['value'];
                return FilterChip(
                  label: Text(filter['label'] as String),
                  selected: isSelected,
                  onSelected: (_) =>
                      _onStatusFilterChanged(filter['value'] as String),
                  backgroundColor: Colors.white,
                  selectedColor: (filter['color'] as Color).withOpacity(0.2),
                  checkmarkColor: filter['color'] as Color,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? filter['color'] as Color
                        : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? filter['color'] as Color
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _orders.isEmpty
                ? _buildEmptyWidget()
                : RefreshIndicator(
                    onRefresh: () => _loadOrders(isRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length + 1, // +1 for pagination
                      itemBuilder: (context, index) {
                        if (index == _orders.length) {
                          return _buildPaginationWidget();
                        }
                        return _buildOrderCard(_orders[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AdminOrderList order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    order.customerPhone,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${order.itemCount} sản phẩm',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Text(
                    _currencyFormat.format(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
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

  Widget _buildPaginationWidget() {
    if (_pagination == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Trang $_currentPage / ${_pagination!.totalPages} (Tổng: ${_pagination!.total} đơn)',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pagination!.hasPreviousPage
                    ? () => _onPageChanged(_currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Trước'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _pagination!.hasNextPage
                    ? () => _onPageChanged(_currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right, size: 20),
                label: const Text('Sau'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadOrders(isRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy đơn hàng nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_searchController.text.isNotEmpty || _selectedStatus != 'all')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _selectedStatus = 'all';
                    _loadOrders(isRefresh: true);
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất danh sách đơn hàng'),
        content: const Text(
          'Bạn có muốn xuất danh sách đơn hàng hiện tại sang file CSV?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportOrders();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportOrders() async {
    try {
      final url = await _orderService.getExportUrl(
        format: 'csv',
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link xuất file: $url'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToOrderDetail(int orderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      ),
    );

    // Refresh if order was updated
    if (result == true) {
      _loadOrders();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
