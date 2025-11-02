/// Payment Method Enum
enum PaymentMethod {
  cod('COD', 'Thanh toán khi nhận hàng', 'assets/icons/cod.png'),
  vnpay('VNPay', 'Thanh toán VNPay', 'assets/icons/vnpay.png');

  final String code;
  final String displayName;
  final String icon;

  const PaymentMethod(this.code, this.displayName, this.icon);

  static PaymentMethod fromCode(String code) {
    return PaymentMethod.values.firstWhere(
      (method) => method.code == code,
      orElse: () => PaymentMethod.cod,
    );
  }
}

/// Bank Information Model
class BankInfo {
  final String code;
  final String name;
  final String logo;

  BankInfo({required this.code, required this.name, required this.logo});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'logo': logo};
  }

  /// Get icon asset path based on logo code
  String get iconPath {
    // Map logo code to asset path
    final iconMap = {
      'vnpayqr': 'assets/icons/banks/vnpayqr.png',
      'vnbank': 'assets/icons/banks/vnbank.png',
      'intcard': 'assets/icons/banks/intcard.png',
      'vcb': 'assets/icons/banks/vietcombank.png',
      'vtb': 'assets/icons/banks/vietinbank.png',
      'bidv': 'assets/icons/banks/bidv.png',
      'agribank': 'assets/icons/banks/agribank.png',
      'sacombank': 'assets/icons/banks/sacombank.png',
      'techcombank': 'assets/icons/banks/techcombank.png',
      'acb': 'assets/icons/banks/acb.png',
      'vpbank': 'assets/icons/banks/vpbank.png',
      'tpbank': 'assets/icons/banks/tpbank.png',
      'mbbank': 'assets/icons/banks/mbbank.png',
      'scb': 'assets/icons/banks/scb.png',
    };

    return iconMap[logo.toLowerCase()] ?? 'assets/icons/banks/default.png';
  }
}

/// Payment Result Model
class PaymentResult {
  final bool success;
  final String message;
  final int? orderId;
  final String? orderNumber;
  final double? amount;
  final String? transactionNo;
  final String? responseCode;
  final String? responseMessage;
  final String? paymentStatus;
  final DateTime? paymentDate;

  PaymentResult({
    required this.success,
    required this.message,
    this.orderId,
    this.orderNumber,
    this.amount,
    this.transactionNo,
    this.responseCode,
    this.responseMessage,
    this.paymentStatus,
    this.paymentDate,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      orderId: json['data']?['orderId'],
      orderNumber: json['data']?['orderNumber'],
      amount: json['data']?['amount']?.toDouble(),
      transactionNo: json['data']?['transactionNo'],
      responseCode: json['data']?['responseCode'],
      responseMessage: json['data']?['responseMessage'],
      paymentStatus: json['data']?['paymentStatus'],
      paymentDate: json['data']?['paymentDate'] != null
          ? DateTime.parse(json['data']['paymentDate'])
          : null,
    );
  }

  /// Check if payment was successful
  bool get isSuccess => success && paymentStatus == 'paid';

  /// Get status icon based on payment result
  String get statusIcon {
    if (isSuccess) {
      return '✅';
    } else if (paymentStatus == 'failed') {
      return '❌';
    } else {
      return '⏳';
    }
  }

  /// Get status color
  String get statusColor {
    if (isSuccess) {
      return 'success';
    } else if (paymentStatus == 'failed') {
      return 'error';
    } else {
      return 'warning';
    }
  }
}

/// Payment Request Model
class PaymentRequest {
  final int orderId;
  final double amount;
  final String orderInfo;
  final String? bankCode;

  PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.orderInfo,
    this.bankCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'orderInfo': orderInfo,
      if (bankCode != null && bankCode!.isNotEmpty) 'bankCode': bankCode,
    };
  }
}

/// Payment Response Model (URL response)
class PaymentResponse {
  final bool success;
  final String message;
  final String? paymentUrl;
  final int? orderId;
  final String? orderNumber;
  final double? amount;

  PaymentResponse({
    required this.success,
    required this.message,
    this.paymentUrl,
    this.orderId,
    this.orderNumber,
    this.amount,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentUrl: json['data']?['paymentUrl'],
      orderId: json['data']?['orderId'],
      orderNumber: json['data']?['orderNumber'],
      amount: json['data']?['amount']?.toDouble(),
    );
  }
}

/// Payment Status Model
class PaymentStatus {
  final int orderId;
  final String orderNumber;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final DateTime? paymentDate;
  final double amount;

  PaymentStatus({
    required this.orderId,
    required this.orderNumber,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.paymentDate,
    required this.amount,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      transactionId: json['transactionId'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  /// Check if payment is completed
  bool get isPaid => paymentStatus == 'paid';

  /// Check if payment is pending
  bool get isPending => paymentStatus == 'pending';

  /// Check if payment failed
  bool get isFailed => paymentStatus == 'failed';

  /// Get status display text
  String get statusDisplayText {
    switch (paymentStatus) {
      case 'paid':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
