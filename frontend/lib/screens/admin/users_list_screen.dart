import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/admin_user.dart';
import '../../services/admin_user_service.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final AdminUserService _userService = AdminUserService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<AdminUserList> _users = [];
  UserPagination? _pagination;
  bool _isLoading = true;
  String _errorMessage = '';

  // Filters
  int _currentPage = 1;
  final int _limit = 20;
  String _selectedRole = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  String _sortBy = 'created_at';
  String _sortOrder = 'DESC';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _userService.getUsers(
        page: _currentPage,
        limit: _limit,
        role: _selectedRole,
        status: _selectedStatus,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _users = result['users'] as List<AdminUserList>;
        _pagination = result['pagination'] as UserPagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _onRoleFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedRole = value;
        _currentPage = 1;
      });
      _loadUsers();
    }
  }

  void _onStatusFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
        _currentPage = 1;
      });
      _loadUsers();
    }
  }

  void _onSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortOrder = _sortOrder == 'DESC' ? 'ASC' : 'DESC';
      } else {
        _sortBy = column;
        _sortOrder = 'DESC';
      }
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _previousPage() {
    if (_pagination?.hasPreviousPage == true) {
      setState(() {
        _currentPage--;
      });
      _loadUsers();
    }
  }

  void _nextPage() {
    if (_pagination?.hasNextPage == true) {
      setState(() {
        _currentPage++;
      });
      _loadUsers();
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Quản Lý Người Dùng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _onSearch,
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    // Role filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Quyền',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Quản trị viên'),
                          ),
                          DropdownMenuItem(
                            value: 'user',
                            child: Text('Người dùng'),
                          ),
                        ],
                        onChanged: _onRoleFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: 'blocked',
                            child: Text('Bị chặn'),
                          ),
                        ],
                        onChanged: _onStatusFilterChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Cards
          if (!_isLoading && _pagination != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Tổng số',
                      _pagination!.totalItems.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Trang hiện tại',
                      '${_pagination!.currentPage}/${_pagination!.totalPages}',
                      Icons.pages,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _users.isEmpty
                ? _buildEmptyWidget()
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Desktop/Tablet view - DataTable
                          if (MediaQuery.of(context).size.width > 600)
                            _buildDataTable()
                          else
                            // Mobile view - Cards
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _users.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return _buildUserCard(user);
                              },
                            ),
                          const SizedBox(height: 20),
                          // Pagination
                          if (_pagination != null) _buildPagination(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
          columns: [
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('name'),
                child: Row(
                  children: [
                    const Text(
                      'Người dùng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'name')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('email'),
                child: Row(
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'email')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('role'),
                child: Row(
                  children: [
                    const Text(
                      'Quyền',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'role')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('status'),
                child: Row(
                  children: [
                    const Text(
                      'Trạng thái',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'status')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('orders_count'),
                child: Row(
                  children: [
                    const Text(
                      'Đơn hàng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'orders_count')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('total_spent'),
                child: Row(
                  children: [
                    const Text(
                      'Tổng chi tiêu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'total_spent')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            DataColumn(
              label: InkWell(
                onTap: () => _onSort('created_at'),
                child: Row(
                  children: [
                    const Text(
                      'Ngày tham gia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_sortBy == 'created_at')
                      Icon(
                        _sortOrder == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            const DataColumn(
              label: Text(
                'Thao tác',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _users.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.avatar != null
                            ? CachedNetworkImageProvider(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (user.phone != null)
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Text(user.email),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.roleText,
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(user.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.statusText,
                      style: TextStyle(
                        color: _getStatusColor(user.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Text(user.ordersCount.toString()),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Text(_currencyFormat.format(user.totalSpent)),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(user.createdAt)),
                  onTap: () => _navigateToDetail(user.id),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => _handleAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text('Xem chi tiết'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'role',
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              user.isAdmin
                                  ? 'Chuyển thành User'
                                  : 'Chuyển thành Admin',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: user.isActive ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              user.isActive
                                  ? 'Chặn tài khoản'
                                  : 'Mở khóa tài khoản',
                              style: TextStyle(
                                color: user.isActive
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              'Xóa tài khoản',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserCard(AdminUserList user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(user.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.avatar != null
                        ? CachedNetworkImageProvider(user.avatar!)
                        : null,
                    child: user.avatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (user.phone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.phone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => _handleAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text('Xem chi tiết'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'role',
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              user.isAdmin
                                  ? 'Chuyển thành User'
                                  : 'Chuyển thành Admin',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: user.isActive ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              user.isActive
                                  ? 'Chặn tài khoản'
                                  : 'Mở khóa tài khoản',
                              style: TextStyle(
                                color: user.isActive
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              'Xóa tài khoản',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      user.roleText,
                      _getRoleColor(user.role),
                      Icons.admin_panel_settings,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      user.statusText,
                      _getStatusColor(user.status),
                      user.isActive ? Icons.check_circle : Icons.block,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Đơn hàng',
                      user.ordersCount.toString(),
                      Icons.shopping_bag,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Chi tiêu',
                      _currencyFormat.format(user.totalSpent),
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tham gia: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trang ${_pagination!.currentPage} / ${_pagination!.totalPages}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _pagination!.hasPreviousPage
                      ? _previousPage
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: _pagination!.hasPreviousPage
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300],
                    foregroundColor: _pagination!.hasPreviousPage
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _pagination!.hasNextPage ? _nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: _pagination!.hasNextPage
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300],
                    foregroundColor: _pagination!.hasNextPage
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
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
              onPressed: _loadUsers,
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy người dùng',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(int userId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(userId: userId)),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  void _handleAction(String action, AdminUserList user) {
    switch (action) {
      case 'view':
        _navigateToDetail(user.id);
        break;
      case 'role':
        _showChangeRoleDialog(user);
        break;
      case 'status':
        _showChangeStatusDialog(user);
        break;
      case 'delete':
        _showDeleteDialog(user);
        break;
    }
  }

  void _showChangeRoleDialog(AdminUserList user) {
    final newRole = user.isAdmin ? 'user' : 'admin';
    final newRoleText = user.isAdmin ? 'Người dùng' : 'Quản trị viên';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay Đổi Quyền'),
        content: Text(
          'Bạn có chắc chắn muốn chuyển quyền của ${user.name} thành $newRoleText?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserRole(user.id, newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(AdminUserList user) {
    final newStatus = user.isActive ? 'blocked' : 'active';
    final action = user.isActive ? 'chặn' : 'mở khóa';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Tài Khoản'),
        content: Text(
          'Bạn có chắc chắn muốn $action tài khoản của ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserStatus(user.id, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminUserList user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Tài Khoản'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản của ${user.name}?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(int userId, String newRole) async {
    try {
      await _userService.updateUserRole(userId, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật quyền thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateUserStatus(int userId, String newStatus) async {
    try {
      await _userService.updateUserStatus(userId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'blocked'
                  ? 'Đã chặn tài khoản'
                  : 'Đã mở khóa tài khoản',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await _userService.deleteUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa tài khoản thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
