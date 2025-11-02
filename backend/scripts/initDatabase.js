const mysql = require('mysql2/promise');
require('dotenv').config();

const SQL_CREATE_DATABASE = `
DROP DATABASE IF EXISTS fashion_shop;
CREATE DATABASE IF NOT EXISTS fashion_shop 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
`;

const SQL_CREATE_TABLES = `
USE fashion_shop;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  role ENUM('customer', 'admin') DEFAULT 'customer',
  avatar VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  password_reset_token VARCHAR(255) NULL,
  password_reset_expires DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_password_reset_token (password_reset_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image VARCHAR(255),
  parent_id INT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_parent (parent_id),
  INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products Table
CREATE TABLE IF NOT EXISTS products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  sale_price DECIMAL(10, 2),
  category_id INT NOT NULL,
  stock_quantity INT DEFAULT 0,
  sold_quantity INT DEFAULT 0,
  sku VARCHAR(100) UNIQUE,
  brand VARCHAR(100),
  material VARCHAR(100),
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(2, 1) DEFAULT 0,
  review_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  INDEX idx_category (category_id),
  INDEX idx_price (price),
  INDEX idx_featured (is_featured),
  INDEX idx_active (is_active),
  INDEX idx_sku (sku),
  FULLTEXT idx_search (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product Images Table
CREATE TABLE IF NOT EXISTS product_images (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product Variants Table (Size, Color)
CREATE TABLE IF NOT EXISTS product_variants (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  size VARCHAR(20),
  color VARCHAR(50),
  stock_quantity INT DEFAULT 0,
  price_adjustment DECIMAL(10, 2) DEFAULT 0,
  sku VARCHAR(100) UNIQUE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product (product_id),
  INDEX idx_sku (sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cart Table
CREATE TABLE IF NOT EXISTS carts (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  variant_id INT,
  quantity INT NOT NULL DEFAULT 1,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
  INDEX idx_cart (cart_id),
  INDEX idx_product (product_id),
  UNIQUE KEY unique_cart_product (cart_id, product_id, variant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  status ENUM('pending', 'confirmed', 'processing', 'shipping', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
  payment_method ENUM('cod', 'bank_transfer', 'momo', 'vnpay') DEFAULT 'cod',
  payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
  subtotal DECIMAL(10, 2) NOT NULL,
  shipping_fee DECIMAL(10, 2) DEFAULT 0,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  customer_name VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  customer_email VARCHAR(255),
  shipping_address TEXT NOT NULL,
  shipping_city VARCHAR(100),
  shipping_district VARCHAR(100),
  shipping_ward VARCHAR(100),
  notes TEXT,
  cancelled_reason TEXT,
  cancelled_at TIMESTAMP NULL,
  confirmed_at TIMESTAMP NULL,
  shipped_at TIMESTAMP NULL,
  delivered_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_order_number (order_number),
  INDEX idx_status (status),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  variant_id INT,
  product_name VARCHAR(255) NOT NULL,
  variant_info VARCHAR(255),
  quantity INT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
  FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
  INDEX idx_order (order_id),
  INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reviews Table (Updated with helpful feature)
CREATE TABLE IF NOT EXISTS reviews (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  user_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  helpful_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product (user_id, product_id),
  INDEX idx_product (product_id),
  INDEX idx_user (user_id),
  INDEX idx_rating (rating),
  INDEX idx_product_rating (product_id, rating),
  INDEX idx_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Review Helpful Table (for tracking who marked review as helpful)
CREATE TABLE IF NOT EXISTS review_helpful (
  id INT PRIMARY KEY AUTO_INCREMENT,
  review_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_review_user (review_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Favorites/Wishlist Table
CREATE TABLE IF NOT EXISTS favorites (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product (user_id, product_id),
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wishlists Table
CREATE TABLE IF NOT EXISTS wishlists (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_wishlist (user_id, product_id),
  INDEX idx_user_id (user_id),
  INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('order', 'promotion', 'system', 'review') DEFAULT 'system',
  related_id INT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_read (is_read),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Addresses Table
CREATE TABLE IF NOT EXISTS addresses (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100),
  ward VARCHAR(100),
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Coupons Table
CREATE TABLE IF NOT EXISTS coupons (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  discount_type ENUM('percentage', 'fixed') DEFAULT 'percentage',
  discount_value DECIMAL(10, 2) NOT NULL,
  min_order_amount DECIMAL(10, 2) DEFAULT 0,
  max_discount_amount DECIMAL(10, 2),
  usage_limit INT,
  used_count INT DEFAULT 0,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_code (code),
  INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
`;

