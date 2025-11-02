import 'package:flutter/material.dart';
import '../../models/app_setting.dart';
import '../../services/settings_service.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();

  bool _isLoading = true;
  String? _error;

  // Store settings
  final _storeNameController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storeDescriptionController = TextEditingController();

  // Payment settings
  final _currencyController = TextEditingController();
  final _currencySymbolController = TextEditingController();
  final _taxRateController = TextEditingController();
  bool _acceptCod = true;
  bool _acceptOnlinePayment = true;

  // Shipping settings
  final _shippingFeeController = TextEditingController();
  final _freeShippingThresholdController = TextEditingController();
  final _estimatedDeliveryDaysController = TextEditingController();
  List<String> _shippingRegions = [];

  // Notification settings
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _notifyNewOrder = true;
  bool _notifyOrderStatus = true;
  bool _notifyLowStock = true;
  final _lowStockThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storeNameController.dispose();
    _storeEmailController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    _storeDescriptionController.dispose();
    _currencyController.dispose();
    _currencySymbolController.dispose();
    _taxRateController.dispose();
    _shippingFeeController.dispose();
    _freeShippingThresholdController.dispose();
    _estimatedDeliveryDaysController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storeSettings = await _settingsService.getStoreSettings();
      final paymentSettings = await _settingsService.getPaymentSettings();
      final shippingSettings = await _settingsService.getShippingSettings();
      final notificationSettings = await _settingsService
          .getNotificationSettings();

      setState(() {
        // Store
        _storeNameController.text = storeSettings.storeName;
        _storeEmailController.text = storeSettings.storeEmail;
        _storePhoneController.text = storeSettings.storePhone;
        _storeAddressController.text = storeSettings.storeAddress;
        _storeDescriptionController.text = storeSettings.storeDescription;

        // Payment
        _currencyController.text = paymentSettings.currency;
        _currencySymbolController.text = paymentSettings.currencySymbol;
        _taxRateController.text = paymentSettings.taxRate.toString();
        _acceptCod = paymentSettings.acceptCod;
        _acceptOnlinePayment = paymentSettings.acceptOnlinePayment;

        // Shipping
        _shippingFeeController.text = shippingSettings.shippingFee.toString();
        _freeShippingThresholdController.text = shippingSettings
            .freeShippingThreshold
            .toString();
        _estimatedDeliveryDaysController.text =
            shippingSettings.estimatedDeliveryDays;
        _shippingRegions = shippingSettings.shippingRegions;

        // Notifications
        _emailNotifications = notificationSettings.emailNotifications;
        _smsNotifications = notificationSettings.smsNotifications;
        _pushNotifications = notificationSettings.pushNotifications;
        _notifyNewOrder = notificationSettings.notifyNewOrder;
        _notifyOrderStatus = notificationSettings.notifyOrderStatus;
        _notifyLowStock = notificationSettings.notifyLowStock;
        _lowStockThresholdController.text = notificationSettings
            .lowStockThreshold
            .toString();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStoreSettings() async {
    try {
      final settings = StoreSettings(
        storeName: _storeNameController.text,
        storeEmail: _storeEmailController.text,
        storePhone: _storePhoneController.text,
        storeAddress: _storeAddressController.text,
        storeDescription: _storeDescriptionController.text,
      );

      await _settingsService.updateStoreSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thông tin cửa hàng'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePaymentSettings() async {
    try {
      final settings = PaymentSettings(
        currency: _currencyController.text,
        currencySymbol: _currencySymbolController.text,
        taxRate: double.tryParse(_taxRateController.text) ?? 10,
        acceptCod: _acceptCod,
        acceptOnlinePayment: _acceptOnlinePayment,
      );

      await _settingsService.updatePaymentSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cài đặt thanh toán'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveShippingSettings() async {
    try {
      final settings = ShippingSettings(
        shippingFee: double.tryParse(_shippingFeeController.text) ?? 30000,
        freeShippingThreshold:
            double.tryParse(_freeShippingThresholdController.text) ?? 500000,
        shippingRegions: _shippingRegions,
        estimatedDeliveryDays: _estimatedDeliveryDaysController.text,
      );

      await _settingsService.updateShippingSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cài đặt vận chuyển'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final settings = NotificationSettings(
        emailNotifications: _emailNotifications,
        smsNotifications: _smsNotifications,
        pushNotifications: _pushNotifications,
        notifyNewOrder: _notifyNewOrder,
        notifyOrderStatus: _notifyOrderStatus,
        notifyLowStock: _notifyLowStock,
        lowStockThreshold:
            int.tryParse(_lowStockThresholdController.text) ?? 10,
      );

      await _settingsService.updateNotificationSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cài đặt thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt Cửa Hàng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cửa hàng'),
            Tab(text: 'Thanh toán'),
            Tab(text: 'Vận chuyển'),
            Tab(text: 'Thông báo'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  ElevatedButton(
                    onPressed: _loadSettings,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStoreTab(),
                _buildPaymentTab(),
                _buildShippingTab(),
                _buildNotificationTab(),
              ],
            ),
    );
  }

  Widget _buildStoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _storeNameController,
          decoration: const InputDecoration(
            labelText: 'Tên cửa hàng',
            prefixIcon: Icon(Icons.store),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _storeEmailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _storePhoneController,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _storeAddressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _storeDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Mô tả',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveStoreSettings,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('Lưu thông tin cửa hàng'),
        ),
      ],
    );
  }

  Widget _buildPaymentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _currencyController,
          decoration: const InputDecoration(
            labelText: 'Đơn vị tiền tệ',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _currencySymbolController,
          decoration: const InputDecoration(
            labelText: 'Ký hiệu tiền tệ',
            prefixIcon: Icon(Icons.currency_exchange),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _taxRateController,
          decoration: const InputDecoration(
            labelText: 'Thuế VAT (%)',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Chấp nhận thanh toán COD'),
          subtitle: const Text('Thanh toán khi nhận hàng'),
          value: _acceptCod,
          onChanged: (value) => setState(() => _acceptCod = value),
        ),
        SwitchListTile(
          title: const Text('Chấp nhận thanh toán online'),
          subtitle: const Text('Chuyển khoản, ví điện tử'),
          value: _acceptOnlinePayment,
          onChanged: (value) => setState(() => _acceptOnlinePayment = value),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _savePaymentSettings,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('Lưu cài đặt thanh toán'),
        ),
      ],
    );
  }

  Widget _buildShippingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _shippingFeeController,
          decoration: const InputDecoration(
            labelText: 'Phí vận chuyển (VNĐ)',
            prefixIcon: Icon(Icons.local_shipping),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _freeShippingThresholdController,
          decoration: const InputDecoration(
            labelText: 'Miễn phí vận chuyển từ (VNĐ)',
            prefixIcon: Icon(Icons.card_giftcard),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _estimatedDeliveryDaysController,
          decoration: const InputDecoration(
            labelText: 'Thời gian giao hàng dự kiến',
            prefixIcon: Icon(Icons.schedule),
            border: OutlineInputBorder(),
            hintText: 'VD: 3-5 ngày',
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khu vực giao hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _shippingRegions
                      .map(
                        (region) => Chip(
                          label: Text(region),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _shippingRegions.remove(region);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveShippingSettings,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('Lưu cài đặt vận chuyển'),
        ),
      ],
    );
  }

  Widget _buildNotificationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Kênh thông báo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: const Text('Thông báo qua Email'),
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        SwitchListTile(
          title: const Text('Thông báo qua SMS'),
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
        ),
        SwitchListTile(
          title: const Text('Thông báo đẩy (Push)'),
          value: _pushNotifications,
          onChanged: (value) => setState(() => _pushNotifications = value),
        ),
        const Divider(height: 32),
        const Text(
          'Sự kiện thông báo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: const Text('Đơn hàng mới'),
          subtitle: const Text('Thông báo khi có đơn hàng mới'),
          value: _notifyNewOrder,
          onChanged: (value) => setState(() => _notifyNewOrder = value),
        ),
        SwitchListTile(
          title: const Text('Cập nhật trạng thái đơn hàng'),
          subtitle: const Text('Thông báo khi trạng thái đơn hàng thay đổi'),
          value: _notifyOrderStatus,
          onChanged: (value) => setState(() => _notifyOrderStatus = value),
        ),
        SwitchListTile(
          title: const Text('Hàng sắp hết'),
          subtitle: const Text('Thông báo khi hàng tồn kho thấp'),
          value: _notifyLowStock,
          onChanged: (value) => setState(() => _notifyLowStock = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lowStockThresholdController,
          decoration: const InputDecoration(
            labelText: 'Ngưỡng cảnh báo hàng tồn',
            prefixIcon: Icon(Icons.inventory),
            border: OutlineInputBorder(),
            helperText: 'Thông báo khi số lượng tồn kho dưới ngưỡng này',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveNotificationSettings,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('Lưu cài đặt thông báo'),
        ),
      ],
    );
  }
}
