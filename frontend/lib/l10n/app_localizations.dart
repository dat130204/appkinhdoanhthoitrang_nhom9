import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Fashion Shop'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In vi, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get submit;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get sort;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reset;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get error;

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get info;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công!'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công!'**
  String get registerSuccess;

  /// No description provided for @logoutSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất thành công!'**
  String get logoutSuccess;

  /// No description provided for @pleaseLogin.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập'**
  String get pleaseLogin;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để tiếp tục'**
  String get pleaseLoginToContinue;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get categories;

  /// No description provided for @cart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng'**
  String get cart;

  /// No description provided for @wishlist.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get wishlist;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get profile;

  /// No description provided for @hotDeals.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi hot'**
  String get hotDeals;

  /// No description provided for @newArrivals.
  ///
  /// In vi, this message translates to:
  /// **'Hàng mới về'**
  String get newArrivals;

  /// No description provided for @bestSellers.
  ///
  /// In vi, this message translates to:
  /// **'Bán chạy'**
  String get bestSellers;

  /// No description provided for @forYou.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho bạn'**
  String get forYou;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm'**
  String get seeMore;

  /// No description provided for @product.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get product;

  /// No description provided for @products.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get products;

  /// No description provided for @productDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết sản phẩm'**
  String get productDetails;

  /// No description provided for @price.
  ///
  /// In vi, this message translates to:
  /// **'Giá'**
  String get price;

  /// No description provided for @description.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get description;

  /// No description provided for @size.
  ///
  /// In vi, this message translates to:
  /// **'Kích cỡ'**
  String get size;

  /// No description provided for @color.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc'**
  String get color;

  /// No description provided for @quantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get quantity;

  /// No description provided for @inStock.
  ///
  /// In vi, this message translates to:
  /// **'Còn hàng'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In vi, this message translates to:
  /// **'Hết hàng'**
  String get outOfStock;

  /// No description provided for @addToCart.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào giỏ'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In vi, this message translates to:
  /// **'Mua ngay'**
  String get buyNow;

  /// No description provided for @addedToCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào giỏ hàng'**
  String get addedToCart;

  /// No description provided for @addToWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào yêu thích'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi yêu thích'**
  String get removeFromWishlist;

  /// No description provided for @addedToWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào yêu thích'**
  String get addedToWishlist;

  /// No description provided for @removedFromWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa khỏi yêu thích'**
  String get removedFromWishlist;

  /// No description provided for @selectSize.
  ///
  /// In vi, this message translates to:
  /// **'Chọn size'**
  String get selectSize;

  /// No description provided for @selectColor.
  ///
  /// In vi, this message translates to:
  /// **'Chọn màu'**
  String get selectColor;

  /// No description provided for @emptyCart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng trống'**
  String get emptyCart;

  /// No description provided for @emptyCartMessage.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sản phẩm nào trong giỏ hàng'**
  String get emptyCartMessage;

  /// No description provided for @continueShopping.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục mua sắm'**
  String get continueShopping;

  /// No description provided for @checkout.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get checkout;

  /// No description provided for @subtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao'**
  String get shipping;

  /// No description provided for @total.
  ///
  /// In vi, this message translates to:
  /// **'Tổng cộng'**
  String get total;

  /// No description provided for @removeFromCart.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi giỏ'**
  String get removeFromCart;

  /// No description provided for @updateCart.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật giỏ hàng'**
  String get updateCart;

  /// No description provided for @cartUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật giỏ hàng'**
  String get cartUpdated;

  /// No description provided for @emptyWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sản phẩm yêu thích'**
  String get emptyWishlist;

  /// No description provided for @emptyWishlistMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thêm sản phẩm yêu thích để xem sau'**
  String get emptyWishlistMessage;

  /// No description provided for @myWishlist.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách yêu thích'**
  String get myWishlist;

  /// No description provided for @moveToCart.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển vào giỏ'**
  String get moveToCart;

  /// No description provided for @allCategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục'**
  String get allCategories;

  /// No description provided for @men.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get men;

  /// No description provided for @women.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get women;

  /// No description provided for @kids.
  ///
  /// In vi, this message translates to:
  /// **'Trẻ em'**
  String get kids;

  /// No description provided for @accessories.
  ///
  /// In vi, this message translates to:
  /// **'Phụ kiện'**
  String get accessories;

  /// No description provided for @shoes.
  ///
  /// In vi, this message translates to:
  /// **'Giày dép'**
  String get shoes;

  /// No description provided for @bags.
  ///
  /// In vi, this message translates to:
  /// **'Túi xách'**
  String get bags;

  /// No description provided for @filterBy.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo'**
  String get filterBy;

  /// No description provided for @sortBy.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp theo'**
  String get sortBy;

  /// No description provided for @priceRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng giá'**
  String get priceRange;

  /// No description provided for @brand.
  ///
  /// In vi, this message translates to:
  /// **'Thương hiệu'**
  String get brand;

  /// No description provided for @rating.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get rating;

  /// No description provided for @discount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá'**
  String get discount;

  /// No description provided for @newest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In vi, this message translates to:
  /// **'Cũ nhất'**
  String get oldest;

  /// No description provided for @priceLowToHigh.
  ///
  /// In vi, this message translates to:
  /// **'Giá thấp đến cao'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In vi, this message translates to:
  /// **'Giá cao đến thấp'**
  String get priceHighToLow;

  /// No description provided for @topRated.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá cao'**
  String get topRated;

  /// No description provided for @mostPopular.
  ///
  /// In vi, this message translates to:
  /// **'Phổ biến nhất'**
  String get mostPopular;

  /// No description provided for @reviews.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In vi, this message translates to:
  /// **'Viết đánh giá'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa đánh giá'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In vi, this message translates to:
  /// **'Xóa đánh giá'**
  String get deleteReview;

  /// No description provided for @yourReview.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn'**
  String get yourReview;

  /// No description provided for @comment.
  ///
  /// In vi, this message translates to:
  /// **'Nhận xét'**
  String get comment;

  /// No description provided for @allReviews.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả đánh giá'**
  String get allReviews;

  /// No description provided for @allReviewsCount.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả đánh giá ({count})'**
  String allReviewsCount(int count);

  /// No description provided for @noReviews.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá nào'**
  String get noReviews;

  /// No description provided for @productReviews.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá sản phẩm'**
  String get productReviews;

  /// No description provided for @confirmDeleteReview.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDeleteReview;

  /// No description provided for @confirmDeleteReviewMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa đánh giá này?'**
  String get confirmDeleteReviewMessage;

  /// No description provided for @reviewDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa đánh giá'**
  String get reviewDeleted;

  /// No description provided for @reviewSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá thành công!'**
  String get reviewSubmitted;

  /// No description provided for @reviewUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật đánh giá thành công!'**
  String get reviewUpdated;

  /// No description provided for @pleaseLoginToReview.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để viết đánh giá'**
  String get pleaseLoginToReview;

  /// No description provided for @sortRecent.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get sortRecent;

  /// No description provided for @sortHelpful.
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích nhất'**
  String get sortHelpful;

  /// No description provided for @sortRatingHigh.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá cao nhất'**
  String get sortRatingHigh;

  /// No description provided for @sortRatingLow.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá thấp nhất'**
  String get sortRatingLow;

  /// No description provided for @helpful.
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In vi, this message translates to:
  /// **'Không hữu ích'**
  String get notHelpful;

  /// No description provided for @orders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng'**
  String get orders;

  /// No description provided for @myOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng của tôi'**
  String get myOrders;

  /// No description provided for @orderHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đơn hàng'**
  String get orderHistory;

  /// No description provided for @orderDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết đơn hàng'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đặt'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get orderStatus;

  /// No description provided for @pending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xử lý'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý'**
  String get processing;

  /// No description provided for @delivered.
  ///
  /// In vi, this message translates to:
  /// **'Đã giao'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get cancelled;

  /// No description provided for @trackOrder.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi đơn hàng'**
  String get trackOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn hàng'**
  String get cancelOrder;

  /// No description provided for @reorder.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reorder;

  /// No description provided for @returnOrder.
  ///
  /// In vi, this message translates to:
  /// **'Trả hàng'**
  String get returnOrder;

  /// No description provided for @myProfile.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của tôi'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInfo;

  /// No description provided for @shippingAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ giao hàng'**
  String get shippingAddress;

  /// No description provided for @paymentMethods.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethods;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @help.
  ///
  /// In vi, this message translates to:
  /// **'Trợ giúp'**
  String get help;

  /// No description provided for @termsAndConditions.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản và điều kiện'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In vi, this message translates to:
  /// **'Về chúng tôi'**
  String get aboutUs;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get version;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get systemDefault;

  /// No description provided for @selectLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get english;

  /// No description provided for @languageChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đã thay đổi ngôn ngữ'**
  String get languageChanged;

  /// No description provided for @noNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông báo'**
  String get noNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu đã đọc tất cả'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả'**
  String get clearAll;

  /// No description provided for @errorOccurred.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi kết nối mạng'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi máy chủ'**
  String get serverError;

  /// No description provided for @invalidInput.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu không hợp lệ'**
  String get invalidInput;

  /// No description provided for @requiredField.
  ///
  /// In vi, this message translates to:
  /// **'Trường này là bắt buộc'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu quá ngắn'**
  String get passwordTooShort;

  /// No description provided for @passwordNotMatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get passwordNotMatch;

  /// No description provided for @tryAgain.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get tryAgain;

  /// No description provided for @contactSupport.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ hỗ trợ'**
  String get contactSupport;

  /// No description provided for @searchProducts.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm sản phẩm'**
  String get searchProducts;

  /// No description provided for @searchResults.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả tìm kiếm'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả'**
  String get noResults;

  /// No description provided for @recentSearches.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm gần đây'**
  String get recentSearches;

  /// No description provided for @popularSearches.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm phổ biến'**
  String get popularSearches;

  /// No description provided for @clearSearchHistory.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử tìm kiếm'**
  String get clearSearchHistory;

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán khi nhận hàng'**
  String get cashOnDelivery;

  /// No description provided for @creditCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get creditCard;

  /// No description provided for @bankTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản ngân hàng'**
  String get bankTransfer;

  /// No description provided for @eWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get eWallet;

  /// No description provided for @paymentSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thất bại'**
  String get paymentFailed;

  /// No description provided for @address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get address;

  /// No description provided for @addAddress.
  ///
  /// In vi, this message translates to:
  /// **'Thêm địa chỉ'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In vi, this message translates to:
  /// **'Sửa địa chỉ'**
  String get editAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In vi, this message translates to:
  /// **'Xóa địa chỉ'**
  String get deleteAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In vi, this message translates to:
  /// **'Đặt làm mặc định'**
  String get setAsDefault;

  /// No description provided for @defaultAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ mặc định'**
  String get defaultAddress;

  /// No description provided for @street.
  ///
  /// In vi, this message translates to:
  /// **'Đường'**
  String get street;

  /// No description provided for @city.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố'**
  String get city;

  /// No description provided for @state.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh/Thành'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã bưu điện'**
  String get zipCode;

  /// No description provided for @country.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia'**
  String get country;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
