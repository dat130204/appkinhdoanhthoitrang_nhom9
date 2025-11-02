class AppSetting {
  final int id;
  final String key;
  final dynamic value;
  final String? description;
  final SettingCategory category;
  final SettingDataType dataType;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSetting({
    required this.id,
    required this.key,
    required this.value,
    this.description,
    required this.category,
    required this.dataType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    final dataType = SettingDataType.fromString(json['data_type']);
    dynamic parsedValue = json['value'];

    // Parse value based on data type
    switch (dataType) {
      case SettingDataType.number:
        parsedValue = double.tryParse(json['value'].toString()) ?? 0;
        break;
      case SettingDataType.boolean:
        parsedValue =
            json['value'] == 'true' ||
            json['value'] == '1' ||
            json['value'] == 1 ||
            json['value'] == true;
        break;
      case SettingDataType.json:
        // parsedValue will already be Map if parsed from JSON
        break;
      default:
        parsedValue = json['value'].toString();
    }

    return AppSetting(
      id: json['id'],
      key: json['key'],
      value: parsedValue,
      description: json['description'],
      category: SettingCategory.fromString(json['category']),
      dataType: dataType,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'description': description,
      'category': category.value,
      'data_type': dataType.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum SettingCategory {
  store('store', 'Thông tin cửa hàng'),
  payment('payment', 'Thanh toán'),
  shipping('shipping', 'Vận chuyển'),
  notification('notification', 'Thông báo'),
  email('email', 'Email'),
  system('system', 'Hệ thống');

  final String value;
  final String displayName;

  const SettingCategory(this.value, this.displayName);

  static SettingCategory fromString(String value) {
    return SettingCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => SettingCategory.system,
    );
  }
}

enum SettingDataType {
  string('string'),
  number('number'),
  boolean('boolean'),
  json('json');

  final String value;

  const SettingDataType(this.value);

  static SettingDataType fromString(String value) {
    return SettingDataType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SettingDataType.string,
    );
  }
}

class SettingsGroup {
  final Map<String, List<SettingItem>> categories;

  SettingsGroup({required this.categories});

  factory SettingsGroup.fromJson(Map<String, dynamic> json) {
    final Map<String, List<SettingItem>> categories = {};

    json.forEach((category, items) {
      if (items is List) {
        categories[category] = items
            .map((item) => SettingItem.fromJson(item))
            .toList();
      }
    });

    return SettingsGroup(categories: categories);
  }
}

class SettingItem {
  final String key;
  final dynamic value;
  final String? description;
  final SettingDataType dataType;

  SettingItem({
    required this.key,
    required this.value,
    this.description,
    required this.dataType,
  });

  factory SettingItem.fromJson(Map<String, dynamic> json) {
    return SettingItem(
      key: json['key'],
      value: json['value'],
      description: json['description'],
      dataType: SettingDataType.fromString(json['dataType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'description': description,
      'dataType': dataType.value,
    };
  }
}

class StoreSettings {
  final String storeName;
  final String storeEmail;
  final String storePhone;
  final String storeAddress;
  final String storeDescription;
  final String? storeLogoUrl;

  StoreSettings({
    required this.storeName,
    required this.storeEmail,
    required this.storePhone,
    required this.storeAddress,
    required this.storeDescription,
    this.storeLogoUrl,
  });

  factory StoreSettings.fromMap(Map<String, dynamic> map) {
    return StoreSettings(
      storeName: map['store_name'] ?? 'Fashion Shop',
      storeEmail: map['store_email'] ?? '',
      storePhone: map['store_phone'] ?? '',
      storeAddress: map['store_address'] ?? '',
      storeDescription: map['store_description'] ?? '',
      storeLogoUrl: map['store_logo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_name': storeName,
      'store_email': storeEmail,
      'store_phone': storePhone,
      'store_address': storeAddress,
      'store_description': storeDescription,
      'store_logo_url': storeLogoUrl,
    };
  }
}

class PaymentSettings {
  final String currency;
  final String currencySymbol;
  final double taxRate;
  final bool acceptCod;
  final bool acceptOnlinePayment;

  PaymentSettings({
    required this.currency,
    required this.currencySymbol,
    required this.taxRate,
    required this.acceptCod,
    required this.acceptOnlinePayment,
  });

  factory PaymentSettings.fromMap(Map<String, dynamic> map) {
    return PaymentSettings(
      currency: map['currency'] ?? 'VND',
      currencySymbol: map['currency_symbol'] ?? '₫',
      taxRate: double.tryParse(map['tax_rate']?.toString() ?? '10') ?? 10,
      acceptCod: map['accept_cod'] == true || map['accept_cod'] == 'true',
      acceptOnlinePayment:
          map['accept_online_payment'] == true ||
          map['accept_online_payment'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'currency_symbol': currencySymbol,
      'tax_rate': taxRate.toString(),
      'accept_cod': acceptCod.toString(),
      'accept_online_payment': acceptOnlinePayment.toString(),
    };
  }
}

class ShippingSettings {
  final double shippingFee;
  final double freeShippingThreshold;
  final List<String> shippingRegions;
  final String estimatedDeliveryDays;

  ShippingSettings({
    required this.shippingFee,
    required this.freeShippingThreshold,
    required this.shippingRegions,
    required this.estimatedDeliveryDays,
  });

  factory ShippingSettings.fromMap(Map<String, dynamic> map) {
    List<String> regions = [];
    if (map['shipping_regions'] != null) {
      if (map['shipping_regions'] is List) {
        regions = List<String>.from(map['shipping_regions']);
      }
    }

    return ShippingSettings(
      shippingFee:
          double.tryParse(map['shipping_fee']?.toString() ?? '30000') ?? 30000,
      freeShippingThreshold:
          double.tryParse(
            map['free_shipping_threshold']?.toString() ?? '500000',
          ) ??
          500000,
      shippingRegions: regions,
      estimatedDeliveryDays: map['estimated_delivery_days'] ?? '3-5',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shipping_fee': shippingFee.toString(),
      'free_shipping_threshold': freeShippingThreshold.toString(),
      'shipping_regions': shippingRegions,
      'estimated_delivery_days': estimatedDeliveryDays,
    };
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool notifyNewOrder;
  final bool notifyOrderStatus;
  final bool notifyLowStock;
  final int lowStockThreshold;

  NotificationSettings({
    required this.emailNotifications,
    required this.smsNotifications,
    required this.pushNotifications,
    required this.notifyNewOrder,
    required this.notifyOrderStatus,
    required this.notifyLowStock,
    required this.lowStockThreshold,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      emailNotifications:
          map['email_notifications'] == true ||
          map['email_notifications'] == 'true',
      smsNotifications:
          map['sms_notifications'] == true ||
          map['sms_notifications'] == 'true',
      pushNotifications:
          map['push_notifications'] == true ||
          map['push_notifications'] == 'true',
      notifyNewOrder:
          map['notify_new_order'] == true || map['notify_new_order'] == 'true',
      notifyOrderStatus:
          map['notify_order_status'] == true ||
          map['notify_order_status'] == 'true',
      notifyLowStock:
          map['notify_low_stock'] == true || map['notify_low_stock'] == 'true',
      lowStockThreshold:
          int.tryParse(map['low_stock_threshold']?.toString() ?? '10') ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email_notifications': emailNotifications.toString(),
      'sms_notifications': smsNotifications.toString(),
      'push_notifications': pushNotifications.toString(),
      'notify_new_order': notifyNewOrder.toString(),
      'notify_order_status': notifyOrderStatus.toString(),
      'notify_low_stock': notifyLowStock.toString(),
      'low_stock_threshold': lowStockThreshold.toString(),
    };
  }
}
