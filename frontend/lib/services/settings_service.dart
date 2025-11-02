import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_setting.dart';
import '../config/app_config.dart';

class SettingsService {
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

  // Get public settings (no authentication required)
  Future<Map<String, dynamic>> getPublicSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/public'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data['data']);
      } else {
        throw Exception('Failed to load public settings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading public settings: $e');
    }
  }

  // Get store information (public)
  Future<StoreSettings> getStoreInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/store-info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StoreSettings.fromMap(data['data']);
      } else {
        throw Exception('Failed to load store info: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading store info: $e');
    }
  }

  // Get all settings (admin only)
  Future<Map<String, dynamic>> getAllSettings({String? category}) async {
    try {
      final headers = await _getHeaders();
      final params = category != null ? {'category': category} : null;

      final uri = Uri.parse(
        '$_baseUrl/settings',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data['data']);
      } else {
        throw Exception('Failed to load settings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading settings: $e');
    }
  }

  // Get settings by category (admin only)
  Future<SettingsGroup> getSettingsByCategory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/by-category'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SettingsGroup.fromJson(data['data']);
      } else {
        throw Exception('Failed to load settings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading settings: $e');
    }
  }

  // Get setting by key (admin only)
  Future<AppSetting> getSettingByKey(String key) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/$key'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppSetting.fromJson(data['data']);
      } else {
        throw Exception('Failed to load setting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading setting: $e');
    }
  }

  // Update setting by key (admin only)
  Future<AppSetting> updateSetting(
    String key,
    dynamic value, {
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      final payload = {
        'value': value,
        if (description != null) 'description': description,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/settings/$key'),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppSetting.fromJson(data['data']);
      } else {
        throw Exception('Failed to update setting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating setting: $e');
    }
  }

  // Update multiple settings (admin only)
  Future<void> updateBulkSettings(List<Map<String, dynamic>> settings) async {
    try {
      final headers = await _getHeaders();
      final body = {'settings': settings};

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/settings'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update settings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating settings: $e');
    }
  }

  // Create new setting (admin only)
  Future<AppSetting> createSetting({
    required String key,
    required dynamic value,
    String? description,
    String category = 'system',
    String dataType = 'string',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'key': key,
        'value': value,
        'description': description,
        'category': category,
        'dataType': dataType,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/settings'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return AppSetting.fromJson(data['data']);
      } else {
        throw Exception('Failed to create setting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating setting: $e');
    }
  }

  // Delete setting (admin only)
  Future<void> deleteSetting(String key) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/settings/$key'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete setting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting setting: $e');
    }
  }

  // Get store settings
  Future<StoreSettings> getStoreSettings() async {
    try {
      final settings = await getAllSettings(category: 'store');
      return StoreSettings.fromMap(settings);
    } catch (e) {
      throw Exception('Error loading store settings: $e');
    }
  }

  // Get payment settings
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      final settings = await getAllSettings(category: 'payment');
      return PaymentSettings.fromMap(settings);
    } catch (e) {
      throw Exception('Error loading payment settings: $e');
    }
  }

  // Get shipping settings
  Future<ShippingSettings> getShippingSettings() async {
    try {
      final settings = await getAllSettings(category: 'shipping');
      return ShippingSettings.fromMap(settings);
    } catch (e) {
      throw Exception('Error loading shipping settings: $e');
    }
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final settings = await getAllSettings(category: 'notification');
      return NotificationSettings.fromMap(settings);
    } catch (e) {
      throw Exception('Error loading notification settings: $e');
    }
  }

  // Update store settings
  Future<void> updateStoreSettings(StoreSettings storeSettings) async {
    try {
      final settingsMap = storeSettings.toMap();
      final settingsList = settingsMap.entries
          .map((entry) => {'key': entry.key, 'value': entry.value})
          .toList();

      await updateBulkSettings(settingsList);
    } catch (e) {
      throw Exception('Error updating store settings: $e');
    }
  }

  // Update payment settings
  Future<void> updatePaymentSettings(PaymentSettings paymentSettings) async {
    try {
      final settingsMap = paymentSettings.toMap();
      final settingsList = settingsMap.entries
          .map((entry) => {'key': entry.key, 'value': entry.value})
          .toList();

      await updateBulkSettings(settingsList);
    } catch (e) {
      throw Exception('Error updating payment settings: $e');
    }
  }

  // Update shipping settings
  Future<void> updateShippingSettings(ShippingSettings shippingSettings) async {
    try {
      final settingsMap = shippingSettings.toMap();
      final settingsList = settingsMap.entries
          .map((entry) => {'key': entry.key, 'value': entry.value})
          .toList();

      await updateBulkSettings(settingsList);
    } catch (e) {
      throw Exception('Error updating shipping settings: $e');
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(
    NotificationSettings notificationSettings,
  ) async {
    try {
      final settingsMap = notificationSettings.toMap();
      final settingsList = settingsMap.entries
          .map((entry) => {'key': entry.key, 'value': entry.value})
          .toList();

      await updateBulkSettings(settingsList);
    } catch (e) {
      throw Exception('Error updating notification settings: $e');
    }
  }
}
