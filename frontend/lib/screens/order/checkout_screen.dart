import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cod';

  final List<String> _cities = [
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Hải Phòng',
    'Cần Thơ',
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cao Bằng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Tĩnh',
    'Hải Dương',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with user info if available
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.fullName;
      _phoneController.text = authProvider.user!.phone ?? '';
      _emailController.text = authProvider.user!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer2<CartProvider, OrderProvider>(
        builder: (context, cartProvider, orderProvider, child) {
          final cart = cartProvider.cart;
          final cartItems = cart?.items ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.emptyCartMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    ),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ],
              ),
            );
          }

          final orderSummary = orderProvider.calculateOrderSummary(cartItems);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerInfo(),
                        _buildShippingInfo(),
                        _buildPaymentMethod(),
                        _buildNotes(),
                        _buildOrderSummary(cartItems, orderSummary),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(
                context,
                orderProvider,
                cartProvider,
                orderSummary,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: Validators.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại *',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                return Validators.validateEmail(value);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Địa chỉ giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tỉnh/Thành phố *',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
            value: _cityController.text.isEmpty ? null : _cityController.text,
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _cityController.text = value ?? '';
              });
            },
            validator: Validators.validateCity,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _districtController,
            decoration: const InputDecoration(
              labelText: 'Quận/Huyện',
              prefixIcon: Icon(Icons.map_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _wardController,
            decoration: const InputDecoration(
              labelText: 'Phường/Xã',
              prefixIcon: Icon(Icons.signpost_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ cụ thể *',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
              hintText: 'Số nhà, tên đường...',
            ),
            maxLines: 2,
            validator: Validators.validateAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Thanh toán khi nhận hàng (COD)'),
              ],
            ),
            value: 'cod',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.account_balance, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Chuyển khoản ngân hàng'),
              ],
            ),
            value: 'bank_transfer',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.phone_android, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Ví MoMo'),
              ],
            ),
            value: 'momo',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.credit_card, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('VNPay'),
              ],
            ),
            value: 'vnpay',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi chú đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Thêm ghi chú cho đơn hàng (không bắt buộc)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(List cartItems, Map<String, dynamic> orderSummary) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính (${cartItems.length} sản phẩm):',
                style: const TextStyle(fontSize: 15),
              ),
              Text(
                AppConstants.formatCurrency(orderSummary['subtotal']),
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phí vận chuyển:', style: TextStyle(fontSize: 15)),
              Text(
                orderSummary['shippingFee'] == 0
                    ? 'Miễn phí'
                    : AppConstants.formatCurrency(orderSummary['shippingFee']),
                style: TextStyle(
                  fontSize: 15,
                  color: orderSummary['shippingFee'] == 0
                      ? AppColors.success
                      : AppColors.textPrimary,
                  fontWeight: orderSummary['shippingFee'] == 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (orderSummary['discount'] > 0) const SizedBox(height: 8),
          if (orderSummary['discount'] > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giảm giá:', style: TextStyle(fontSize: 15)),
                Text(
                  '-${AppConstants.formatCurrency(orderSummary['discount'])}',
                  style: const TextStyle(fontSize: 15, color: AppColors.error),
                ),
              ],
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                AppConstants.formatCurrency(orderSummary['total']),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (orderSummary['shippingFee'] > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Miễn phí vận chuyển cho đơn hàng từ ${AppConstants.formatCurrency(500000)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    OrderProvider orderProvider,
    CartProvider cartProvider,
    Map<String, dynamic> orderSummary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: 'Đặt hàng',
          isLoading: orderProvider.isPlacingOrder,
          onPressed: () => _placeOrder(context, orderProvider, cartProvider),
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    OrderProvider orderProvider,
    CartProvider cartProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Set order info
    orderProvider.setCustomerInfo(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
    );

    orderProvider.setShippingInfo(
      address: _addressController.text,
      city: _cityController.text,
      district: _districtController.text.isEmpty
          ? null
          : _districtController.text,
      ward: _wardController.text.isEmpty ? null : _wardController.text,
    );

    orderProvider.setPaymentMethod(_selectedPaymentMethod);
    orderProvider.setNotes(
      _notesController.text.isEmpty ? null : _notesController.text,
    );

    // Place order
    final cartItems = cartProvider.cart?.items ?? [];
    final success = await orderProvider.placeOrder(cartItems);

    if (!context.mounted) return;

    if (success) {
      // Get the newly created order
      final newOrder = orderProvider.orders.isNotEmpty
          ? orderProvider.orders.first
          : null;

      if (newOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo đơn hàng'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Clear cart
      await cartProvider.clearCart();

      // Navigate to payment method selection
      Navigator.pushNamed(
        context,
        '/payment/method',
        arguments: {
          'orderId': newOrder.id,
          'totalAmount': newOrder.totalAmount,
          'orderNumber': newOrder.orderNumber,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Đặt hàng thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
