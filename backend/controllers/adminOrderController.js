const Order = require('../models/Order');
const emailService = require('../services/emailService');
const db = require('../config/database');

class AdminOrderController {
  // GET /api/admin/orders?page=1&limit=20&status=all&search=
  async getOrders(req, res) {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      const status = req.query.status;
      const search = req.query.search;
      const offset = (page - 1) * limit;

      const conn = await db.getConnection();

      try {
        // Build query - Use table alias consistently
        let baseQuery = `
          SELECT o.id, o.order_number, o.user_id, o.status, o.payment_method, 
                 o.payment_status, o.subtotal, o.shipping_fee, o.discount_amount, 
                 o.total_amount, o.customer_name, o.customer_phone, o.customer_email,
                 o.shipping_address, o.shipping_city, o.shipping_district, o.shipping_ward,
                 o.notes, o.created_at, o.updated_at,
                 u.email as user_email, 
                 u.full_name as user_full_name,
                 u.phone as user_phone,
                 COUNT(oi.id) as item_count
          FROM orders o
          LEFT JOIN users u ON o.user_id = u.id
          LEFT JOIN order_items oi ON o.id = oi.order_id
          WHERE o.deleted_at IS NULL
        `;
        const params = [];

        // Filter by status
        if (status && status !== 'all') {
          baseQuery += ' AND o.status = ?';
          params.push(status);
        }

        // Search by order number, customer name, phone, or email
        if (search && search.trim()) {
          baseQuery += ` AND (
            o.order_number LIKE ? OR 
            o.customer_name LIKE ? OR 
            o.customer_phone LIKE ? OR 
            o.customer_email LIKE ? OR
            u.email LIKE ?
          )`;
          const searchTerm = `%${search.trim()}%`;
          params.push(searchTerm, searchTerm, searchTerm, searchTerm, searchTerm);
        }

        baseQuery += ' GROUP BY o.id';

        // Get total count from the base query
        const countQuery = `SELECT COUNT(*) as total FROM (${baseQuery}) as subquery`;
        const [countResult] = await conn.query(countQuery, params);
        const total = countResult[0].total;

        // Add sorting and pagination to base query
        const query = baseQuery + ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
        params.push(limit, offset);

        // Get orders
        const [orders] = await conn.query(query, params);

        // Get items for each order
        const ordersWithItems = await Promise.all(
          orders.map(async (order) => {
            const [items] = await conn.query(
              `SELECT oi.*,
               (SELECT image_url FROM product_images WHERE product_id = oi.product_id AND is_primary = 1 LIMIT 1) as product_image
               FROM order_items oi
               WHERE oi.order_id = ?`,
              [order.id]
            );

            return {
              id: order.id,
              orderNumber: order.order_number,
              user: {
                id: order.user_id,
                name: order.user_full_name,
                email: order.user_email,
                phone: order.user_phone
              },
              items: items.map(item => ({
                id: item.id,
                productId: item.product_id,
                productName: item.product_name,
                variantInfo: item.variant_info,
                quantity: item.quantity,
                price: parseFloat(item.price),
                subtotal: parseFloat(item.subtotal),
                productImage: item.product_image
              })),
              subtotal: parseFloat(order.subtotal),
              shippingFee: parseFloat(order.shipping_fee),
              discountAmount: parseFloat(order.discount_amount),
              totalAmount: parseFloat(order.total_amount),
              status: order.status,
              paymentMethod: order.payment_method,
              paymentStatus: order.payment_status,
              customerName: order.customer_name,
              customerPhone: order.customer_phone,
              customerEmail: order.customer_email,
              shippingAddress: order.shipping_address,
              shippingCity: order.shipping_city,
              shippingDistrict: order.shipping_district,
              shippingWard: order.shipping_ward,
              notes: order.notes,
              itemCount: parseInt(order.item_count),
              createdAt: order.created_at,
              updatedAt: order.updated_at
            };
          })
        );

        const totalPages = Math.ceil(total / limit);

        res.json({
          success: true,
          data: {
            orders: ordersWithItems,
            pagination: {
              total,
              page,
              limit,
              totalPages
            }
          }
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getOrders:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy danh sách đơn hàng',
        error: error.message
      });
    }
  }

