const db = require('../config/database');

class Wishlist {
  static async findByUserId(userId) {
    const [rows] = await db.query(`
      SELECT 
        w.id,
        w.user_id,
        w.product_id,
        w.created_at,
        p.name as product_name,
        p.price,
        p.sale_price,
        p.stock_quantity > 0 as in_stock,
        pi.image_url as product_image
      FROM wishlists w
      JOIN products p ON w.product_id = p.id
      LEFT JOIN (
        SELECT product_id, MIN(image_url) as image_url
        FROM product_images
        WHERE is_primary = 1
        GROUP BY product_id
      ) pi ON p.id = pi.product_id
      WHERE w.user_id = ?
      ORDER BY w.created_at DESC
    `, [userId]);
    return rows;
  }

  static async add(userId, productId) {
    // Check if already exists
    const [existing] = await db.query(
      'SELECT id FROM wishlists WHERE user_id = ? AND product_id = ?',
      [userId, productId]
    );

    if (existing.length > 0) {
      return existing[0].id;
    }

    const [result] = await db.query(
      'INSERT INTO wishlists (user_id, product_id) VALUES (?, ?)',
      [userId, productId]
    );
    return result.insertId;
  }

  static async remove(userId, productId) {
    const [result] = await db.query(
      'DELETE FROM wishlists WHERE user_id = ? AND product_id = ?',
      [userId, productId]
    );
    return result.affectedRows > 0;
  }

  static async removeById(id, userId) {
    const [result] = await db.query(
      'DELETE FROM wishlists WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  }

  static async isInWishlist(userId, productId) {
    const [rows] = await db.query(
      'SELECT id FROM wishlists WHERE user_id = ? AND product_id = ?',
      [userId, productId]
    );
    return rows.length > 0;
  }

  static async clearAll(userId) {
    const [result] = await db.query(
      'DELETE FROM wishlists WHERE user_id = ?',
      [userId]
    );
    return result.affectedRows;
  }

  static async count(userId) {
    const [rows] = await db.query(
      'SELECT COUNT(*) as total FROM wishlists WHERE user_id = ?',
      [userId]
    );
    return rows[0].total;
  }
}

module.exports = Wishlist;
