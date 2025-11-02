import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../config/app_colors.dart';

/// Payment Result Screen
///
/// Displays payment success or failure result
/// Shows order details, transaction info
/// Provides navigation to home or order details
class PaymentResultScreen extends StatefulWidget {
  final bool success;
  final PaymentResult? result;
  final int? orderId;
  final String? orderNumber;
  final String? errorMessage;

  const PaymentResultScreen({
    super.key,
    required this.success,
    this.result,
    this.orderId,
    this.orderNumber,
    this.errorMessage,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button, must use navigation buttons
        return false;
      },
      child: Scaffold(
        backgroundColor: widget.success
            ? Colors.green.shade50
            : Colors.red.shade50,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Animated Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: widget.success
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.success ? Icons.check_circle : Icons.cancel,
                            size: 80,
                            color: widget.success
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          widget.success
                              ? 'Thanh toán thành công!'
                              : 'Thanh toán thất bại',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.success
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Message
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          widget.success
                              ? 'Đơn hàng của bạn đã được thanh toán và xác nhận thành công'
                              : widget.errorMessage ??
                                    widget.result?.responseMessage ??
                                    'Có lỗi xảy ra trong quá trình thanh toán',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Order Details Card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chi tiết đơn hàng',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                // Order Number
                                _buildInfoRow(
                                  context,
                                  'Mã đơn hàng',
                                  widget.orderNumber ??
                                      widget.result?.orderNumber ??
                                      'N/A',
                                  icon: Icons.receipt_long,
                                ),

                                const Divider(height: 24),

                                // Amount
                                if (widget.result?.amount != null)
                                  _buildInfoRow(
                                    context,
                                    'Số tiền',
                                    '${widget.result!.amount!.toStringAsFixed(0)}₫',
                                    icon: Icons.payments,
                                    valueColor: AppColors.primary,
                                  ),

                                if (widget.result?.amount != null)
                                  const Divider(height: 24),

                                // Transaction ID (if success)
                                if (widget.success &&
                                    widget.result?.transactionNo != null)
                                  _buildInfoRow(
                                    context,
                                    'Mã giao dịch',
                                    widget.result!.transactionNo!,
                                    icon: Icons.tag,
                                  ),

                                if (widget.success &&
                                    widget.result?.transactionNo != null)
                                  const Divider(height: 24),

                                // Payment Status
                                _buildInfoRow(
                                  context,
                                  'Trạng thái',
                                  widget.success ? 'Đã thanh toán' : 'Thất bại',
                                  icon: Icons.info_outline,
                                  valueColor: widget.success
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),

                                // Payment Date (if success)
                                if (widget.success &&
                                    widget.result?.paymentDate != null)
                                  Column(
                                    children: [
                                      const Divider(height: 24),
                                      _buildInfoRow(
                                        context,
                                        'Thời gian',
                                        _formatDate(
                                          widget.result!.paymentDate!,
                                        ),
                                        icon: Icons.access_time,
                                      ),
                                    ],
                                  ),

                                // Response Code (if failed)
                                if (!widget.success &&
                                    widget.result?.responseCode != null)
                                  Column(
                                    children: [
                                      const Divider(height: 24),
                                      _buildInfoRow(
                                        context,
                                        'Mã lỗi',
                                        widget.result!.responseCode!,
                                        icon: Icons.error_outline,
                                        valueColor: Colors.red.shade700,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Additional Info Card (Success)
                      if (widget.success)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Bạn có thể theo dõi đơn hàng trong mục "Đơn hàng của tôi"',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.blue.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Retry Info (Failed)
                      if (!widget.success)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Vui lòng kiểm tra lại thông tin thanh toán và thử lại sau',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.orange.shade900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.success) {
                              // Navigate to order history
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/order_history',
                                (route) => route.isFirst,
                              );
                            } else {
                              // Navigate to home
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/main',
                                (route) => false,
                              );
                            }
                          },
                          icon: Icon(
                            widget.success ? Icons.receipt_long : Icons.home,
                          ),
                          label: Text(
                            widget.success ? 'Xem đơn hàng' : 'Về trang chủ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Secondary Action
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to home
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/main',
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home_outlined),
                          label: const Text(
                            'Về trang chủ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