  // GET /api/admin/orders/:id
  async getOrderById(req, res) {
    try {
      const { id } = req.params;
      const conn = await db.getConnection();

      try {
        // Get order with full user info
        const [orders] = await conn.query(
          `SELECT o.*,
            u.id as user_id,
            u.email as user_email,
            u.full_name as user_full_name,
            u.phone as user_phone,
            u.avatar as user_avatar,
            u.created_at as user_created_at
           FROM orders o
           LEFT JOIN users u ON o.user_id = u.id
           WHERE o.id = ? AND o.deleted_at IS NULL`,
          [id]
        );

        if (orders.length === 0) {
          return res.status(404).json({
            success: false,
            message: 'Không tìm thấy đơn hàng'
          });
        }

        const order = orders[0];

        // Get order items
        const [items] = await conn.query(
          `SELECT oi.*,
           p.id as product_id,
           p.name as product_name,
           p.sku as product_sku,
           (SELECT image_url FROM product_images WHERE product_id = oi.product_id AND is_primary = 1 LIMIT 1) as product_image
           FROM order_items oi
           LEFT JOIN products p ON oi.product_id = p.id
           WHERE oi.order_id = ?`,
          [id]
        );

        // Build order history/timeline from timestamp columns
        const history = [];
        
        // Created
        if (order.created_at) {
          history.push({
            id: null,
            status: 'pending',
            notes: 'Đơn hàng được tạo',
            createdBy: order.user_id,
            createdAt: order.created_at
          });
        }
        
        // Confirmed
        if (order.confirmed_at) {
          history.push({
            id: null,
            status: 'confirmed',
            notes: 'Đơn hàng đã được xác nhận',
            createdBy: null,
            createdAt: order.confirmed_at
          });
        }
        
        // Shipped
        if (order.shipped_at) {
          history.push({
            id: null,
            status: 'shipping',
            notes: 'Đơn hàng đang được giao',
            createdBy: null,
            createdAt: order.shipped_at
          });
        }
        
        // Delivered
        if (order.delivered_at) {
          history.push({
            id: null,
            status: 'delivered',
            notes: 'Đơn hàng đã được giao thành công',
            createdBy: null,
            createdAt: order.delivered_at
          });
        }
        
        // Cancelled
        if (order.cancelled_at) {
          history.push({
            id: null,
            status: 'cancelled',
            notes: order.cancelled_reason || 'Đơn hàng đã bị hủy',
            createdBy: null,
            createdAt: order.cancelled_at
          });
        }
        
        // Sort by createdAt
        history.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));

        res.json({
          success: true,
          data: {
            id: order.id,
            orderNumber: order.order_number,
            user: {
              id: order.user_id,
              name: order.user_full_name,
              email: order.user_email,
              phone: order.user_phone,
              avatar: order.user_avatar,
              memberSince: order.user_created_at
            },
            items: items.map(item => ({
              id: item.id,
              productId: item.product_id,
              productName: item.product_name,
              productSku: item.product_sku,
              variantInfo: item.variant_info,
              quantity: item.quantity,
              price: parseFloat(item.price),
              subtotal: parseFloat(item.subtotal),
              productImage: item.product_image
            })),
            subtotal: parseFloat(order.subtotal),
            shippingFee: parseFloat(order.shipping_fee),
            discountAmount: parseFloat(order.discount_amount),
            totalAmount: parseFloat(order.total_amount),
            status: order.status,
            paymentMethod: order.payment_method,
            paymentStatus: order.payment_status,
            customerName: order.customer_name,
            customerPhone: order.customer_phone,
            customerEmail: order.customer_email,
            shippingAddress: order.shipping_address,
            shippingCity: order.shipping_city,
            shippingDistrict: order.shipping_district,
            shippingWard: order.shipping_ward,
            notes: order.notes,
            itemCount: items.length,
            history: history.map(h => ({
              id: h.id,
              status: h.status,
              notes: h.notes,
              createdBy: h.createdBy,
              createdAt: h.createdAt
            })),
            createdAt: order.created_at,
            updatedAt: order.updated_at
          }
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getOrderById:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy chi tiết đơn hàng',
        error: error.message
      });
    }
  }

  // PUT /api/admin/orders/:id/status
  async updateOrderStatus(req, res) {
    try {
      const { id } = req.params;
      const { status, notes } = req.body;

      // Validate status
      const validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: `Trạng thái không hợp lệ. Chỉ chấp nhận: ${validStatuses.join(', ')}`
        });
      }

      const conn = await db.getConnection();

      try {
        // Get current order
        const [orders] = await conn.query(
          `SELECT o.*, u.email as user_email, u.full_name as user_full_name
           FROM orders o
           LEFT JOIN users u ON o.user_id = u.id
           WHERE o.id = ? AND o.deleted_at IS NULL`,
          [id]
        );

        if (orders.length === 0) {
          return res.status(404).json({
            success: false,
            message: 'Không tìm thấy đơn hàng'
          });
        }

        const order = orders[0];
        const oldStatus = order.status;

        // Check if status change is valid
        if (oldStatus === status) {
          return res.status(400).json({
            success: false,
            message: 'Trạng thái mới giống trạng thái hiện tại'
          });
        }

        // Prevent changing status of cancelled or delivered orders
        if (oldStatus === 'delivered' || oldStatus === 'cancelled') {
          return res.status(400).json({
            success: false,
            message: `Không thể thay đổi trạng thái đơn hàng đã ${oldStatus === 'delivered' ? 'giao' : 'hủy'}`
          });
        }

        await conn.beginTransaction();

        try {
          // Determine which timestamp column to update based on status
          let timestampColumn = null;
          switch (status) {
            case 'confirmed':
              timestampColumn = 'confirmed_at';
              break;
            case 'processing':
              // No specific timestamp column
              break;
            case 'shipped':
              timestampColumn = 'shipped_at';
              break;
            case 'delivered':
              timestampColumn = 'delivered_at';
              break;
            case 'cancelled':
              timestampColumn = 'cancelled_at';
              break;
          }

          // Update order status
          let updateQuery = 'UPDATE orders SET status = ?, updated_at = NOW()';
          let updateParams = [status];

          // Add timestamp column if applicable
          if (timestampColumn) {
            updateQuery += `, ${timestampColumn} = NOW()`;
          }

          // Add cancelled_reason if provided and status is cancelled
          if (status === 'cancelled' && notes) {
            updateQuery += ', cancelled_reason = ?';
            updateParams.push(notes);
          }

          updateQuery += ' WHERE id = ?';
          updateParams.push(id);

          await conn.query(updateQuery, updateParams);

          // If cancelled, restore product stock
          if (status === 'cancelled' && oldStatus !== 'cancelled') {
            const [items] = await conn.query(
              'SELECT product_id, quantity FROM order_items WHERE order_id = ?',
              [id]
            );

            for (const item of items) {
              await conn.query(
                'UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?',
                [item.quantity, item.product_id]
              );
            }
          }

          await conn.commit();

          // Send email notification
          try {
            const statusMessages = {
              pending: 'đang chờ xác nhận',
              processing: 'đang được xử lý',
              shipped: 'đang được giao',
              delivered: 'đã được giao thành công',
              cancelled: 'đã bị hủy'
            };

            const statusTexts = {
              pending: 'Chờ xác nhận',
              processing: 'Đang xử lý',
              shipped: 'Đang giao',
              delivered: 'Đã giao',
              cancelled: 'Đã hủy'
            };

            await emailService.sendEmail({
              to: order.customer_email || order.user_email,
              subject: `Cập nhật trạng thái đơn hàng #${order.order_number}`,
              html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                  <h2 style="color: #2196F3;">Cập Nhật Đơn Hàng</h2>
                  <p>Xin chào <strong>${order.customer_name}</strong>,</p>
                  <p>Đơn hàng <strong>#${order.order_number}</strong> của bạn ${statusMessages[status]}.</p>
                  ${notes ? `<p><strong>Ghi chú:</strong> ${notes}</p>` : ''}
                  <div style="margin: 20px 0; padding: 15px; background-color: #f5f5f5; border-radius: 5px;">
                    <p style="margin: 5px 0;"><strong>Trạng thái:</strong> ${statusTexts[status] || status}</p>
                    <p style="margin: 5px 0;"><strong>Tổng tiền:</strong> ${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(order.total_amount)}</p>
                  </div>
                  <p>Cảm ơn bạn đã mua sắm tại Fashion Shop!</p>
                </div>
              `
            });
          } catch (emailError) {
            console.error('Error sending email:', emailError);
            // Continue even if email fails
          }

          res.json({
            success: true,
            message: 'Cập nhật trạng thái đơn hàng thành công',
            data: {
              id: parseInt(id),
              status,
              oldStatus
            }
          });
        } catch (error) {
          await conn.rollback();
          throw error;
        }
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in updateOrderStatus:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi cập nhật trạng thái đơn hàng',
        error: error.message
      });
    }
  }

  // DELETE /api/admin/orders/:id (soft delete)
  async deleteOrder(req, res) {
    try {
      const { id } = req.params;
      const conn = await db.getConnection();

      try {
        // Check if order exists
        const [orders] = await conn.query(
          'SELECT * FROM orders WHERE id = ? AND deleted_at IS NULL',
          [id]
        );

        if (orders.length === 0) {
          return res.status(404).json({
            success: false,
            message: 'Không tìm thấy đơn hàng'
          });
        }

        const order = orders[0];

        // Only allow deleting pending or cancelled orders
        if (order.status !== 'pending' && order.status !== 'cancelled') {
          return res.status(400).json({
            success: false,
            message: 'Chỉ có thể xóa đơn hàng ở trạng thái chờ xác nhận hoặc đã hủy'
          });
        }

        // Soft delete
        await conn.query(
          'UPDATE orders SET deleted_at = NOW() WHERE id = ?',
          [id]
        );

        res.json({
          success: true,
          message: 'Xóa đơn hàng thành công'
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in deleteOrder:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi xóa đơn hàng',
        error: error.message
      });
    }
  }

  // GET /api/admin/orders/export?format=csv
  async exportOrders(req, res) {
    try {
      const format = req.query.format || 'csv';
      const status = req.query.status;
      const search = req.query.search;

      if (format !== 'csv') {
        return res.status(400).json({
          success: false,
          message: 'Hiện tại chỉ hỗ trợ format CSV'
        });
      }

      const conn = await db.getConnection();

      try {
        // Build query (same as getOrders but without pagination)
        let query = `
          SELECT o.*, 
            u.email as user_email, 
            u.full_name as user_full_name,
            u.phone as user_phone,
            COUNT(oi.id) as item_count
          FROM orders o
          LEFT JOIN users u ON o.user_id = u.id
          LEFT JOIN order_items oi ON o.id = oi.order_id
          WHERE o.deleted_at IS NULL
        `;
        const params = [];

        if (status && status !== 'all') {
          query += ' AND o.status = ?';
          params.push(status);
        }

        if (search && search.trim()) {
          query += ` AND (
            o.order_number LIKE ? OR 
            o.customer_name LIKE ? OR 
            o.customer_phone LIKE ?
          )`;
          const searchTerm = `%${search.trim()}%`;
          params.push(searchTerm, searchTerm, searchTerm);
        }

        query += ' GROUP BY o.id ORDER BY o.created_at DESC';

        const [orders] = await conn.query(query, params);

        // Generate CSV
        const csvRows = [];
        
        // Header
        csvRows.push([
          'Mã đơn hàng',
          'Khách hàng',
          'Email',
          'Số điện thoại',
          'Số lượng SP',
          'Tổng tiền',
          'Trạng thái',
          'Phương thức TT',
          'Địa chỉ',
          'Ngày tạo'
        ].join(','));

        // Data rows
        orders.forEach(order => {
          const row = [
            order.order_number,
            `"${order.customer_name}"`,
            order.customer_email || order.user_email || '',
            order.customer_phone || order.user_phone || '',
            order.item_count,
            order.total_amount,
            this._getStatusText(order.status),
            this._getPaymentMethodText(order.payment_method),
            `"${this._getFullAddress(order)}"`,
            new Date(order.created_at).toLocaleString('vi-VN')
          ];
          csvRows.push(row.join(','));
        });

        const csvContent = csvRows.join('\n');

        // Set headers for file download
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="orders_${Date.now()}.csv"`);
        
        // Add BOM for UTF-8 to support Vietnamese characters in Excel
        res.write('\uFEFF');
        res.write(csvContent);
        res.end();
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in exportOrders:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi xuất danh sách đơn hàng',
        error: error.message
      });
    }
  }

  // Helper methods
  _getStatusText(status) {
    const statusMap = {
      pending: 'Chờ xác nhận',
      processing: 'Đang xử lý',
      shipped: 'Đang giao',
      delivered: 'Đã giao',
      cancelled: 'Đã hủy'
    };
    return statusMap[status] || status;
  }

  _getPaymentMethodText(method) {
    const methodMap = {
      cod: 'Thanh toán khi nhận hàng',
      bank_transfer: 'Chuyển khoản ngân hàng',
      momo: 'Ví MoMo',
      vnpay: 'VNPay'
    };
    return methodMap[method] || method;
  }

  _getFullAddress(order) {
    const parts = [
      order.shipping_address,
      order.shipping_ward,
      order.shipping_district,
      order.shipping_city
    ].filter(Boolean);
    return parts.join(', ');
  }
}

module.exports = new AdminOrderController();
