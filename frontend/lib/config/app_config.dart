class AppConfig {
  // API Configuration
  // Use localhost for Web, 10.0.2.2 for Android Emulator
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Web & iOS Simulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://192.168.1.x:3000/api'; // Physical Device
//http://localhost:3000/api
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Images
  static const String placeholderImage =
      'https://via.placeholder.com/300x400?text=No+Image';

  // Shipping Fee
  static const double freeShippingThreshold = 500000;
  static const double defaultShippingFee = 30000;
}
