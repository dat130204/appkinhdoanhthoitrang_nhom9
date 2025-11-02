import '../models/user.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _api.post('/auth/register', {
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
      }, includeAuth: false);

      if (response['success']) {
        final token = response['data']['token'];
        final user = User.fromJson(response['data']['user']);

        await _api.saveToken(token);
        await _saveUser(user);

        return response;
      }

      throw ApiException(message: response['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (response['success']) {
        final token = response['data']['token'];
        final user = User.fromJson(response['data']['user']);

        await _api.saveToken(token);
        await _saveUser(user);

        return response;
      }

      throw ApiException(message: response['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getProfile() async {
    try {
      final response = await _api.get('/auth/profile');

      if (response['success']) {
        final user = User.fromJson(response['data']);
        await _saveUser(user);
        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      final response = await _api.put('/auth/profile', data);

      if (response['success']) {
        final user = User.fromJson(response['data']);
        await _saveUser(user);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.put('/auth/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConfig.userKey);

      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userKey, json.encode(user.toJson()));
  }
}
