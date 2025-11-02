import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/vnpay_service.dart';
import '../../config/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// VNPay WebView Screen
///
/// Displays VNPay payment page in WebView
/// Monitors URL changes to detect payment completion
/// Handles payment callback and navigates to result screen
class VNPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final String orderNumber;

  const VNPayWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<VNPayWebViewScreen> createState() => _VNPayWebViewScreenState();
}

class _VNPayWebViewScreenState extends State<VNPayWebViewScreen> {
  final VNPayService _vnpayService = VNPayService();
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _isProcessingCallback = false;
  int _loadingProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if this is VNPay return URL
            _checkForReturnUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Lỗi tải trang: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Monitor all navigation requests
            _checkForReturnUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Check if URL is VNPay return URL and handle callback
  void _checkForReturnUrl(String url) {
    if (_isProcessingCallback) return;

    if (_vnpayService.isVNPayReturnUrl(url)) {
      setState(() => _isProcessingCallback = true);
      _handlePaymentCallback(url);
    }
  }

  /// Handle VNPay payment callback
  Future<void> _handlePaymentCallback(String url) async {
    try {
      // Parse return URL parameters
      final params = _vnpayService.parseReturnUrl(url);

      if (params.isEmpty) {
        throw Exception('Không thể parse URL callback');
      }

      // Call backend to process callback
      final result = await _vnpayService.handlePaymentCallback(params);

      if (mounted) {
        // Navigate to result screen
        Navigator.pushReplacementNamed(
          context,
          '/payment/result',
          arguments: {
            'success': result.isSuccess,
            'result': result,
            'orderId': widget.orderId,
            'orderNumber': widget.orderNumber,
            'errorMessage': null,
          },
        );
      }
    } catch (e) {
      print('❌ Handle callback error: $e');

      if (mounted) {
        setState(() => _isProcessingCallback = false);

        // Show error and navigate to failed screen
        Fluttertoast.showToast(
          msg: 'Lỗi xử lý thanh toán: ${e.toString()}',
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        // Navigate to failed screen after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/payment/result',
              arguments: {
                'success': false,
                'result': null,
                'orderId': widget.orderId,
                'orderNumber': widget.orderNumber,
                'errorMessage': e.toString(),
              },
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Confirm before leaving payment page
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy thanh toán?'),
            content: const Text(
              'Bạn có chắc muốn hủy thanh toán? Đơn hàng sẽ chưa được xác nhận.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tiếp tục thanh toán'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Hủy'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hủy thanh toán?'),
                  content: const Text('Bạn có chắc muốn hủy thanh toán?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Không'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Có'),
                    ),
                  ],
                ),
              );

              if (shouldClose == true && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isProcessingCallback
                  ? null
                  : () {
                      _controller.reload();
                    },
            ),
          ],
        ),
        body: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _controller),

            // Loading progress bar
            if (_isLoading && _loadingProgress < 100)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

            // Error message
            if (_errorMessage != null && !_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.error.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() => _errorMessage = null);
                        },
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),

            // Processing callback overlay
            if (_isProcessingCallback)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Đang xử lý thanh toán...',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng không tắt ứng dụng',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
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
            child: Row(
              children: [
                Icon(Icons.security, size: 20, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Giao dịch được bảo mật bởi VNPay',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Mã ĐH: ${widget.orderNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
