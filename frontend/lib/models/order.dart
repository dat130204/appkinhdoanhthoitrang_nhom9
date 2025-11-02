class Order {
  final int id;
  final int userId;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String shippingAddress;
  final String? shippingCity;
  final String? shippingDistrict;
  final String? shippingWard;
  final String? notes;
  final String? cancelledReason;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final int? itemCount;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.shippingAddress,
    this.shippingCity,
    this.shippingDistrict,
    this.shippingWard,
    this.notes,
    this.cancelledReason,
    this.cancelledAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    required this.createdAt,
    this.itemCount,
    this.items,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? itemsList;
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'],
      userId: json['user_id'],
      orderNumber: json['order_number'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      subtotal: _parseDouble(json['subtotal']),
      shippingFee: _parseDouble(json['shipping_fee']),
      discountAmount: _parseDouble(json['discount_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      shippingAddress: json['shipping_address'],
      shippingCity: json['shipping_city'],
      shippingDistrict: json['shipping_district'],
      shippingWard: json['shipping_ward'],
      notes: json['notes'],
      cancelledReason: json['cancelled_reason'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'])
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      itemCount: json['item_count'],
      items: itemsList,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'vnpay':
        return 'VNPay';
      default:
        return paymentMethod;
    }
  }

  bool get canCancel => status == 'pending' || status == 'confirmed';
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int? variantId;
  final String productName;
  final String? variantInfo;
  final int quantity;
  final double price;
  final double subtotal;
  final String? productImage;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.variantId,
    required this.productName,
    this.variantInfo,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.productImage,
    required this.createdAt,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      productName: json['product_name'],
      variantInfo: json['variant_info'],
      quantity: json['quantity'],
      price: _parseDouble(json['price']),
      subtotal: _parseDouble(json['subtotal']),
      productImage: json['product_image'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
