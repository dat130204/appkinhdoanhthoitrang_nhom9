import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart' as app_notification;
import '../../services/notification_service.dart';
import '../../services/admin_user_service.dart';
import '../../providers/auth_provider.dart';

class SendNotificationsScreen extends StatefulWidget {
  const SendNotificationsScreen({super.key});

  @override
  State<SendNotificationsScreen> createState() =>
      _SendNotificationsScreenState();
}

class _SendNotificationsScreenState extends State<SendNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final AdminUserService _userService = AdminUserService();

  app_notification.NotificationType _selectedType =
      app_notification.NotificationType.system;
  bool _sendEmail = false;
  bool _isLoading = false;
  String _recipientOption = 'all'; // all, custom
  final List<int> _selectedUserIds = [];
  final Map<int, Map<String, String>> _selectedUsers =
      {}; // id -> {name, email}

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get recipient user IDs
      List<int> userIds;
      if (_recipientOption == 'all') {
        // In real app, fetch all user IDs from API
        // For demo, use current user
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        userIds = [authProvider.user!.id];
      } else {
        userIds = _selectedUserIds;
      }

      if (userIds.isEmpty) {
        throw Exception('Vui lòng chọn ít nhất một người nhận');
      }

      final request = app_notification.SendNotificationRequest(
        userIds: userIds,
        title: _titleController.text,
        message: _messageController.text,
        type: _selectedType,
        sendEmail: _sendEmail,
      );

      final result = await _notificationService.sendNotification(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gửi thông báo đến ${result['notificationsCreated']} người dùng',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedType = app_notification.NotificationType.system;
          _sendEmail = false;
          _recipientOption = 'all';
          _selectedUserIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showUserSelectionDialog() async {
    final selectedUsers = Map<int, Map<String, String>>.from(_selectedUsers);
    final selectedIds = List<int>.from(_selectedUserIds);

    await showDialog(
      context: context,
      builder: (context) => _UserSelectionDialog(
        userService: _userService,
        selectedUserIds: selectedIds,
        selectedUsers: selectedUsers,
      ),
    ).then((result) {
      if (result != null && result is Map) {
        setState(() {
          _selectedUserIds.clear();
          _selectedUserIds.addAll(result['ids'] as List<int>);
          _selectedUsers.clear();
          _selectedUsers.addAll(
            result['users'] as Map<int, Map<String, String>>,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gửi Thông Báo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người nhận',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Tất cả người dùng'),
                        value: 'all',
                        groupValue: _recipientOption,
                        onChanged: (value) {
                          setState(() => _recipientOption = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Chọn người dùng cụ thể'),
                        value: 'custom',
                        groupValue: _recipientOption,
                        onChanged: (value) {
                          setState(() => _recipientOption = value!);
                        },
                      ),
                      if (_recipientOption == 'custom') ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _showUserSelectionDialog(),
                          icon: const Icon(Icons.person_add),
                          label: Text(
                            _selectedUserIds.isEmpty
                                ? 'Chọn người dùng'
                                : '${_selectedUserIds.length} người đã chọn',
                          ),
                        ),
                        if (_selectedUsers.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedUsers.entries.map((entry) {
                              return Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    entry.value['name']!
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                label: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.value['name']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      entry.value['email']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedUserIds.remove(entry.key);
                                    _selectedUsers.remove(entry.key);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notification type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loại thông báo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: app_notification.NotificationType.values.map((
                          type,
                        ) {
                          final isSelected = _selectedType == type;
                          return FilterChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(type.icon),
                                const SizedBox(width: 4),
                                Text(type.displayName),
                              ],
                            ),
                            onSelected: (selected) {
                              setState(() => _selectedType = type);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notification content
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nội dung thông báo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề *',
                          hintText: 'Nhập tiêu đề thông báo',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                        maxLength: 255,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung *',
                          hintText: 'Nhập nội dung thông báo',
                          prefixIcon: Icon(Icons.message),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                        maxLines: 5,
                        maxLength: 1000,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tùy chọn',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SwitchListTile(
                        title: const Text('Gửi email thông báo'),
                        subtitle: const Text('Gửi email đến người dùng'),
                        value: _sendEmail,
                        onChanged: (value) {
                          setState(() => _sendEmail = value);
                        },
                        secondary: const Icon(Icons.email),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preview card
              if (_titleController.text.isNotEmpty ||
                  _messageController.text.isNotEmpty)
                Card(
                  elevation: 2,
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.visibility, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Xem trước',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                _selectedType,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _selectedType.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            _titleController.text.isEmpty
                                ? 'Tiêu đề thông báo'
                                : _titleController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _messageController.text.isEmpty
                                    ? 'Nội dung thông báo sẽ hiển thị ở đây'
                                    : _messageController.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 12),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Vừa xong',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(
                                        _selectedType,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _selectedType.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _getTypeColor(_selectedType),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendNotification,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Đang gửi...' : 'Gửi thông báo',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.order:
        return Colors.blue;
      case app_notification.NotificationType.promotion:
        return Colors.red;
      case app_notification.NotificationType.system:
        return Colors.grey;
      case app_notification.NotificationType.review:
        return Colors.orange;
      case app_notification.NotificationType.account:
        return Colors.green;
    }
  }
}

// User Selection Dialog Widget
class _UserSelectionDialog extends StatefulWidget {
  final AdminUserService userService;
  final List<int> selectedUserIds;
  final Map<int, Map<String, String>> selectedUsers;

  const _UserSelectionDialog({
    required this.userService,
    required this.selectedUserIds,
    required this.selectedUsers,
  });

  @override
  State<_UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<_UserSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  late Set<int> _tempSelectedIds;
  late Map<int, Map<String, String>> _tempSelectedUsers;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = Set<int>.from(widget.selectedUserIds);
    _tempSelectedUsers = Map<int, Map<String, String>>.from(
      widget.selectedUsers,
    );
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
      final result = await widget.userService.getUsers(
        search: _searchController.text,
        role: 'user', // Only get regular users, not admins
      );

      if (mounted) {
        setState(() {
          _users = result['users'];
          _filteredUsers = _users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name = (user['full_name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  void _toggleUser(Map<String, dynamic> user) {
    setState(() {
      final userId = user['id'] as int;
      if (_tempSelectedIds.contains(userId)) {
        _tempSelectedIds.remove(userId);
        _tempSelectedUsers.remove(userId);
      } else {
        _tempSelectedIds.add(userId);
        _tempSelectedUsers[userId] = {
          'name': user['full_name']?.toString() ?? 'Unknown',
          'email': user['email']?.toString() ?? '',
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Chọn người nhận',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterUsers,
            ),
            const SizedBox(height: 12),

            // Selected count
            if (_tempSelectedIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã chọn ${_tempSelectedIds.length} người',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempSelectedIds.clear();
                          _tempSelectedUsers.clear();
                        });
                      },
                      child: const Text('Bỏ chọn tất cả'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // User list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUsers,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Không có người dùng nào'
                                : 'Không tìm thấy người dùng',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        final userId = user['id'] as int;
                        final isSelected = _tempSelectedIds.contains(userId);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 3 : 1,
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              child: Text(
                                (user['full_name']?.toString() ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user['full_name']?.toString() ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email']?.toString() ?? ''),
                                if (user['phone'] != null)
                                  Text(
                                    user['phone'].toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleUser(user),
                              activeColor: Colors.blue,
                            ),
                            onTap: () => _toggleUser(user),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _tempSelectedIds.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context, {
                            'ids': _tempSelectedIds.toList(),
                            'users': _tempSelectedUsers,
                          });
                        },
                  icon: const Icon(Icons.check),
                  label: Text('Xác nhận (${_tempSelectedIds.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
