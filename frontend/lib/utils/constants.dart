class AppConstants {
  // API Endpoints
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String authEndpoint = '/auth';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';

  // SharedPreferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';

  // App Info
  static const String appName = 'Fashion Shop';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int itemsPerPage = 20;
  static const int productsPerRow = 2;

  // Image Placeholders
  static const String productPlaceholder =
      'assets/images/product_placeholder.png';
  static const String categoryPlaceholder =
      'assets/images/category_placeholder.png';
  static const String avatarPlaceholder =
      'assets/images/avatar_placeholder.png';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Sizes
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Product Card
  static const double productCardHeight = 280.0;
  static const double productImageHeight = 180.0;

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderShipping = 'shipping';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Payment Methods
  static const String paymentCOD = 'cod';
  static const String paymentBankTransfer = 'bank_transfer';
  static const String paymentMomo = 'momo';
  static const String paymentVNPay = 'vnpay';

  // Currency
  static const String currencySymbol = 'đ';
  static const String currencyFormat = '#,###';

  // Format currency helper
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr$currencySymbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).round()}k$currencySymbol';
    }
    return '${amount.round()}$currencySymbol';
  }

  // Image placeholder
  static const String imagePlaceholder =
      'https://via.placeholder.com/400x400?text=No+Image';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Phone
  static const String phonePrefix = '+84';
  static const int phoneLength = 10;

  // Messages
  static const String networkError = 'Lỗi kết nối mạng. Vui lòng thử lại.';
  static const String serverError = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String unknownError = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  static const String loginRequired = 'Vui lòng đăng nhập để tiếp tục.';
  static const String noInternet = 'Không có kết nối Internet.';

  // Success Messages
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký thành công!';
  static const String addToCartSuccess = 'Đã thêm vào giỏ hàng!';
  static const String orderSuccess = 'Đặt hàng thành công!';
  static const String updateSuccess = 'Cập nhật thành công!';

  // Empty States
  static const String emptyCartMessage = 'Giỏ hàng trống';
  static const String emptyOrdersMessage = 'Chưa có đơn hàng';
  static const String emptyProductsMessage = 'Không có sản phẩm';
  static const String emptyCategoriesMessage = 'Không có danh mục';
  static const String emptySearchMessage = 'Không tìm thấy kết quả';

  // Button Labels
  static const String btnLogin = 'Đăng Nhập';
  static const String btnRegister = 'Đăng Ký';
  static const String btnAddToCart = 'Thêm Vào Giỏ';
  static const String btnBuyNow = 'Mua Ngay';
  static const String btnCheckout = 'Thanh Toán';
  static const String btnPlaceOrder = 'Đặt Hàng';
  static const String btnCancel = 'Hủy';
  static const String btnConfirm = 'Xác Nhận';
  static const String btnSave = 'Lưu';
  static const String btnUpdate = 'Cập Nhật';
  static const String btnLogout = 'Đăng Xuất';

  // Tab Labels
  static const String tabHome = 'Trang Chủ';
  static const String tabCategories = 'Danh Mục';
  static const String tabCart = 'Giỏ Hàng';
  static const String tabProfile = 'Tài Khoản';
}
