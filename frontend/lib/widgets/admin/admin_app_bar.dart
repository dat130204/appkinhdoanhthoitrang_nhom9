import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../config/app_colors.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const AdminAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();
}

class _AdminAppBarState extends State<AdminAppBar> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final notifications = await _adminService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'review':
        return Icons.rate_review;
      case 'user':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'review':
        return Colors.orange;
      case 'user':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  void _showNotificationsDialog(BuildContext context) {
    final notificationCount = _notifications
        .where((n) => n['isRead'] == false)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Thông báo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (notificationCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notificationCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingNotifications
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('Không có thông báo mới'),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final iconData = _getIconForType(notification['type']);
                    final color = _getColorForType(notification['type']);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(iconData, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        notification['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        notification['message'] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        notification['time'] ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
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

  @override
  Widget build(BuildContext context) {
    final notificationCount = _notifications
        .where((n) => n['isRead'] == false)
        .length;

    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      elevation: 0,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                _showNotificationsDialog(context);
              },
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
