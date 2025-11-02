-- Create settings table
CREATE TABLE IF NOT EXISTS settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  `key` VARCHAR(100) NOT NULL UNIQUE,
  value TEXT NOT NULL,
  description VARCHAR(255) DEFAULT NULL,
  category ENUM('store', 'payment', 'shipping', 'notification', 'email', 'system') NOT NULL DEFAULT 'system',
  data_type ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_category (category),
  INDEX idx_key (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT INTO settings (`key`, value, description, category, data_type) VALUES
-- Store Information
('store_name', 'Fashion Shop', 'Tên cửa hàng', 'store', 'string'),
('store_email', 'contact@fashionshop.com', 'Email liên hệ', 'store', 'string'),
('store_phone', '0123456789', 'Số điện thoại', 'store', 'string'),
('store_address', '123 Nguyễn Huệ, Quận 1, TP.HCM', 'Địa chỉ cửa hàng', 'store', 'string'),
('store_description', 'Thời trang cao cấp cho mọi lứa tuổi', 'Mô tả cửa hàng', 'store', 'string'),
('store_logo_url', '', 'URL logo cửa hàng', 'store', 'string'),

-- Payment Settings
('currency', 'VND', 'Đơn vị tiền tệ', 'payment', 'string'),
('currency_symbol', '₫', 'Ký hiệu tiền tệ', 'payment', 'string'),
('tax_rate', '10', 'Thuế VAT (%)', 'payment', 'number'),
('accept_cod', 'true', 'Chấp nhận thanh toán COD', 'payment', 'boolean'),
('accept_online_payment', 'true', 'Chấp nhận thanh toán online', 'payment', 'boolean'),

-- Shipping Settings
('shipping_fee', '30000', 'Phí vận chuyển mặc định', 'shipping', 'number'),
('free_shipping_threshold', '500000', 'Miễn phí ship từ', 'shipping', 'number'),
('shipping_regions', '["TP.HCM", "Hà Nội", "Đà Nẵng", "Cần Thơ"]', 'Khu vực giao hàng', 'shipping', 'json'),
('estimated_delivery_days', '3-5', 'Thời gian giao hàng dự kiến', 'shipping', 'string'),

-- Notification Settings
('email_notifications', 'true', 'Bật thông báo email', 'notification', 'boolean'),
('sms_notifications', 'false', 'Bật thông báo SMS', 'notification', 'boolean'),
('push_notifications', 'true', 'Bật push notifications', 'notification', 'boolean'),
('notify_new_order', 'true', 'Thông báo đơn hàng mới', 'notification', 'boolean'),
('notify_order_status', 'true', 'Thông báo trạng thái đơn hàng', 'notification', 'boolean'),
('notify_low_stock', 'true', 'Thông báo hàng sắp hết', 'notification', 'boolean'),
('low_stock_threshold', '10', 'Ngưỡng cảnh báo hàng tồn', 'notification', 'number'),

-- Email Templates
('email_from_name', 'Fashion Shop', 'Tên người gửi email', 'email', 'string'),
('email_from_address', 'noreply@fashionshop.com', 'Địa chỉ email gửi', 'email', 'string'),
('email_reply_to', 'support@fashionshop.com', 'Email reply-to', 'email', 'string'),
('email_footer', '© 2024 Fashion Shop. All rights reserved.', 'Footer email', 'email', 'string'),

-- System Settings
('maintenance_mode', 'false', 'Chế độ bảo trì', 'system', 'boolean'),
('allow_registration', 'true', 'Cho phép đăng ký', 'system', 'boolean'),
('allow_guest_checkout', 'false', 'Cho phép mua hàng không cần đăng ký', 'system', 'boolean'),
('max_cart_items', '50', 'Số lượng sản phẩm tối đa trong giỏ', 'system', 'number'),
('session_timeout', '3600', 'Thời gian timeout phiên (giây)', 'system', 'number'),
('enable_reviews', 'true', 'Cho phép đánh giá sản phẩm', 'system', 'boolean'),
('auto_approve_reviews', 'false', 'Tự động duyệt đánh giá', 'system', 'boolean');
