import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Service xử lý Google Sign In cho ứng dụng
///
/// Sử dụng google_sign_in package để xác thực với Google
/// và backend API để lấy JWT token
class GoogleAuthService {
  // Singleton pattern
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // Backend API URL from app config
  final String _baseUrl = AppConfig.baseUrl;

  // Google Sign In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Đăng nhập bằng Google
  ///
  /// Flow:
  /// 1. Mở Google Sign In UI
  /// 2. Người dùng chọn tài khoản Google
  /// 3. Lấy idToken từ Google
  /// 4. Gửi idToken lên backend để verify
  /// 5. Backend trả về JWT token
  /// 6. Lưu token và user data vào SharedPreferences
  ///
  /// Returns: Map với user data và token nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Step 3: Send ID token to backend for verification
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Step 4: Save token and user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['data']['token']);
          await prefs.setString('user', jsonEncode(data['data']['user']));

          return {'user': data['data']['user'], 'token': data['data']['token']};
        } else {
          throw Exception(data['message'] ?? 'Google authentication failed');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Server error');
      }
    } catch (error) {
      print('❌ Google Sign In Error: $error');
      rethrow;
    }
  }

  /// Đăng xuất khỏi Google
  ///
  /// Đăng xuất khỏi Google Sign In và xóa token local
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (error) {
      print('❌ Google Sign Out Error: $error');
      rethrow;
    }
  }

  /// Ngắt kết nối tài khoản Google khỏi backend
  ///
  /// API yêu cầu authentication token
  /// User phải có password đã set, không thể unlink nếu chỉ có Google
  Future<bool> unlinkGoogleAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/google/unlink'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to unlink Google account');
      }
    } catch (error) {
      print('❌ Unlink Google Account Error: $error');
      rethrow;
    }
  }

  /// Kiểm tra xem có đăng nhập Google không
  ///
  /// Returns: true nếu đã đăng nhập Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Lấy current Google user
  ///
  /// Returns: GoogleSignInAccount nếu đã đăng nhập, null nếu chưa
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Silent sign in (không hiển thị UI)
  ///
  /// Tự động đăng nhập nếu user đã đăng nhập trước đó
  /// Returns: GoogleSignInAccount nếu thành công, null nếu thất bại
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      print('❌ Silent Sign In Error: $error');
      return null;
    }
  }

  /// Disconnect Google account (revoke access)
  ///
  /// Ngắt hoàn toàn kết nối với Google, khác với signOut
  /// User sẽ phải authorize lại app lần sau
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print('❌ Google Disconnect Error: $error');
      rethrow;
    }
  }
}