const SQL_INSERT_SAMPLE_DATA = `
USE fashion_shop;

-- Insert Admin User (password: admin123)
INSERT INTO users (email, password, full_name, phone, role) VALUES
('admin@fashionshop.com', '$2a$10$YpruZm2tpXVg8UABcpQn0uZUqm8fZfRuxwNWVotXaQDFa0.r.Fazy', 'Administrator', '0901234567', 'admin');

-- Insert Categories
INSERT INTO categories (name, description, display_order) VALUES
('Áo Nam', 'Các loại áo thời trang nam', 1),
('Quần Nam', 'Các loại quần thời trang nam', 2),
('Áo Nữ', 'Các loại áo thời trang nữ', 3),
('Quần Nữ', 'Các loại quần thời trang nữ', 4),
('Phụ Kiện', 'Phụ kiện thời trang', 5),
('Giày Dép', 'Giày dép thời trang', 6);

-- Insert Sub Categories
INSERT INTO categories (name, description, parent_id, display_order) VALUES
('Áo Thun Nam', 'Áo thun nam các loại', 1, 1),
('Áo Sơ Mi Nam', 'Áo sơ mi nam các loại', 1, 2),
('Áo Khoác Nam', 'Áo khoác nam các loại', 1, 3),
('Quần Jean Nam', 'Quần jean nam các loại', 2, 1),
('Quần Tây Nam', 'Quần tây nam các loại', 2, 2),
('Quần Short Nam', 'Quần short nam các loại', 2, 3),
('Áo Thun Nữ', 'Áo thun nữ các loại', 3, 1),
('Áo Sơ Mi Nữ', 'Áo sơ mi nữ các loại', 3, 2),
('Đầm Váy', 'Đầm váy các loại', 3, 3),
('Quần Jean Nữ', 'Quần jean nữ các loại', 4, 1),
('Quần Tây Nữ', 'Quần tây nữ các loại', 4, 2),
('Chân Váy', 'Chân váy các loại', 4, 3);

-- Insert Sample Products (Áo Thun Nam - category_id = 7)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Áo Thun Nam Trơn Basic', 'Áo thun nam cổ tròn chất liệu cotton 100% thoáng mát, form regular phù hợp mọi vóc dáng', 149000, 129000, 7, 100, 'ATN001', 'Fashion Shop', 'Cotton 100%', TRUE, TRUE),
('Áo Thun Nam Có Cổ Polo', 'Áo thun polo nam cao cấp, chất liệu cotton pha polyester, không nhăn, không xù lông', 249000, 199000, 7, 80, 'ATN002', 'Fashion Shop', 'Cotton Polyester', TRUE, TRUE),
('Áo Thun Nam Tay Dài Oversize', 'Áo thun tay dài form oversize trendy, chất cotton mềm mại, phong cách Hàn Quốc', 189000, NULL, 7, 60, 'ATN003', 'Fashion Shop', 'Cotton', FALSE, TRUE),
('Áo Thun Nam In Hình', 'Áo thun in hình độc đáo, chất liệu cotton cao cấp, màu sắc bền đẹp', 169000, 149000, 7, 90, 'ATN004', 'Fashion Shop', 'Cotton', TRUE, TRUE);

-- Insert Sample Products (Áo Sơ Mi Nam - category_id = 8)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Áo Sơ Mi Nam Trắng Công Sở', 'Áo sơ mi trắng cao cấp, chất liệu kate mềm mịn, phù hợp môi trường công sở', 299000, 259000, 8, 70, 'ASM001', 'Fashion Shop', 'Kate', TRUE, TRUE),
('Áo Sơ Mi Nam Kẻ Sọc', 'Áo sơ mi kẻ sọc dọc thanh lịch, chất liệu oxford cao cấp, dễ phối đồ', 279000, NULL, 8, 65, 'ASM002', 'Fashion Shop', 'Oxford', FALSE, TRUE),
('Áo Sơ Mi Nam Denim', 'Áo sơ mi jeans phong cách năng động, chất vải bò cao cấp, không phai màu', 349000, 299000, 8, 50, 'ASM003', 'Fashion Shop', 'Denim', TRUE, TRUE);

-- Insert Sample Products (Quần Jean Nam - category_id = 10)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Quần Jean Nam Slim Fit', 'Quần jean nam form slim ôm vừa vặn, chất denim co giãn thoải mái, không bai không xù', 399000, 349000, 10, 85, 'QJN001', 'Fashion Shop', 'Denim Stretch', TRUE, TRUE),
('Quần Jean Nam Regular Fit', 'Quần jean form regular thoải mái, chất vải bò cao cấp, màu xanh đậm cổ điển', 379000, NULL, 10, 90, 'QJN002', 'Fashion Shop', 'Denim', FALSE, TRUE),
('Quần Jean Nam Rách Gối', 'Quần jean rách gối phong cách streetwear, chất liệu cao cấp, không nhão không giãn', 429000, 379000, 10, 60, 'QJN003', 'Fashion Shop', 'Denim', TRUE, TRUE);

-- Insert Sample Products (Áo Thun Nữ - category_id = 13)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Áo Thun Nữ Form Rộng', 'Áo thun nữ form rộng thoải mái, chất cotton mềm mại, phong cách Hàn Quốc', 139000, 119000, 13, 120, 'ATNW001', 'Fashion Shop', 'Cotton', TRUE, TRUE),
('Áo Thun Nữ Croptop', 'Áo croptop nữ sexy trendy, chất liệu cotton co giãn, ôm dáng nhẹ nhàng', 129000, NULL, 13, 95, 'ATNW002', 'Fashion Shop', 'Cotton Spandex', TRUE, TRUE),
('Áo Thun Nữ Tay Phồng', 'Áo thun tay phồng nữ tính, chất liệu cao cấp, thiết kế thanh lịch', 159000, 139000, 13, 75, 'ATNW003', 'Fashion Shop', 'Cotton', FALSE, TRUE);

-- Insert Sample Products (Đầm Váy - category_id = 15)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Đầm Váy Hoa Nhí Vintage', 'Đầm váy hoa nhí phong cách vintage nữ tính, chất vải voan mềm mại, dáng xòe nhẹ', 349000, 299000, 15, 55, 'DV001', 'Fashion Shop', 'Voan', TRUE, TRUE),
('Đầm Babydoll Trắng', 'Đầm babydoll trắng tinh khôi, chất liệu cotton cao cấp, dáng suông thoải mái', 289000, 249000, 15, 60, 'DV002', 'Fashion Shop', 'Cotton', TRUE, TRUE),
('Đầm Midi Công Sở', 'Đầm midi công sở thanh lịch, chất liệu kate cao cấp, form ôm vừa vặn', 399000, NULL, 15, 45, 'DV003', 'Fashion Shop', 'Kate', FALSE, TRUE);

-- Insert Sample Products (Quần Jean Nữ - category_id = 16)
INSERT INTO products (name, description, price, sale_price, category_id, stock_quantity, sku, brand, material, is_featured, is_active) VALUES
('Quần Jean Nữ Lưng Cao', 'Quần jean nữ lưng cao ôm dáng, chất denim co giãn tôn dáng, màu xanh nhạt trendy', 369000, 319000, 16, 80, 'QJNW001', 'Fashion Shop', 'Denim Stretch', TRUE, TRUE),
('Quần Jean Nữ Ống Rộng', 'Quần jean nữ ống rộng phong cách Hàn Quốc, chất liệu cao cấp, dễ mix đồ', 389000, 339000, 16, 70, 'QJNW002', 'Fashion Shop', 'Denim', TRUE, TRUE),
('Quần Jean Nữ Skinny', 'Quần jean nữ skinny ôm body, chất denim co giãn 4 chiều, tôn dáng tối đa', 349000, NULL, 16, 85, 'QJNW003', 'Fashion Shop', 'Denim Stretch', FALSE, TRUE);

-- Insert Sample Users (customers for testing - password: customer123)
INSERT INTO users (email, password, full_name, phone, role, address) VALUES
('user1@gmail.com', '$2a$10$Z0tXSg.GUvkxnZ9.zcHC9O5.l1r/bsj8m3u9tfvQuY0BYNRWD7TDO', 'Nguyễn Văn A', '0912345678', 'customer', 'Hà Nội'),
('user2@gmail.com', '$2a$10$Z0tXSg.GUvkxnZ9.zcHC9O5.l1r/bsj8m3u9tfvQuY0BYNRWD7TDO', 'Trần Thị B', '0923456789', 'customer', 'TP. Hồ Chí Minh'),
('user3@gmail.com', '$2a$10$Z0tXSg.GUvkxnZ9.zcHC9O5.l1r/bsj8m3u9tfvQuY0BYNRWD7TDO', 'Lê Văn C', '0934567890', 'customer', 'Đà Nẵng'),
('user4@gmail.com', '$2a$10$Z0tXSg.GUvkxnZ9.zcHC9O5.l1r/bsj8m3u9tfvQuY0BYNRWD7TDO', 'Phạm Thị D', '0945678901', 'customer', 'Hải Phòng'),
('user5@gmail.com', '$2a$10$Z0tXSg.GUvkxnZ9.zcHC9O5.l1r/bsj8m3u9tfvQuY0BYNRWD7TDO', 'Hoàng Văn E', '0956789012', 'customer', 'Cần Thơ');

-- Insert Product Images (3-4 images per product)
INSERT INTO product_images (product_id, image_url, is_primary, display_order) VALUES
-- Áo Thun Nam Trơn Basic (product_id = 1)
(1, 'https://product.hstatic.net/1000006063/product/den3_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(1, 'https://product.hstatic.net/1000006063/product/den5_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
(1, 'https://product.hstatic.net/1000006063/product/den7_5b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 3),
-- Áo Thun Nam Có Cổ Polo (product_id = 2)
(2, 'https://product.hstatic.net/1000006063/product/xanh1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(2, 'https://product.hstatic.net/1000006063/product/xanh2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
(2, 'https://product.hstatic.net/1000006063/product/xanh3_5b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 3),
-- Áo Thun Nam Tay Dài Oversize (product_id = 3)
(3, 'https://product.hstatic.net/1000006063/product/trang1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(3, 'https://product.hstatic.net/1000006063/product/trang2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Thun Nam In Hình (product_id = 4)
(4, 'https://product.hstatic.net/1000006063/product/do1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(4, 'https://product.hstatic.net/1000006063/product/do2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
(4, 'https://product.hstatic.net/1000006063/product/do3_5b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 3),
-- Áo Sơ Mi Nam Trắng (product_id = 5)
(5, 'https://product.hstatic.net/1000006063/product/trang1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(5, 'https://product.hstatic.net/1000006063/product/trang2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Sơ Mi Nam Kẻ Sọc (product_id = 6)
(6, 'https://product.hstatic.net/1000006063/product/soc1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(6, 'https://product.hstatic.net/1000006063/product/soc2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Sơ Mi Nam Denim (product_id = 7)
(7, 'https://product.hstatic.net/1000006063/product/denim1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(7, 'https://product.hstatic.net/1000006063/product/denim2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nam Slim Fit (product_id = 8)
(8, 'https://product.hstatic.net/1000006063/product/jean1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(8, 'https://product.hstatic.net/1000006063/product/jean2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nam Regular Fit (product_id = 9)
(9, 'https://product.hstatic.net/1000006063/product/jean3_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(9, 'https://product.hstatic.net/1000006063/product/jean4_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nam Rách Gối (product_id = 10)
(10, 'https://product.hstatic.net/1000006063/product/jean5_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(10, 'https://product.hstatic.net/1000006063/product/jean6_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Thun Nữ Form Rộng (product_id = 11)
(11, 'https://product.hstatic.net/1000006063/product/nu1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(11, 'https://product.hstatic.net/1000006063/product/nu2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Thun Nữ Croptop (product_id = 12)
(12, 'https://product.hstatic.net/1000006063/product/crop1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(12, 'https://product.hstatic.net/1000006063/product/crop2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Áo Thun Nữ Tay Phồng (product_id = 13)
(13, 'https://product.hstatic.net/1000006063/product/phong1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(13, 'https://product.hstatic.net/1000006063/product/phong2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Đầm Váy Hoa Nhí (product_id = 14)
(14, 'https://product.hstatic.net/1000006063/product/dam1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(14, 'https://product.hstatic.net/1000006063/product/dam2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
(14, 'https://product.hstatic.net/1000006063/product/dam3_5b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 3),
-- Đầm Babydoll Trắng (product_id = 15)
(15, 'https://product.hstatic.net/1000006063/product/baby1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(15, 'https://product.hstatic.net/1000006063/product/baby2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Đầm Midi Công Sở (product_id = 16)
(16, 'https://product.hstatic.net/1000006063/product/midi1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(16, 'https://product.hstatic.net/1000006063/product/midi2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nữ Lưng Cao (product_id = 17)
(17, 'https://product.hstatic.net/1000006063/product/jeanu1_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(17, 'https://product.hstatic.net/1000006063/product/jeanu2_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nữ Ống Rộng (product_id = 18)
(18, 'https://product.hstatic.net/1000006063/product/jeanu3_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(18, 'https://product.hstatic.net/1000006063/product/jeanu4_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2),
-- Quần Jean Nữ Skinny (product_id = 19)
(19, 'https://product.hstatic.net/1000006063/product/jeanu5_9b5e2c8296084c82ab88f0e541b0a60c_grande.jpg', TRUE, 1),
(19, 'https://product.hstatic.net/1000006063/product/jeanu6_2b4e3c8296084c82ab88f0e541b0a60c_grande.jpg', FALSE, 2);

-- Insert Product Variants (Size and Color variations)
INSERT INTO product_variants (product_id, size, color, stock_quantity, sku) VALUES
-- Áo Thun Nam Trơn Basic (product_id = 1)
(1, 'S', 'Đen', 20, 'ATN001-S-DEN'),
(1, 'M', 'Đen', 30, 'ATN001-M-DEN'),
(1, 'L', 'Đen', 25, 'ATN001-L-DEN'),
(1, 'XL', 'Đen', 15, 'ATN001-XL-DEN'),
(1, 'S', 'Trắng', 20, 'ATN001-S-TRANG'),
(1, 'M', 'Trắng', 30, 'ATN001-M-TRANG'),
(1, 'L', 'Trắng', 25, 'ATN001-L-TRANG'),
-- Áo Thun Nam Có Cổ Polo (product_id = 2)
(2, 'M', 'Xanh Navy', 25, 'ATN002-M-XANH'),
(2, 'L', 'Xanh Navy', 30, 'ATN002-L-XANH'),
(2, 'XL', 'Xanh Navy', 15, 'ATN002-XL-XANH'),
(2, 'M', 'Đen', 20, 'ATN002-M-DEN'),
(2, 'L', 'Đen', 25, 'ATN002-L-DEN'),
-- Quần Jean Nam Slim Fit (product_id = 8)
(8, '29', 'Xanh Đậm', 20, 'QJN001-29-XANH'),
(8, '30', 'Xanh Đậm', 25, 'QJN001-30-XANH'),
(8, '31', 'Xanh Đậm', 20, 'QJN001-31-XANH'),
(8, '32', 'Xanh Đậm', 15, 'QJN001-32-XANH'),
(8, '33', 'Xanh Đậm', 10, 'QJN001-33-XANH'),
-- Áo Thun Nữ Form Rộng (product_id = 11)
(11, 'S', 'Trắng', 30, 'ATNW001-S-TRANG'),
(11, 'M', 'Trắng', 40, 'ATNW001-M-TRANG'),
(11, 'L', 'Trắng', 30, 'ATNW001-L-TRANG'),
(11, 'S', 'Đen', 25, 'ATNW001-S-DEN'),
(11, 'M', 'Đen', 35, 'ATNW001-M-DEN'),
-- Đầm Váy Hoa Nhí (product_id = 14)
(14, 'S', 'Hoa Nhí', 15, 'DV001-S-HOA'),
(14, 'M', 'Hoa Nhí', 20, 'DV001-M-HOA'),
(14, 'L', 'Hoa Nhí', 15, 'DV001-L-HOA'),
-- Quần Jean Nữ Lưng Cao (product_id = 17)
(17, '26', 'Xanh Nhạt', 20, 'QJNW001-26-XANH'),
(17, '27', 'Xanh Nhạt', 25, 'QJNW001-27-XANH'),
(17, '28', 'Xanh Nhạt', 20, 'QJNW001-28-XANH'),
(17, '29', 'Xanh Nhạt', 15, 'QJNW001-29-XANH');

-- Insert Sample Reviews
INSERT INTO reviews (product_id, user_id, rating, comment, helpful_count, created_at) VALUES
(1, 2, 5, 'Áo rất đẹp và chất lượng tốt, vải cotton mềm mại, mặc rất thoải mái. Sẽ ủng hộ shop tiếp!', 15, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(1, 3, 4, 'Áo đẹp, form chuẩn. Tuy nhiên màu hơi nhạt hơn so với hình. Nhưng nhìn chung vẫn ok!', 8, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(1, 4, 5, 'Chất lượng tốt, giá cả hợp lý. Đóng gói cẩn thận, giao hàng nhanh. Rất hài lòng!', 12, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 2, 5, 'Áo polo rất đẹp và sang trọng. Mặc đi làm rất phù hợp. Vải không nhăn, dễ giặt!', 10, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(2, 5, 4, 'Áo đẹp nhưng hơi rộng một chút. Nên mua nhỏ hơn 1 size. Chất lượng tốt!', 6, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(8, 3, 5, 'Quần jean rất đẹp, chất denim co giãn tốt. Form slim vừa vặn, không bị bó. Rất thích!', 18, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8, 4, 5, 'Quần đẹp, chất lượng tốt. Màu xanh đậm rất đẹp. Giao hàng nhanh. Sẽ mua thêm!', 14, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(8, 5, 4, 'Quần đẹp nhưng hơi dài. Phải đi sửa lại. Chất lượng vải tốt, không bai không xù!', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(11, 2, 5, 'Áo form rộng rất đẹp, mặc thoải mái. Vải cotton mềm mại. Rất hài lòng với sản phẩm!', 20, DATE_SUB(NOW(), INTERVAL 11 DAY)),
(11, 3, 5, 'Áo đẹp, chất lượng tốt. Form oversize vừa vặn, không quá rộng. Sẽ mua thêm màu khác!', 16, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(14, 4, 5, 'Đầm rất đẹp, họa tiết hoa nhí xinh xắn. Vải voan mềm mại, mặc rất mát. Rất thích!', 22, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(14, 5, 4, 'Đầm đẹp nhưng hơi mỏng. Nên mặc lót bên trong. Chất lượng tốt, giá hợp lý!', 9, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(17, 2, 5, 'Quần jean lưng cao rất đẹp, tôn dáng. Chất denim co giãn tốt. Rất hài lòng!', 17, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(17, 3, 5, 'Quần đẹp, form chuẩn. Màu xanh nhạt rất trendy. Chất lượng tốt, giá ok!', 13, DATE_SUB(NOW(), INTERVAL 10 DAY));

-- Insert Sample Wishlists
INSERT INTO wishlists (user_id, product_id) VALUES
(2, 3),
(2, 7),
(2, 10),
(2, 15),
(3, 1),
(3, 8),
(3, 14),
(4, 2),
(4, 11),
(4, 17),
(5, 5),
(5, 12),
(5, 18);

-- Insert Sample Favorites
INSERT INTO favorites (user_id, product_id) VALUES
(2, 1),
(2, 8),
(2, 14),
(3, 2),
(3, 11),
(4, 1),
(4, 17),
(5, 8),
(5, 14);
`;

async function initDatabase() {
  let connection;
  
  try {
    console.log('🚀 Starting database initialization...\n');
    
    // Connect without database selection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT || 3306,
      multipleStatements: true
    });

    console.log('✅ Connected to MySQL server');

    // Create database
    console.log('📦 Creating database...');
    await connection.query(SQL_CREATE_DATABASE);
    console.log('✅ Database created/verified\n');

    // Create tables
    console.log('📋 Creating tables...');
    await connection.query(SQL_CREATE_TABLES);
    console.log('✅ Tables created successfully\n');

    // Insert sample data
    console.log('📝 Inserting sample data...');
    await connection.query(SQL_INSERT_SAMPLE_DATA);
    console.log('✅ Sample data inserted\n');

    console.log('🎉 Database initialization completed successfully!');
    console.log('\n📊 Database Summary:');
    console.log('   - Database: fashion_shop');
    console.log('   - Tables: 15 tables created');
    console.log('   - Admin user: admin@fashionshop.com / admin123');
    console.log('   - Categories: 18 categories (6 main + 12 sub)');
    console.log('   - Products: 20 sample products added');
    console.log('\n💡 You can now start the server with: npm run dev\n');

  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    console.error(error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

initDatabase();
