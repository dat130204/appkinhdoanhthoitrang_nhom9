import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../utils/admin_helpers.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final notificationProvider = Provider.of<NotificationPreferencesProvider>(
      context,
    );
    final user = authProvider.user;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user?.fullName[0].toUpperCase() ?? 'A',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Admin',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'admin@example.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 14,
                                    color: Colors.purple[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Quản trị viên',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
          ),

          const SizedBox(height: 16),

          // General Settings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Thông báo'),
                  subtitle: const Text('Quản lý thông báo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showNotificationSettings(context, notificationProvider);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(
                    languageProvider.isVietnamese ? 'Ngôn ngữ' : 'Language',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese ? 'Tiếng Việt' : 'English',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageSettings(context, languageProvider);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(
                    languageProvider.isVietnamese ? 'Giao diện' : 'Theme',
                  ),
                  subtitle: Text(
                    _getThemeModeName(
                      themeProvider.themeMode,
                      languageProvider,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeSettings(context, themeProvider);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // System Settings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Sao lưu dữ liệu'),
                  subtitle: const Text('Xuất dữ liệu hệ thống'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showBackupDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Bảo mật'),
                  subtitle: const Text('Đổi mật khẩu, xác thực 2 lớp'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showSecuritySettings(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Thông tin ứng dụng'),
                  subtitle: const Text('Phiên bản 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logout
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode, LanguageProvider languageProvider) {
    switch (mode) {
      case ThemeMode.light:
        return languageProvider.isVietnamese ? 'Sáng' : 'Light';
      case ThemeMode.dark:
        return languageProvider.isVietnamese ? 'Tối' : 'Dark';
      case ThemeMode.system:
        return languageProvider.isVietnamese ? 'Theo hệ thống' : 'System';
    }
  }

  void _showNotificationSettings(
    BuildContext context,
    NotificationPreferencesProvider provider,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isVietnamese
              ? 'Cài đặt thông báo'
              : 'Notification Settings',
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(
                    languageProvider.isVietnamese
                        ? 'Đơn hàng mới'
                        : 'New Orders',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese
                        ? 'Nhận thông báo khi có đơn hàng mới'
                        : 'Receive notifications for new orders',
                  ),
                  value: provider.newOrders,
                  onChanged: (value) {
                    provider.setNewOrders(value);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(
                    languageProvider.isVietnamese
                        ? 'Đánh giá mới'
                        : 'New Reviews',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese
                        ? 'Nhận thông báo khi có đánh giá mới'
                        : 'Receive notifications for new reviews',
                  ),
                  value: provider.newReviews,
                  onChanged: (value) {
                    provider.setNewReviews(value);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(
                    languageProvider.isVietnamese
                        ? 'Người dùng mới'
                        : 'New Users',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese
                        ? 'Nhận thông báo khi có người dùng đăng ký'
                        : 'Receive notifications for new user registrations',
                  ),
                  value: provider.newUsers,
                  onChanged: (value) {
                    provider.setNewUsers(value);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(
                    languageProvider.isVietnamese
                        ? 'Hàng tồn kho thấp'
                        : 'Low Stock',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese
                        ? 'Nhận thông báo khi hàng tồn kho thấp'
                        : 'Receive notifications for low stock items',
                  ),
                  value: provider.lowStock,
                  onChanged: (value) {
                    provider.setLowStock(value);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(
                    languageProvider.isVietnamese
                        ? 'Cập nhật hệ thống'
                        : 'System Updates',
                  ),
                  subtitle: Text(
                    languageProvider.isVietnamese
                        ? 'Nhận thông báo về cập nhật hệ thống'
                        : 'Receive notifications about system updates',
                  ),
                  value: provider.systemUpdates,
                  onChanged: (value) {
                    provider.setSystemUpdates(value);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isVietnamese ? 'Đóng' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          provider.isVietnamese ? 'Chọn ngôn ngữ' : 'Select Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: provider.locale.languageCode,
              onChanged: (value) {
                provider.setLanguage('vi');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã chuyển sang Tiếng Việt'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: provider.locale.languageCode,
              onChanged: (value) {
                provider.setLanguage('en');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switched to English'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.isVietnamese ? 'Đóng' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings(BuildContext context, ThemeProvider provider) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isVietnamese ? 'Chọn giao diện' : 'Select Theme',
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(languageProvider.isVietnamese ? 'Sáng' : 'Light'),
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (value) {
                    provider.setThemeMode(ThemeMode.light);
                    setState(() {});
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(languageProvider.isVietnamese ? 'Tối' : 'Dark'),
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (value) {
                    provider.setThemeMode(ThemeMode.dark);
                    setState(() {});
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    languageProvider.isVietnamese ? 'Theo hệ thống' : 'System',
                  ),
                  value: ThemeMode.system,
                  groupValue: provider.themeMode,
                  onChanged: (value) {
                    provider.setThemeMode(ThemeMode.system);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isVietnamese ? 'Đóng' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu dữ liệu'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xuất dữ liệu hệ thống sang file CSV:'),
            SizedBox(height: 16),
            Text('• Sản phẩm'),
            Text('• Đơn hàng'),
            Text('• Người dùng'),
            Text('• Đánh giá'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang xuất dữ liệu...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xuất dữ liệu'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt bảo mật'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Đổi mật khẩu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Xác thực 2 lớp'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fashion Shop Admin'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2024 Fashion Shop'),
            SizedBox(height: 16),
            Text(
              'Hệ thống quản lý cửa hàng thời trang trực tuyến',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AdminHelpers.showConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất?',
      confirmText: 'Đăng xuất',
      isDangerous: true,
    );

    if (confirmed && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}
