const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const emailService = require('../services/emailService');

class OrderController {
  async create(req, res) {
    try {
      const {
        items,
        payment_method,
        shipping_address,
        shipping_city,
        shipping_district,
        shipping_ward,
        customer_name,
        customer_phone,
        customer_email,
        notes
      } = req.body;

      // Validate items
      if (!items || items.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Giỏ hàng trống'
        });
      }

      // Calculate totals and prepare order items
      let subtotal = 0;
      const orderItems = [];

      for (const item of items) {
        const product = await Product.findById(item.product_id);
        
        if (!product || !product.is_active) {
          return res.status(400).json({
            success: false,
            message: `Sản phẩm ${product?.name || item.product_id} không khả dụng`
          });
        }

        if (product.stock_quantity < item.quantity) {
          return res.status(400).json({
            success: false,
            message: `Sản phẩm ${product.name} không đủ số lượng`
          });
        }

        const price = product.sale_price || product.price;
        const itemSubtotal = price * item.quantity;
        subtotal += itemSubtotal;

        orderItems.push({
          product_id: product.id,
          variant_id: item.variant_id || null,
          product_name: product.name,
          variant_info: item.variant_info || null,
          quantity: item.quantity,
          price: price,
          subtotal: itemSubtotal
        });
      }

      // Calculate shipping and total
      const shipping_fee = subtotal >= 500000 ? 0 : 30000;
      const discount_amount = 0;
      const total_amount = subtotal + shipping_fee - discount_amount;

      // Generate order number
      const order_number = await Order.generateOrderNumber();

      // Create order
      const orderId = await Order.create({
        user_id: req.user.id,
        order_number,
        subtotal,
        shipping_fee,
        discount_amount,
        total_amount,
        payment_method: payment_method || 'cod',
        customer_name: customer_name || req.user.full_name,
        customer_phone: customer_phone || req.user.phone,
        customer_email: customer_email || req.user.email,
        shipping_address,
        shipping_city,
        shipping_district,
        shipping_ward,
        notes
      });

      // Add order items
      await Order.addItems(orderId, orderItems);

      // Update product stock
      for (const item of orderItems) {
        await Product.updateStock(item.product_id, item.quantity, 'subtract');
        await Product.updateSoldQuantity(item.product_id, item.quantity);
      }

      // Clear cart
      const cart = await Cart.findOrCreateByUserId(req.user.id);
      await Cart.clearCart(cart.id);

      // Get complete order
      const order = await Order.findById(orderId);
      const items_detail = await Order.getOrderItems(orderId);

      // Send order confirmation email (async, don't wait)
      if (customer_email || req.user.email) {
        emailService.sendOrderConfirmation(
          { ...order, items: items_detail },
          customer_email || req.user.email
        ).catch(err => console.error('Email send error:', err));
      }

      res.status(201).json({
        success: true,
        message: 'Đặt hàng thành công',
        data: {
          order,
          items: items_detail
        }
      });
    } catch (error) {
      console.error('Create order error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi tạo đơn hàng'
      });
    }
  }

  async getMyOrders(req, res) {
    try {
      const { status, page = 1, limit = 10 } = req.query;

      const filters = {
        status,
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      };

      const orders = await Order.findByUserId(req.user.id, filters);
      const total = await Order.count({ user_id: req.user.id, status });

      res.json({
        success: true,
        data: {
          orders,
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total_items: total,
            total_pages: Math.ceil(total / parseInt(limit))
          }
        }
      });
    } catch (error) {
      console.error('Get my orders error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách đơn hàng'
      });
    }
  }

  async getOrderDetail(req, res) {
    try {
      const { id } = req.params;
      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Đơn hàng không tồn tại'
        });
      }

      // Check permission
      if (order.user_id !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền xem đơn hàng này'
        });
      }

      const items = await Order.getOrderItems(id);

      res.json({
        success: true,
        data: {
          order,
          items
        }
      });
    } catch (error) {
      console.error('Get order detail error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thông tin đơn hàng'
      });
    }
  }

  async cancelOrder(req, res) {
    try {
      const { id } = req.params;
      const { reason } = req.body;

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Đơn hàng không tồn tại'
        });
      }

      // Check permission
      if (order.user_id !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Bạn không có quyền hủy đơn hàng này'
        });
      }

      // Check if order can be cancelled
      if (!['pending', 'confirmed'].includes(order.status)) {
        return res.status(400).json({
          success: false,
          message: 'Không thể hủy đơn hàng ở trạng thái này'
        });
      }

      // Update order status
      await Order.updateStatus(id, 'cancelled', { cancelled_reason: reason });

      // Restore product stock
      const items = await Order.getOrderItems(id);
      for (const item of items) {
        await Product.updateStock(item.product_id, item.quantity, 'add');
        await Product.updateSoldQuantity(item.product_id, -item.quantity);
      }

      const updatedOrder = await Order.findById(id);

      res.json({
        success: true,
        message: 'Hủy đơn hàng thành công',
        data: updatedOrder
      });
    } catch (error) {
      console.error('Cancel order error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi hủy đơn hàng'
      });
    }
  }

  // Admin endpoints
  async getAllOrders(req, res) {
    try {
      const {
        status,
        payment_status,
        search,
        from_date,
        to_date,
        page = 1,
        limit = 20
      } = req.query;

      const filters = {
        status,
        payment_status,
        search,
        from_date,
        to_date,
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      };

      const orders = await Order.findAll(filters);
      const total = await Order.count(filters);

      res.json({
        success: true,
        data: {
          orders,
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total_items: total,
            total_pages: Math.ceil(total / parseInt(limit))
          }
        }
      });
    } catch (error) {
      console.error('Get all orders error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách đơn hàng'
      });
    }
  }

  async updateOrderStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Đơn hàng không tồn tại'
        });
      }

      await Order.updateStatus(id, status);
      const updatedOrder = await Order.findById(id);

      // Send status update email (async, don't wait)
      if (order.customer_email) {
        emailService.sendOrderStatusUpdate(
          updatedOrder,
          order.customer_email,
          status
        ).catch(err => console.error('Email send error:', err));
      }

      res.json({
        success: true,
        message: 'Cập nhật trạng thái đơn hàng thành công',
        data: updatedOrder
      });
    } catch (error) {
      console.error('Update order status error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật trạng thái đơn hàng'
      });
    }
  }

  async getStatistics(req, res) {
    try {
      const { from_date, to_date } = req.query;
      const statistics = await Order.getStatistics({ from_date, to_date });

      res.json({
        success: true,
        data: statistics
      });
    } catch (error) {
      console.error('Get order statistics error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thống kê đơn hàng'
      });
    }
  }
}

module.exports = new OrderController();
