import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A237E), const Color(0xFF283593)]
                    : [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fashion Shop Management',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: '/admin/dashboard',
                  isSelected: currentRoute == '/admin/dashboard',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Quản lý Sản phẩm',
                  route: '/admin/products',
                  isSelected: currentRoute == '/admin/products',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.category_rounded,
                  title: 'Quản lý Danh mục',
                  route: '/admin/categories',
                  isSelected: currentRoute == '/admin/categories',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Quản lý Đơn hàng',
                  route: '/admin/orders',
                  isSelected: currentRoute == '/admin/orders',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_rounded,
                  title: 'Quản lý Người dùng',
                  route: '/admin/users',
                  isSelected: currentRoute == '/admin/users',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.rate_review_rounded,
                  title: 'Quản lý Đánh giá',
                  route: '/admin/reviews',
                  isSelected: currentRoute == '/admin/reviews',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Cài đặt',
                  route: '/admin/settings',
                  isSelected: currentRoute == '/admin/settings',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.arrow_back_rounded,
                  title: 'Về trang chủ',
                  route: '/main',
                  isSelected: false,
                  isExit: true,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    bool isExit = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? (isDark
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Theme.of(context).primaryColor.withOpacity(0.1))
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).primaryColor
              : (isDark ? Colors.grey[400] : Colors.grey[700]),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).primaryColor
                : (isDark ? Colors.grey[300] : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isSelected) {
            if (isExit) {
              // Navigate to main app
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false,
              );
            } else {
              Navigator.pushReplacementNamed(context, route);
            }
          }
        },
      ),
    );
  }
}
