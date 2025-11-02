import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminHelpers {
  // Number formatters
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(number);
  }

  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Date formatters
  static String formatDate(DateTime date, {bool showTime = false}) {
    if (showTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  static String formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('dd/MM').format(start);
    final endStr = DateFormat('dd/MM/yyyy').format(end);
    return '$startStr - $endStr';
  }

  // Date range picker
  static Future<DateTimeRange?> showDateRangePicker(
    BuildContext context,
  ) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    return await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => _DateRangePickerDialog(
        firstDate: firstDate,
        lastDate: lastDate,
        initialDateRange: DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
      ),
    );
  }

  // Permission checker
  static bool hasPermission(String? userRole, String requiredRole) {
    if (userRole == null) return false;

    const roleHierarchy = {'admin': 3, 'manager': 2, 'user': 1};

    final userLevel = roleHierarchy[userRole.toLowerCase()] ?? 0;
    final requiredLevel = roleHierarchy[requiredRole.toLowerCase()] ?? 0;

    return userLevel >= requiredLevel;
  }

  static bool isAdmin(String? userRole) {
    return userRole?.toLowerCase() == 'admin';
  }

  // Export functions
  static String generateCSV(
    List<Map<String, dynamic>> data,
    List<String> headers,
  ) {
    if (data.isEmpty) return '';

    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(headers.join(','));

    // Add data rows
    for (var row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // Escape commas and quotes
        if (value.contains(',') || value.contains('"')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).toList();
      buffer.writeln(values.join(','));
    }

    return buffer.toString();
  }

  static Future<void> downloadCSV(
    BuildContext context,
    List<Map<String, dynamic>> data,
    List<String> headers,
    String filename,
  ) async {
    try {
      generateCSV(data, headers);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất ${data.length} bản ghi'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Color helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'completed':
      case 'delivered':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'inactive':
      case 'rejected':
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'shipping':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static Color getRandomColor(int seed) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[seed % colors.length];
  }

  // Validation helpers
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại phải có 10 chữ số';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // Confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDangerous ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Percentage calculation
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100 : 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange initialDateRange;

  const _DateRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    required this.initialDateRange,
  });

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn khoảng thời gian'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Từ ngày'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(_selectedRange.start),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedRange.start,
                firstDate: widget.firstDate,
                lastDate: _selectedRange.end,
              );
              if (date != null) {
                setState(() {
                  _selectedRange = DateTimeRange(
                    start: date,
                    end: _selectedRange.end,
                  );
                });
              }
            },
          ),
          ListTile(
            title: const Text('Đến ngày'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedRange.end)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedRange.end,
                firstDate: _selectedRange.start,
                lastDate: widget.lastDate,
              );
              if (date != null) {
                setState(() {
                  _selectedRange = DateTimeRange(
                    start: _selectedRange.start,
                    end: date,
                  );
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedRange),
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
