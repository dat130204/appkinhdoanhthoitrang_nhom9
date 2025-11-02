import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  Order? _selectedOrder;

  bool _isLoading = false;
  bool _isPlacingOrder = false;
  String? _error;

  // Order placement data
  String? _customerName;
  String? _customerPhone;
  String? _customerEmail;
  String? _shippingAddress;
  String? _shippingCity;
  String? _shippingDistrict;
  String? _shippingWard;
  String? _paymentMethod;
  String? _notes;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;
  String? get customerEmail => _customerEmail;
  String? get shippingAddress => _shippingAddress;
  String? get shippingCity => _shippingCity;
  String? get shippingDistrict => _shippingDistrict;
  String? get shippingWard => _shippingWard;
  String? get paymentMethod => _paymentMethod;
  String? get notes => _notes;

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get pending orders
  List<Order> get pendingOrders =>
      _orders.where((order) => order.status == 'pending').toList();

  // Get processing orders
  List<Order> get processingOrders => _orders
      .where(
        (order) => order.status == 'confirmed' || order.status == 'processing',
      )
      .toList();

  // Get shipping orders
  List<Order> get shippingOrders =>
      _orders.where((order) => order.status == 'shipping').toList();

  // Get delivered orders
  List<Order> get deliveredOrders =>
      _orders.where((order) => order.status == 'delivered').toList();

  // Get cancelled orders
  List<Order> get cancelledOrders =>
      _orders.where((order) => order.status == 'cancelled').toList();

  // Fetch all orders
  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getMyOrders(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch order by ID
  Future<void> fetchOrderById(int id) async {
    _isLoading = true;
    _error = null;
    _selectedOrder = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set customer info
  void setCustomerInfo({
    required String name,
    required String phone,
    String? email,
  }) {
    _customerName = name;
    _customerPhone = phone;
    _customerEmail = email;
    notifyListeners();
  }

  // Set shipping info
  void setShippingInfo({
    required String address,
    required String city,
    String? district,
    String? ward,
  }) {
    _shippingAddress = address;
    _shippingCity = city;
    _shippingDistrict = district;
    _shippingWard = ward;
    notifyListeners();
  }

  // Set payment method
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // Set order notes
  void setNotes(String? orderNotes) {
    _notes = orderNotes;
    notifyListeners();
  }

  // Validate checkout data
  bool validateCheckoutData() {
    if (_customerName == null || _customerName!.isEmpty) {
      _error = 'Vui lòng nhập tên khách hàng';
      notifyListeners();
      return false;
    }

    if (_customerPhone == null || _customerPhone!.isEmpty) {
      _error = 'Vui lòng nhập số điện thoại';
      notifyListeners();
      return false;
    }

    if (_shippingAddress == null || _shippingAddress!.isEmpty) {
      _error = 'Vui lòng nhập địa chỉ giao hàng';
      notifyListeners();
      return false;
    }

    if (_shippingCity == null || _shippingCity!.isEmpty) {
      _error = 'Vui lòng chọn tỉnh/thành phố';
      notifyListeners();
      return false;
    }

    if (_paymentMethod == null || _paymentMethod!.isEmpty) {
      _error = 'Vui lòng chọn phương thức thanh toán';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Place order from cart
  Future<bool> placeOrder(List<CartItem> cartItems) async {
    if (!validateCheckoutData()) {
      return false;
    }

    _isPlacingOrder = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        items: cartItems,
        customerName: _customerName!,
        customerPhone: _customerPhone!,
        customerEmail: _customerEmail,
        shippingAddress: _shippingAddress!,
        shippingCity: _shippingCity!,
        shippingDistrict: _shippingDistrict,
        shippingWard: _shippingWard,
        notes: _notes,
        paymentMethod: _paymentMethod ?? 'cod',
      );

      if (order != null) {
        // Add to local orders list
        _orders.insert(0, order);

        // Clear checkout data
        clearCheckoutData();

        _isPlacingOrder = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Không thể đặt hàng. Vui lòng thử lại.';
        _isPlacingOrder = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isPlacingOrder = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _orderService.cancelOrder(orderId, reason: reason);

      if (success) {
        // Refresh orders from server to get updated status
        await fetchOrders();

        // Update selected order if it's the one being cancelled
        if (_selectedOrder?.id == orderId) {
          await fetchOrderById(orderId);
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Calculate order summary
  Map<String, dynamic> calculateOrderSummary(List<CartItem> cartItems) {
    double subtotal = 0;
    for (var item in cartItems) {
      subtotal += item.price * item.quantity;
    }

    // Shipping fee calculation (simple logic)
    double shippingFee = subtotal >= 500000 ? 0 : 30000;

    // Discount calculation (can be extended)
    double discount = 0;

    double total = subtotal + shippingFee - discount;

    return {
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'total': total,
    };
  }

  // Clear checkout data
  void clearCheckoutData() {
    _customerName = null;
    _customerPhone = null;
    _customerEmail = null;
    _shippingAddress = null;
    _shippingCity = null;
    _shippingDistrict = null;
    _shippingWard = null;
    _paymentMethod = null;
    _notes = null;
    notifyListeners();
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get order status display text
  String getOrderStatusText(String status) {
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
      default:
        return 'Không xác định';
    }
  }

  // Get payment method display text
  String getPaymentMethodText(String method) {
    switch (method) {
      case 'cod':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'vnpay':
        return 'VNPay';
      default:
        return 'Khác';
    }
  }

  // Get payment status display text
  String getPaymentStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
  }
}
