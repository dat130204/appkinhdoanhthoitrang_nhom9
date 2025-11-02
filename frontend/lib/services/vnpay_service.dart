import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment.dart';
import '../config/app_config.dart';

/// VNPay Service for payment integration
///
/// Handles VNPay payment gateway integration including:
/// - Creating payment URLs
/// - Handling payment callbacks
/// - Querying payment status
/// - Managing bank selection
class VNPayService {
  // Singleton pattern
  static final VNPayService _instance = VNPayService._internal();
  factory VNPayService() => _instance;
  VNPayService._internal();

  // Base URL from app config
  final String _baseUrl = AppConfig.baseUrl;

  /// Get authentication token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Create VNPay payment URL
  ///
  /// @param orderId - Order ID to pay for
  /// @param amount - Payment amount in VND
  /// @param orderInfo - Order description (optional)
  /// @param bankCode - Specific bank code (optional, empty for all banks)
  /// @returns PaymentResponse with payment URL
  Future<PaymentResponse> createPayment({
    required int orderId,
    required double amount,
    String? orderInfo,
    String? bankCode,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final request = PaymentRequest(
        orderId: orderId,
        amount: amount,
        orderInfo: orderInfo ?? 'Thanh toán đơn hàng #$orderId',
        bankCode: bankCode,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/payment/vnpay/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi tạo URL thanh toán');
      }
    } catch (error) {
      print('❌ Create payment error: $error');
      rethrow;
    }
  }

  /// Get list of supported banks from VNPay
  ///
  /// @returns List of BankInfo objects
  Future<List<BankInfo>> getSupportedBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment/vnpay/banks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> banksJson = data['data'];
          return banksJson.map((json) => BankInfo.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy danh sách ngân hàng');
        }
      } else {
        throw Exception('Lỗi kết nối server');
      }
    } catch (error) {
      print('❌ Get banks error: $error');
      // Return default bank list if API fails
      return _getDefaultBanks();
    }
  }

  /// Get default bank list (fallback)
  List<BankInfo> _getDefaultBanks() {
    return [
      BankInfo(code: '', name: 'Cổng thanh toán VNPAYQR', logo: 'vnpayqr'),
      BankInfo(
        code: 'VNBANK',
        name: 'Thẻ ATM/Tài khoản nội địa',
        logo: 'vnbank',
      ),
      BankInfo(
        code: 'INTCARD',
        name: 'Thẻ thanh toán quốc tế',
        logo: 'intcard',
      ),
      BankInfo(code: 'VIETCOMBANK', name: 'Vietcombank', logo: 'vcb'),
      BankInfo(code: 'VIETINBANK', name: 'Vietinbank', logo: 'vtb'),
      BankInfo(code: 'BIDV', name: 'BIDV', logo: 'bidv'),
      BankInfo(code: 'AGRIBANK', name: 'Agribank', logo: 'agribank'),
      BankInfo(code: 'TECHCOMBANK', name: 'Techcombank', logo: 'techcombank'),
      BankInfo(code: 'ACB', name: 'ACB', logo: 'acb'),
      BankInfo(code: 'VPBANK', name: 'VPBank', logo: 'vpbank'),
      BankInfo(code: 'MBBANK', name: 'MBBank', logo: 'mbbank'),
    ];
  }

  /// Handle VNPay payment callback from WebView
  ///
  /// @param params - Query parameters from VNPay return URL
  /// @returns PaymentResult with payment status
  Future<PaymentResult> handlePaymentCallback(
    Map<String, String> params,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/vnpay/callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentResult.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi xử lý callback thanh toán');
      }
    } catch (error) {
      print('❌ Handle callback error: $error');
      rethrow;
    }
  }

  /// Parse VNPay return URL parameters
  ///
  /// @param url - Return URL from VNPay
  /// @returns Map of query parameters
  Map<String, String> parseReturnUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters;
    } catch (error) {
      print('❌ Parse URL error: $error');
      return {};
    }
  }

  /// Get payment status for an order
  ///
  /// @param orderId - Order ID to check status
  /// @returns PaymentStatus object
  Future<PaymentStatus> getPaymentStatus(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/payment/vnpay/status/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PaymentStatus.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi lấy trạng thái thanh toán');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi kết nối server');
      }
    } catch (error) {
      print('❌ Get payment status error: $error');
      rethrow;
    }
  }

  /// Check if URL is VNPay return URL
  ///
  /// @param url - URL to check
  /// @returns true if URL is VNPay return URL
  bool isVNPayReturnUrl(String url) {
    return url.contains('vnp_ResponseCode') &&
        url.contains('vnp_TransactionNo') &&
        url.contains('vnp_TxnRef');
  }

  /// Extract order number from VNPay return URL
  ///
  /// @param url - VNPay return URL
  /// @returns Order number (vnp_TxnRef)
  String? extractOrderNumber(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['vnp_TxnRef'];
    } catch (error) {
      print('❌ Extract order number error: $error');
      return null;
    }
  }

  /// Check if payment was successful from URL
  ///
  /// @param url - VNPay return URL
  /// @returns true if payment successful (responseCode = 00)
  bool isPaymentSuccessFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      return responseCode == '00';
    } catch (error) {
      print('❌ Check payment success error: $error');
      return false;
    }
  }

  /// Get response message from VNPay response code
  ///
  /// @param responseCode - VNPay response code
  /// @returns Vietnamese message
  String getResponseMessage(String responseCode) {
    final messages = {
      '00': 'Giao dịch thành công',
      '07': 'Trừ tiền thành công. Giao dịch bị nghi ngờ',
      '09': 'Thẻ/Tài khoản chưa đăng ký InternetBanking',
      '10': 'Xác thực thông tin không đúng quá 3 lần',
      '11': 'Đã hết hạn chờ thanh toán',
      '12': 'Thẻ/Tài khoản bị khóa',
      '13': 'Nhập sai mật khẩu OTP',
      '24': 'Khách hàng hủy giao dịch',
      '51': 'Tài khoản không đủ số dư',
      '65': 'Vượt quá giới hạn giao dịch trong ngày',
      '75': 'Ngân hàng thanh toán đang bảo trì',
      '79': 'Nhập sai mật khẩu quá số lần quy định',
      '99': 'Lỗi không xác định',
    };

    return messages[responseCode] ?? 'Lỗi không xác định';
  }
}
