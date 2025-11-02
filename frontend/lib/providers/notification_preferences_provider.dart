import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  final bool newOrders;
  final bool newReviews;
  final bool newUsers;
  final bool lowStock;
  final bool systemUpdates;

  NotificationPreferences({
    this.newOrders = true,
    this.newReviews = true,
    this.newUsers = false,
    this.lowStock = true,
    this.systemUpdates = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'newOrders': newOrders,
      'newReviews': newReviews,
      'newUsers': newUsers,
      'lowStock': lowStock,
      'systemUpdates': systemUpdates,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      newOrders: json['newOrders'] ?? true,
      newReviews: json['newReviews'] ?? true,
      newUsers: json['newUsers'] ?? false,
      lowStock: json['lowStock'] ?? true,
      systemUpdates: json['systemUpdates'] ?? false,
    );
  }

  NotificationPreferences copyWith({
    bool? newOrders,
    bool? newReviews,
    bool? newUsers,
    bool? lowStock,
    bool? systemUpdates,
  }) {
    return NotificationPreferences(
      newOrders: newOrders ?? this.newOrders,
      newReviews: newReviews ?? this.newReviews,
      newUsers: newUsers ?? this.newUsers,
      lowStock: lowStock ?? this.lowStock,
      systemUpdates: systemUpdates ?? this.systemUpdates,
    );
  }
}

class NotificationPreferencesProvider extends ChangeNotifier {
  static const String _keyPreferences = 'notification_preferences';

  NotificationPreferences _preferences = NotificationPreferences();

  NotificationPreferences get preferences => _preferences;

  bool get newOrders => _preferences.newOrders;
  bool get newReviews => _preferences.newReviews;
  bool get newUsers => _preferences.newUsers;
  bool get lowStock => _preferences.lowStock;
  bool get systemUpdates => _preferences.systemUpdates;

  NotificationPreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyPreferences);

      if (jsonString != null) {
        final Map<String, dynamic> json = {};
        final parts = jsonString.split('|');
        for (var part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            json[keyValue[0]] = keyValue[1] == 'true';
          }
        }
        _preferences = NotificationPreferences.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _preferences.toJson();
      final jsonString = json.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|');
      await prefs.setString(_keyPreferences, jsonString);
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  Future<void> setNewOrders(bool value) async {
    _preferences = _preferences.copyWith(newOrders: value);
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setNewReviews(bool value) async {
    _preferences = _preferences.copyWith(newReviews: value);
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setNewUsers(bool value) async {
    _preferences = _preferences.copyWith(newUsers: value);
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setLowStock(bool value) async {
    _preferences = _preferences.copyWith(lowStock: value);
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setSystemUpdates(bool value) async {
    _preferences = _preferences.copyWith(systemUpdates: value);
    notifyListeners();
    await _savePreferences();
  }

  Future<void> resetToDefaults() async {
    _preferences = NotificationPreferences();
    notifyListeners();
    await _savePreferences();
  }
}
