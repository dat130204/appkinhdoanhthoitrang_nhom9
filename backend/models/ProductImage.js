const db = require('../config/database');

class ProductImage {
  static async create(imageData) {
    const { product_id, image_url, is_primary, display_order } = imageData;
    
    // If this is primary, set all other images as non-primary
    if (is_primary) {
      await db.query(
        'UPDATE product_images SET is_primary = 0 WHERE product_id = ?',
        [product_id]
      );
    }
    
    const [result] = await db.query(
      'INSERT INTO product_images (product_id, image_url, is_primary, display_order) VALUES (?, ?, ?, ?)',
      [product_id, image_url, is_primary || false, display_order || 0]
    );
    return result.insertId;
  }

  static async findByProductId(productId) {
    const [rows] = await db.query(
      'SELECT * FROM product_images WHERE product_id = ? ORDER BY is_primary DESC, display_order',
      [productId]
    );
    return rows;
  }

  static async delete(id) {
    const [result] = await db.query('DELETE FROM product_images WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  static async deleteByProductId(productId) {
    const [result] = await db.query('DELETE FROM product_images WHERE product_id = ?', [productId]);
    return result.affectedRows > 0;
  }

  static async setPrimary(id, productId) {
    const connection = await db.getConnection();
    try {
      await connection.beginTransaction();
      
      await connection.query(
        'UPDATE product_images SET is_primary = 0 WHERE product_id = ?',
        [productId]
      );
      
      await connection.query(
        'UPDATE product_images SET is_primary = 1 WHERE id = ?',
        [id]
      );
      
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }
}

module.exports = ProductImage;
