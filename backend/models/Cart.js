const db = require('../config/database');

class Cart {
  static async findOrCreateByUserId(userId) {
    let [rows] = await db.query('SELECT * FROM carts WHERE user_id = ?', [userId]);
    
    if (rows.length === 0) {
      const [result] = await db.query('INSERT INTO carts (user_id) VALUES (?)', [userId]);
      [rows] = await db.query('SELECT * FROM carts WHERE id = ?', [result.insertId]);
    }
    
    return rows[0];
  }

  static async getItems(cartId) {
    const [rows] = await db.query(
      `SELECT ci.*, p.name as product_name, p.stock_quantity, p.is_active as product_active,
       (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as product_image,
       pv.size, pv.color, pv.stock_quantity as variant_stock
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       LEFT JOIN product_variants pv ON ci.variant_id = pv.id
       WHERE ci.cart_id = ?
       ORDER BY ci.created_at DESC`,
      [cartId]
    );
    return rows;
  }

  static async addItem(cartId, itemData) {
    const { product_id, variant_id, quantity, price } = itemData;
    
    // Check if item already exists
    const [existing] = await db.query(
      'SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ? AND (variant_id = ? OR (variant_id IS NULL AND ? IS NULL))',
      [cartId, product_id, variant_id || null, variant_id || null]
    );

    if (existing.length > 0) {
      // Update quantity
      const [result] = await db.query(
        'UPDATE cart_items SET quantity = quantity + ?, price = ? WHERE id = ?',
        [quantity, price, existing[0].id]
      );
      return existing[0].id;
    } else {
      // Insert new item
      const [result] = await db.query(
        'INSERT INTO cart_items (cart_id, product_id, variant_id, quantity, price) VALUES (?, ?, ?, ?, ?)',
        [cartId, product_id, variant_id || null, quantity, price]
      );
      return result.insertId;
    }
  }

  static async updateItemQuantity(itemId, quantity) {
    const [result] = await db.query(
      'UPDATE cart_items SET quantity = ? WHERE id = ?',
      [quantity, itemId]
    );
    return result.affectedRows > 0;
  }

  static async removeItem(itemId) {
    const [result] = await db.query('DELETE FROM cart_items WHERE id = ?', [itemId]);
    return result.affectedRows > 0;
  }

  static async clearCart(cartId) {
    const [result] = await db.query('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);
    return result.affectedRows > 0;
  }

  static async getCartSummary(cartId) {
    const [rows] = await db.query(
      `SELECT 
        COUNT(*) as item_count,
        SUM(quantity) as total_items,
        SUM(quantity * price) as subtotal
       FROM cart_items
       WHERE cart_id = ?`,
      [cartId]
    );
    return rows[0];
  }
}

module.exports = Cart;
