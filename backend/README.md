# Fashion Shop Backend API

Backend API cho ứng dụng Fashion Shop được xây dựng với Node.js, Express và MySQL.

## Yêu cầu

- Node.js >= 14.x
- MySQL >= 5.7 hoặc MySQL 8.x (XAMPP)
- npm hoặc yarn

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Cấu hình database:
- Khởi động XAMPP và bật MySQL
- Copy file `.env.example` thành `.env`
- Cập nhật thông tin database trong file `.env`

3. Khởi tạo database:
```bash
npm run init-db
```

4. Chạy server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký tài khoản
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/profile` - Lấy thông tin profile
- `PUT /api/auth/profile` - Cập nhật profile
- `PUT /api/auth/change-password` - Đổi mật khẩu

### Categories
- `GET /api/categories` - Lấy danh sách danh mục
- `GET /api/categories/tree` - Lấy cây danh mục
- `GET /api/categories/:id` - Lấy chi tiết danh mục
- `POST /api/categories` - Tạo danh mục (Admin)
- `PUT /api/categories/:id` - Cập nhật danh mục (Admin)
- `DELETE /api/categories/:id` - Xóa danh mục (Admin)

### Products
- `GET /api/products` - Lấy danh sách sản phẩm
- `GET /api/products/featured` - Lấy sản phẩm nổi bật
- `GET /api/products/brands` - Lấy danh sách thương hiệu
- `GET /api/products/:id` - Lấy chi tiết sản phẩm
- `POST /api/products` - Tạo sản phẩm (Admin)
- `PUT /api/products/:id` - Cập nhật sản phẩm (Admin)
- `DELETE /api/products/:id` - Xóa sản phẩm (Admin)

### Cart
- `GET /api/cart` - Lấy giỏ hàng
- `POST /api/cart/items` - Thêm sản phẩm vào giỏ
- `PUT /api/cart/items/:id` - Cập nhật số lượng
- `DELETE /api/cart/items/:id` - Xóa sản phẩm khỏi giỏ
- `DELETE /api/cart/clear` - Xóa toàn bộ giỏ hàng

### Orders
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders/my-orders` - Lấy đơn hàng của tôi
- `GET /api/orders/:id` - Lấy chi tiết đơn hàng
- `PUT /api/orders/:id/cancel` - Hủy đơn hàng
- `GET /api/orders` - Lấy tất cả đơn hàng (Admin)
- `PUT /api/orders/:id/status` - Cập nhật trạng thái đơn hàng (Admin)
- `GET /api/orders/statistics/summary` - Thống kê đơn hàng (Admin)

## Database Schema

Database bao gồm các bảng:
- users - Người dùng
- categories - Danh mục sản phẩm
- products - Sản phẩm
- product_images - Hình ảnh sản phẩm
- product_variants - Biến thể sản phẩm (size, màu)
- carts - Giỏ hàng
- cart_items - Sản phẩm trong giỏ
- orders - Đơn hàng
- order_items - Sản phẩm trong đơn hàng
- reviews - Đánh giá sản phẩm
- favorites - Yêu thích
- notifications - Thông báo
- addresses - Địa chỉ giao hàng
- coupons - Mã giảm giá

## Tài khoản mặc định

- Email: admin@fashionshop.com
- Password: admin123
