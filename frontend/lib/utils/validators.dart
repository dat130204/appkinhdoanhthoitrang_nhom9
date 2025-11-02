import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Mật khẩu không được quá ${AppConstants.maxPasswordLength} ký tự';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Họ tên phải có ít nhất ${AppConstants.minNameLength} ký tự';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Họ tên không được quá ${AppConstants.maxNameLength} ký tự';
    }

    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Họ tên chỉ được chứa chữ cái';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if starts with 0 and has 10 digits
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Số điện thoại không hợp lệ (10 chữ số, bắt đầu bằng 0)';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }

    if (value.length < 10) {
      return 'Địa chỉ quá ngắn (ít nhất 10 ký tự)';
    }

    if (value.length > 200) {
      return 'Địa chỉ quá dài (tối đa 200 ký tự)';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Giá trị phải là số';
    }

    if (min != null && number < min) {
      return 'Giá trị phải lớn hơn hoặc bằng $min';
    }

    if (max != null && number > max) {
      return 'Giá trị phải nhỏ hơn hoặc bằng $max';
    }

    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    return validateNumber(value, min: 1, max: 999);
  }

  // City/Province validation
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn Tỉnh/Thành phố';
    }
    return null;
  }

  // District validation
  static String? validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn Quận/Huyện';
    }
    return null;
  }

  // Payment method validation
  static String? validatePaymentMethod(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn phương thức thanh toán';
    }
    return null;
  }
}
