const db = require('../config/database');

class Order {
  static async create(orderData) {
    const {
      user_id, order_number, subtotal, shipping_fee, discount_amount, total_amount,
      payment_method, customer_name, customer_phone, customer_email,
      shipping_address, shipping_city, shipping_district, shipping_ward, notes
    } = orderData;

    const [result] = await db.query(
      `INSERT INTO orders (
        user_id, order_number, subtotal, shipping_fee, discount_amount, total_amount,
        payment_method, customer_name, customer_phone, customer_email,
        shipping_address, shipping_city, shipping_district, shipping_ward, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        user_id, order_number, subtotal, shipping_fee || 0, discount_amount || 0,
        total_amount, payment_method || 'cod', customer_name, customer_phone,
        customer_email, shipping_address, shipping_city, shipping_district,
        shipping_ward, notes
      ]
    );
    return result.insertId;
  }

  static async addItems(orderId, items) {
    const values = items.map(item => [
      orderId,
      item.product_id,
      item.variant_id || null,
      item.product_name,
      item.variant_info || null,
      item.quantity,
      item.price,
      item.subtotal
    ]);

    const [result] = await db.query(
      `INSERT INTO order_items (
        order_id, product_id, variant_id, product_name, variant_info,
        quantity, price, subtotal
      ) VALUES ?`,
      [values]
    );
    return result.affectedRows;
  }

  static async findById(id) {
    const [rows] = await db.query(
      `SELECT o.*, u.email as user_email, u.full_name as user_full_name
       FROM orders o
       LEFT JOIN users u ON o.user_id = u.id
       WHERE o.id = ?`,
      [id]
    );
    return rows[0];
  }

  static async getOrderItems(orderId) {
    const [rows] = await db.query(
      `SELECT oi.*, 
       (SELECT image_url FROM product_images WHERE product_id = oi.product_id AND is_primary = 1 LIMIT 1) as product_image
       FROM order_items oi
       WHERE oi.order_id = ?`,
      [orderId]
    );
    return rows;
  }

  static async findByUserId(userId, filters = {}) {
    let query = `
      SELECT o.*, COUNT(oi.id) as item_count
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = ?
    `;
    const params = [userId];

    if (filters.status) {
      query += ' AND o.status = ?';
      params.push(filters.status);
    }

    query += ' GROUP BY o.id ORDER BY o.created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ? OFFSET ?';
      params.push(parseInt(filters.limit), parseInt(filters.offset || 0));
    }

    const [rows] = await db.query(query, params);
    return rows;
  }

  static async findAll(filters = {}) {
    let query = `
      SELECT o.*, u.email as user_email, u.full_name as user_full_name,
      COUNT(oi.id) as item_count
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE 1=1
    `;
    const params = [];

    if (filters.status) {
      query += ' AND o.status = ?';
      params.push(filters.status);
    }

    if (filters.payment_status) {
      query += ' AND o.payment_status = ?';
      params.push(filters.payment_status);
    }

    if (filters.search) {
      query += ' AND (o.order_number LIKE ? OR o.customer_name LIKE ? OR o.customer_phone LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (filters.from_date) {
      query += ' AND DATE(o.created_at) >= ?';
      params.push(filters.from_date);
    }

    if (filters.to_date) {
      query += ' AND DATE(o.created_at) <= ?';
      params.push(filters.to_date);
    }

    query += ' GROUP BY o.id ORDER BY o.created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ? OFFSET ?';
      params.push(parseInt(filters.limit), parseInt(filters.offset || 0));
    }

    const [rows] = await db.query(query, params);
    return rows;
  }

  static async count(filters = {}) {
    let query = 'SELECT COUNT(DISTINCT o.id) as total FROM orders o WHERE 1=1';
    const params = [];

    if (filters.status) {
      query += ' AND o.status = ?';
      params.push(filters.status);
    }

    if (filters.user_id) {
      query += ' AND o.user_id = ?';
      params.push(filters.user_id);
    }

    const [rows] = await db.query(query, params);
    return rows[0].total;
  }

  static async updateStatus(id, status, additionalData = {}) {
    const fields = ['status = ?'];
    const values = [status];

    // Set timestamp based on status
    const statusTimestamps = {
      'confirmed': 'confirmed_at',
      'shipping': 'shipped_at',
      'delivered': 'delivered_at',
      'cancelled': 'cancelled_at'
    };

    if (statusTimestamps[status]) {
      fields.push(`${statusTimestamps[status]} = NOW()`);
    }

    if (additionalData.cancelled_reason) {
      fields.push('cancelled_reason = ?');
      values.push(additionalData.cancelled_reason);
    }

    values.push(id);

    const [result] = await db.query(
      `UPDATE orders SET ${fields.join(', ')} WHERE id = ?`,
      values
    );
    return result.affectedRows > 0;
  }

  static async updatePaymentStatus(id, paymentStatus) {
    const [result] = await db.query(
      'UPDATE orders SET payment_status = ? WHERE id = ?',
      [paymentStatus, id]
    );
    return result.affectedRows > 0;
  }

  /**
   * Update payment information after VNPay payment
   * @param {number} id - Order ID
   * @param {Object} paymentInfo - Payment information from VNPay
   * @returns {boolean} Success status
   */
  static async updatePaymentInfo(id, paymentInfo) {
    const {
      payment_status,
      transaction_id,
      payment_date,
      payment_response
    } = paymentInfo;

    const [result] = await db.query(
      `UPDATE orders 
       SET payment_status = ?, 
           transaction_id = ?, 
           payment_date = ?,
           payment_response = ?
       WHERE id = ?`,
      [
        payment_status,
        transaction_id,
        payment_date,
        JSON.stringify(payment_response),
        id
      ]
    );
    return result.affectedRows > 0;
  }

  /**
   * Update transaction ID for order
   * @param {number} id - Order ID
   * @param {string} transactionId - VNPay transaction ID
   * @returns {boolean} Success status
   */
  static async updateTransactionId(id, transactionId) {
    const [result] = await db.query(
      'UPDATE orders SET transaction_id = ? WHERE id = ?',
      [transactionId, id]
    );
    return result.affectedRows > 0;
  }

  /**
   * Find order by transaction ID
   * @param {string} transactionId - VNPay transaction ID
   * @returns {Object|null} Order data
   */
  static async findByTransactionId(transactionId) {
    const [rows] = await db.query(
      `SELECT o.*, 
        GROUP_CONCAT(
          JSON_OBJECT(
            'id', oi.id,
            'product_id', oi.product_id,
            'variant_id', oi.variant_id,
            'product_name', oi.product_name,
            'variant_info', oi.variant_info,
            'quantity', oi.quantity,
            'price', oi.price,
            'subtotal', oi.subtotal
          )
        ) as items
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       WHERE o.transaction_id = ?
       GROUP BY o.id`,
      [transactionId]
    );

    if (rows.length === 0) return null;

    const order = rows[0];
    if (order.items) {
      order.items = JSON.parse(`[${order.items}]`);
    }
    return order;
  }

  /**
   * Find order by order number
   * @param {string} orderNumber - Order number
   * @returns {Object|null} Order data
   */
  static async findByOrderNumber(orderNumber) {
    const [rows] = await db.query(
      `SELECT o.*, 
        GROUP_CONCAT(
          JSON_OBJECT(
            'id', oi.id,
            'product_id', oi.product_id,
            'variant_id', oi.variant_id,
            'product_name', oi.product_name,
            'variant_info', oi.variant_info,
            'quantity', oi.quantity,
            'price', oi.price,
            'subtotal', oi.subtotal
          )
        ) as items
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       WHERE o.order_number = ?
       GROUP BY o.id`,
      [orderNumber]
    );

    if (rows.length === 0) return null;

    const order = rows[0];
    if (order.items) {
      order.items = JSON.parse(`[${order.items}]`);
    }
    return order;
  }

  static async generateOrderNumber() {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    return `ORD${year}${month}${day}${random}`;
  }

  static async getStatistics(filters = {}) {
    let query = `
      SELECT 
        COUNT(*) as total_orders,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_orders,
        SUM(CASE WHEN status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_orders,
        SUM(CASE WHEN status = 'processing' THEN 1 ELSE 0 END) as processing_orders,
        SUM(CASE WHEN status = 'shipping' THEN 1 ELSE 0 END) as shipping_orders,
        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as delivered_orders,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_orders,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as average_order_value
      FROM orders
      WHERE 1=1
    `;
    const params = [];

    if (filters.from_date) {
      query += ' AND DATE(created_at) >= ?';
      params.push(filters.from_date);
    }

    if (filters.to_date) {
      query += ' AND DATE(created_at) <= ?';
      params.push(filters.to_date);
    }

    const [rows] = await db.query(query, params);
    return rows[0];
  }
}

module.exports = Order;
