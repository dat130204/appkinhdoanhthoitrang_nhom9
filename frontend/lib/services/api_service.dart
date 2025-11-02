import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
    if (_token != null) {
      print(
        '📥 Token loaded: ${_token!.substring(0, 20)}... (${_token!.length} chars)',
      );
    } else {
      print('📥 No token found in storage');
    }
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
    print(
      '💾 Token saved: ${token.substring(0, 20)}... (${token.length} chars)',
    );
    print('💾 Token key: ${AppConfig.tokenKey}');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        message: body['message'] ?? 'Đã xảy ra lỗi',
        statusCode: response.statusCode,
      );
    }
  }

  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    try {
      await loadToken();

      var uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http
          .get(uri, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(const Duration(milliseconds: AppConfig.connectTimeout));

      return await _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Lỗi kết nối: ${e.toString()}');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      await loadToken();

      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

      final response = await http
          .post(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
            body: json.encode(data),
          )
          .timeout(const Duration(milliseconds: AppConfig.connectTimeout));

      return await _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Lỗi kết nối: ${e.toString()}');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      await loadToken();

      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
            body: json.encode(data),
          )
          .timeout(const Duration(milliseconds: AppConfig.connectTimeout));

      return await _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Lỗi kết nối: ${e.toString()}');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      await loadToken();

      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

      final response = await http
          .delete(uri, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(const Duration(milliseconds: AppConfig.connectTimeout));

      return await _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Lỗi kết nối: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
