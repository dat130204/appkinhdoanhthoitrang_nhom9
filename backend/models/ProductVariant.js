const db = require('../config/database');

class ProductVariant {
  static async findByProductId(productId) {
    const [rows] = await db.query(
      `SELECT * FROM product_variants 
       WHERE product_id = ? 
       ORDER BY id`,
      [productId]
    );
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.query(
      'SELECT * FROM product_variants WHERE id = ?',
      [id]
    );
    return rows[0];
  }

  static async create(variantData) {
    const [result] = await db.query(
      `INSERT INTO product_variants 
       (product_id, size, color, price_adjustment, stock_quantity, sku) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        variantData.product_id,
        variantData.size || null,
        variantData.color || null,
        variantData.price_adjustment || 0,
        variantData.stock_quantity || 0,
        variantData.sku || null
      ]
    );
    return result.insertId;
  }

  static async update(id, variantData) {
    const fields = [];
    const values = [];

    if (variantData.size !== undefined) {
      fields.push('size = ?');
      values.push(variantData.size);
    }
    if (variantData.color !== undefined) {
      fields.push('color = ?');
      values.push(variantData.color);
    }
    if (variantData.price_adjustment !== undefined) {
      fields.push('price_adjustment = ?');
      values.push(variantData.price_adjustment);
    }
    if (variantData.stock_quantity !== undefined) {
      fields.push('stock_quantity = ?');
      values.push(variantData.stock_quantity);
    }
    if (variantData.sku !== undefined) {
      fields.push('sku = ?');
      values.push(variantData.sku);
    }

    values.push(id);

    await db.query(
      `UPDATE product_variants SET ${fields.join(', ')} WHERE id = ?`,
      values
    );
  }

  static async delete(id) {
    await db.query('DELETE FROM product_variants WHERE id = ?', [id]);
  }

  static async deleteByProductId(productId) {
    await db.query('DELETE FROM product_variants WHERE product_id = ?', [productId]);
  }

  static async updateStock(id, quantity, operation = 'subtract') {
    const operator = operation === 'subtract' ? '-' : '+';
    await db.query(
      `UPDATE product_variants 
       SET stock_quantity = stock_quantity ${operator} ? 
       WHERE id = ?`,
      [quantity, id]
    );
  }
}

module.exports = ProductVariant;
