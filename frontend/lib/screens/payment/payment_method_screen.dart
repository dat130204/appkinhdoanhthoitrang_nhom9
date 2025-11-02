import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/vnpay_service.dart';
import '../../config/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Payment Method Selection Screen
///
/// Allows user to choose between COD and VNPay payment methods
/// For VNPay, user can select specific bank (optional)
class PaymentMethodScreen extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final String orderNumber;

  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.orderNumber,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final VNPayService _vnpayService = VNPayService();

  PaymentMethod _selectedMethod = PaymentMethod.cod;
  BankInfo? _selectedBank;
  List<BankInfo> _banks = [];
  bool _isLoadingBanks = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    setState(() => _isLoadingBanks = true);
    try {
      final banks = await _vnpayService.getSupportedBanks();
      setState(() {
        _banks = banks;
        _isLoadingBanks = false;
      });
    } catch (e) {
      setState(() => _isLoadingBanks = false);
      print('Load banks error: $e');
    }
  }

  Future<void> _handleConfirmPayment() async {
    if (_selectedMethod == PaymentMethod.cod) {
      // COD - Navigate directly to success result screen
      Navigator.pushReplacementNamed(
        context,
        '/payment/result',
        arguments: {
          'success': true,
          'result': null,
          'orderId': widget.orderId,
          'orderNumber': widget.orderNumber,
          'errorMessage': null,
        },
      );
      return;
    }

    // VNPay payment
    setState(() => _isProcessing = true);

    try {
      final response = await _vnpayService.createPayment(
        orderId: widget.orderId,
        amount: widget.totalAmount,
        orderInfo: 'Thanh toán đơn hàng ${widget.orderNumber}',
        bankCode: _selectedBank?.code,
      );

      if (response.success && response.paymentUrl != null) {
        if (mounted) {
          // Navigate to WebView screen
          Navigator.pushReplacementNamed(
            context,
            '/payment/vnpay-webview',
            arguments: {
              'paymentUrl': response.paymentUrl!,
              'orderId': widget.orderId,
              'orderNumber': widget.orderNumber,
            },
          );
        }
      } else {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Không thể tạo URL thanh toán',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }

      Fluttertoast.showToast(
        msg: 'Lỗi: ${e.toString()}',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn phương thức thanh toán'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin đơn hàng',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mã đơn hàng:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                widget.orderNumber,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng tiền:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${widget.totalAmount.toStringAsFixed(0)}₫',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Phương thức thanh toán',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // COD Option
                  _buildPaymentMethodCard(
                    method: PaymentMethod.cod,
                    icon: Icons.local_shipping_outlined,
                    subtitle: 'Thanh toán khi nhận hàng',
                  ),

                  const SizedBox(height: 12),

                  // VNPay Option
                  _buildPaymentMethodCard(
                    method: PaymentMethod.vnpay,
                    icon: Icons.credit_card,
                    subtitle: 'Thanh toán qua VNPay',
                  ),

                  // Bank Selection (only show if VNPay selected)
                  if (_selectedMethod == PaymentMethod.vnpay) ...[
                    const SizedBox(height: 24),

                    Text(
                      'Chọn ngân hàng (tùy chọn)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Bỏ qua để hiển thị tất cả phương thức thanh toán',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_isLoadingBanks)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildBankGrid(),
                  ],
                ],
              ),
            ),
          ),

          // Confirm Button
          Container(
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
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirmPayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _selectedMethod == PaymentMethod.cod
                              ? 'Xác nhận đặt hàng'
                              : 'Tiếp tục thanh toán',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == method;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                  }
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _banks.length,
      itemBuilder: (context, index) {
        final bank = _banks[index];
        final isSelected = _selectedBank?.code == bank.code;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedBank = isSelected ? null : bank;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  size: 32,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  bank.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
