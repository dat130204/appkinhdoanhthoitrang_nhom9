import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/admin/admin_app_bar.dart';
import '../admin/dashboard_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  String _currentRoute = '/admin/dashboard';

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || authProvider.user?.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn không có quyền truy cập trang này'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn || authProvider.user?.role != 'admin') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const AdminAppBar(title: 'Admin Panel'),
      drawer: AdminDrawer(currentRoute: _currentRoute),
      body: const DashboardScreen(),
    );
  }
}

class AdminRoute extends StatelessWidget {
  final Widget child;
  final String routeName;

  const AdminRoute({super.key, required this.child, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.user?.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Không có quyền truy cập')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Bạn không có quyền truy cập trang này',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chỉ quản trị viên mới có thể truy cập',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/main');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AdminAppBar(title: _getPageTitle(routeName)),
          drawer: AdminDrawer(currentRoute: routeName),
          body: child,
        );
      },
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/admin/dashboard':
        return 'Dashboard';
      case '/admin/products':
        return 'Quản lý Sản phẩm';
      case '/admin/categories':
        return 'Quản lý Danh mục';
      case '/admin/orders':
        return 'Quản lý Đơn hàng';
      case '/admin/users':
        return 'Quản lý Người dùng';
      case '/admin/reviews':
        return 'Quản lý Đánh giá';
      case '/admin/settings':
        return 'Cài đặt';
      default:
        return 'Admin Panel';
    }
  }
}
