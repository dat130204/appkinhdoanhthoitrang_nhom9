import '../models/order.dart';
import '../models/cart.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _api = ApiService();

  Future<Order?> createOrder({
    required List<CartItem> items,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String shippingAddress,
    required String shippingCity,
    String? shippingDistrict,
    String? shippingWard,
    String? notes,
    String paymentMethod = 'cod',
  }) async {
    try {
      final itemsData = items
          .map(
            (item) => {
              'product_id': item.productId,
              if (item.variantId != null) 'variant_id': item.variantId,
              'product_name': item.productName,
              if (item.variantInfo != null) 'variant_info': item.variantInfo,
              'quantity': item.quantity,
              'price': item.price,
            },
          )
          .toList();

      final response = await _api.post('/orders', {
        'items': itemsData,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        if (customerEmail != null) 'customer_email': customerEmail,
        'shipping_address': shippingAddress,
        'shipping_city': shippingCity,
        if (shippingDistrict != null) 'shipping_district': shippingDistrict,
        if (shippingWard != null) 'shipping_ward': shippingWard,
        if (notes != null) 'notes': notes,
        'payment_method': paymentMethod,
      });

      if (response['success']) {
        return Order.fromJson(response['data']['order']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Order>> getMyOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _api.get(
        '/orders/my-orders',
        queryParameters: queryParams,
      );

      if (response['success']) {
        final List<dynamic> ordersData = response['data']['orders'];
        return ordersData.map((json) => Order.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Order?> getOrderDetail(int orderId) async {
    try {
      final response = await _api.get('/orders/$orderId');

      if (response['success']) {
        final orderData = response['data']['order'];
        final itemsData = response['data']['items'] as List<dynamic>;

        final order = Order.fromJson(orderData);
        final items = itemsData
            .map((json) => OrderItem.fromJson(json))
            .toList();

        return Order(
          id: order.id,
          userId: order.userId,
          orderNumber: order.orderNumber,
          status: order.status,
          paymentMethod: order.paymentMethod,
          paymentStatus: order.paymentStatus,
          subtotal: order.subtotal,
          shippingFee: order.shippingFee,
          discountAmount: order.discountAmount,
          totalAmount: order.totalAmount,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          customerEmail: order.customerEmail,
          shippingAddress: order.shippingAddress,
          shippingCity: order.shippingCity,
          shippingDistrict: order.shippingDistrict,
          shippingWard: order.shippingWard,
          notes: order.notes,
          cancelledReason: order.cancelledReason,
          cancelledAt: order.cancelledAt,
          confirmedAt: order.confirmedAt,
          shippedAt: order.shippedAt,
          deliveredAt: order.deliveredAt,
          createdAt: order.createdAt,
          itemCount: order.itemCount,
          items: items,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _api.put('/orders/$orderId/cancel', {
        if (reason != null) 'reason': reason,
      });

      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
