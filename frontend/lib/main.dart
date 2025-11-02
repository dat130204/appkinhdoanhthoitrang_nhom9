import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_preferences_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home/product_detail_screen.dart';
import 'screens/order/checkout_screen.dart';
import 'screens/order/order_history_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/products_screen.dart';
import 'screens/admin/product_form_screen.dart';
import 'screens/admin/categories_screen.dart';
import 'screens/admin/orders_list_screen.dart';
import 'screens/admin/users_list_screen.dart';
import 'screens/admin/reviews_screen.dart';
import 'screens/admin/settings_screen.dart';
import 'screens/admin/send_notifications_screen.dart';
import 'screens/admin/store_settings_screen.dart';
import 'screens/main/notifications_screen.dart';
import 'screens/profile/support_chat_screen.dart';
import 'screens/payment/payment_method_screen.dart';
import 'screens/payment/vnpay_webview_screen.dart';
import 'screens/payment/payment_result_screen.dart';
import 'models/product.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Fashion Shop',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', ''), // Vietnamese
              Locale('en', ''), // English
            ],
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainScreen(),
              '/admin': (context) => const AdminMainScreen(),
              '/admin/dashboard': (context) => const AdminRoute(
                child: DashboardScreen(),
                routeName: '/admin/dashboard',
              ),
              '/admin/products': (context) => const AdminRoute(
                child: AdminProductsScreen(),
                routeName: '/admin/products',
              ),
              '/admin/categories': (context) => const AdminRoute(
                child: AdminCategoriesScreen(),
                routeName: '/admin/categories',
              ),
              '/admin/orders': (context) => const AdminRoute(
                child: OrdersListScreen(),
                routeName: '/admin/orders',
              ),
              '/admin/users': (context) => const AdminRoute(
                child: UsersListScreen(),
                routeName: '/admin/users',
              ),
              '/admin/reviews': (context) => const AdminRoute(
                child: AdminReviewsScreen(),
                routeName: '/admin/reviews',
              ),
              '/admin/settings': (context) => const AdminRoute(
                child: AdminSettingsScreen(),
                routeName: '/admin/settings',
              ),
              '/admin/send-notifications': (context) => const AdminRoute(
                child: SendNotificationsScreen(),
                routeName: '/admin/send-notifications',
              ),
              '/admin/store-settings': (context) => const AdminRoute(
                child: StoreSettingsScreen(),
                routeName: '/admin/store-settings',
              ),
              '/notifications': (context) => const NotificationsScreen(),
              '/support-chat': (context) => const SupportChatScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle /product-detail route with arguments
              if (settings.name == '/product-detail') {
                final productId = settings.arguments as int;
                return MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(productId: productId),
                  settings: settings,
                );
              }

              // Handle /checkout route
              if (settings.name == '/checkout') {
                return MaterialPageRoute(
                  builder: (context) => const CheckoutScreen(),
                  settings: settings,
                );
              }

              // Handle /admin/product-form route
              if (settings.name == '/admin/product-form') {
                final product = settings.arguments as Product?;
                return MaterialPageRoute(
                  builder: (context) => AdminRoute(
                    child: ProductFormScreen(product: product),
                    routeName: '/admin/product-form',
                  ),
                  settings: settings,
                );
              }

              // Handle /order_history route
              if (settings.name == '/order_history') {
                return MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                  settings: settings,
                );
              }

              // Handle /cart route - just go back since cart is in MainScreen
              if (settings.name == '/cart') {
                // Pop back to previous screen (MainScreen with cart will be visible)
                return MaterialPageRoute(
                  builder: (context) {
                    // Navigate back immediately
                    Future.microtask(() => Navigator.of(context).pop());
                    return const MainScreen();
                  },
                  settings: settings,
                );
              }

              // Handle /payment/method route
              if (settings.name == '/payment/method') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PaymentMethodScreen(
                    orderId: args['orderId'] as int,
                    totalAmount: args['totalAmount'] as double,
                    orderNumber: args['orderNumber'] as String,
                  ),
                  settings: settings,
                );
              }

              // Handle /payment/vnpay-webview route
              if (settings.name == '/payment/vnpay-webview') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => VNPayWebViewScreen(
                    paymentUrl: args['paymentUrl'] as String,
                    orderId: args['orderId'] as int,
                    orderNumber: args['orderNumber'] as String,
                  ),
                  settings: settings,
                );
              }

              // Handle /payment/result route
              if (settings.name == '/payment/result') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PaymentResultScreen(
                    success: args['success'] as bool,
                    result: args['result'],
                    orderId: args['orderId'] as int?,
                    orderNumber: args['orderNumber'] as String?,
                    errorMessage: args['errorMessage'] as String?,
                  ),
                  settings: settings,
                );
              }

              return null;
            },
          );
        },
      ),
    );
  }
}
