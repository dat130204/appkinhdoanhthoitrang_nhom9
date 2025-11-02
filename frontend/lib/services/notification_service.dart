import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../config/app_config.dart';

class NotificationService {
  final String _baseUrl = AppConfig.baseUrl;

  // Get JWT token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get user notifications
  Future<NotificationListResponse> getUserNotifications({
    bool? isRead,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (isRead != null) {
        params['isRead'] = isRead.toString();
      }

      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }

      final uri = Uri.parse(
        '$_baseUrl/notifications',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationListResponse.fromJson(data['data']);
      } else {
        throw Exception('Failed to load notifications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['unreadCount'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking as read: $e');
    }
  }

  // Mark all notifications as read
  Future<int> markAllAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/mark-all-read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['markedCount'] ?? 0;
      } else {
        throw Exception('Failed to mark all as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // Delete all read notifications
  Future<int> deleteAllRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/read/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['deletedCount'] ?? 0;
      } else {
        throw Exception(
          'Failed to delete read notifications: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting read notifications: $e');
    }
  }

  // Admin: Send notification
  Future<Map<String, dynamic>> sendNotification(
    SendNotificationRequest request,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/notifications/send'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  // Admin: Get notification statistics
  Future<List<NotificationStatistics>> getStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/notifications/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stats = data['data'];
        return stats
            .map((stat) => NotificationStatistics.fromJson(stat))
            .toList();
      } else {
        throw Exception('Failed to get statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting statistics: $e');
    }
  }

  // Admin: Clean old notifications
  Future<int> cleanOldNotifications({int daysOld = 90}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/notifications/clean?daysOld=$daysOld'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['deletedCount'] ?? 0;
      } else {
        throw Exception('Failed to clean notifications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error cleaning notifications: $e');
    }
  }
}
