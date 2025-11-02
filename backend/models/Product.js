const db = require('../config/database');

class Product {
  static async create(productData) {
    const {
      name, description, price, sale_price, category_id,
      stock_quantity, sku, brand, material, is_featured
    } = productData;

    const [result] = await db.query(
      `INSERT INTO products (name, description, price, sale_price, category_id, 
       stock_quantity, sku, brand, material, is_featured) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, price, sale_price || null, category_id,
       stock_quantity || 0, sku, brand, material, is_featured || false]
    );
    return result.insertId;
  }

  static async findById(id) {
    const [rows] = await db.query(
      `SELECT p.*, c.name as category_name, c.parent_id,
       (SELECT GROUP_CONCAT(image_url) FROM product_images WHERE product_id = p.id ORDER BY is_primary DESC, display_order) as images
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = ?`,
      [id]
    );
    
    if (rows[0] && rows[0].images) {
      rows[0].images = rows[0].images.split(',');
    }
    
    return rows[0];
  }

  static async findAll(filters = {}) {
    let query = `
      SELECT p.*, c.name as category_name,
      (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as primary_image,
      (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as review_count
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE 1=1
    `;
    const params = [];

    // Filter by is_active if specified
    if (filters.is_active !== undefined && filters.is_active !== null) {
      query += ' AND p.is_active = ?';
      params.push(filters.is_active === true || filters.is_active === '1' || filters.is_active === 1 ? 1 : 0);
    }

    if (filters.category_id) {
      query += ' AND p.category_id = ?';
      params.push(filters.category_id);
    }

    if (filters.search) {
      query += ' AND (p.name LIKE ? OR p.description LIKE ? OR p.brand LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (filters.min_price) {
      query += ' AND p.price >= ?';
      params.push(filters.min_price);
    }

    if (filters.max_price) {
      query += ' AND p.price <= ?';
      params.push(filters.max_price);
    }

    if (filters.brand) {
      query += ' AND p.brand = ?';
      params.push(filters.brand);
    }

    if (filters.is_featured !== undefined && filters.is_featured !== null) {
      query += ' AND p.is_featured = ?';
      params.push(filters.is_featured === true || filters.is_featured === '1' || filters.is_featured === 1 ? 1 : 0);
    }

    // Sorting
    const sortBy = filters.sort_by || 'created_at';
    const sortOrder = filters.sort_order || 'DESC';
    const allowedSortFields = ['created_at', 'price', 'name', 'sold_quantity', 'rating'];
    
    if (allowedSortFields.includes(sortBy)) {
      query += ` ORDER BY p.${sortBy} ${sortOrder}`;
    } else {
      query += ' ORDER BY p.created_at DESC';
    }

    if (filters.limit) {
      query += ' LIMIT ? OFFSET ?';
      params.push(parseInt(filters.limit), parseInt(filters.offset || 0));
    }

    const [rows] = await db.query(query, params);
    return rows;
  }

  static async count(filters = {}) {
    let query = 'SELECT COUNT(*) as total FROM products p WHERE p.is_active = 1';
    const params = [];

    if (filters.category_id) {
      query += ' AND p.category_id = ?';
      params.push(filters.category_id);
    }

    if (filters.search) {
      query += ' AND (p.name LIKE ? OR p.description LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm);
    }

    if (filters.min_price) {
      query += ' AND p.price >= ?';
      params.push(filters.min_price);
    }

    if (filters.max_price) {
      query += ' AND p.price <= ?';
      params.push(filters.max_price);
    }

    const [rows] = await db.query(query, params);
    return rows[0].total;
  }

  static async update(id, productData) {
    const fields = [];
    const values = [];
    
    Object.keys(productData).forEach(key => {
      if (productData[key] !== undefined && key !== 'id') {
        fields.push(`${key} = ?`);
        values.push(productData[key]);
      }
    });
    
    if (fields.length === 0) return false;
    
    values.push(id);
    const [result] = await db.query(
      `UPDATE products SET ${fields.join(', ')} WHERE id = ?`,
      values
    );
    return result.affectedRows > 0;
  }

  static async delete(id) {
    const [result] = await db.query('UPDATE products SET is_active = 0 WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  static async updateStock(id, quantity, operation = 'subtract') {
    const operator = operation === 'add' ? '+' : '-';
    const [result] = await db.query(
      `UPDATE products SET stock_quantity = stock_quantity ${operator} ? WHERE id = ?`,
      [quantity, id]
    );
    return result.affectedRows > 0;
  }

  static async updateSoldQuantity(id, quantity) {
    const [result] = await db.query(
      'UPDATE products SET sold_quantity = sold_quantity + ? WHERE id = ?',
      [quantity, id]
    );
    return result.affectedRows > 0;
  }

  static async updateRating(productId) {
    const [rows] = await db.query(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as count FROM reviews WHERE product_id = ? AND is_approved = 1',
      [productId]
    );
    
    if (rows[0]) {
      await db.query(
        'UPDATE products SET rating = ?, review_count = ? WHERE id = ?',
        [rows[0].avg_rating || 0, rows[0].count, productId]
      );
    }
  }

  static async getBrands() {
    const [rows] = await db.query(
      'SELECT DISTINCT brand FROM products WHERE brand IS NOT NULL AND brand != "" ORDER BY brand'
    );
    return rows.map(row => row.brand);
  }

  static async getRelatedProducts(productId, categoryId, limit = 4) {
    const [rows] = await db.query(
      `SELECT p.*, 
       (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as primary_image
       FROM products p
       WHERE p.category_id = ? AND p.id != ? AND p.is_active = 1
       ORDER BY p.sold_quantity DESC, p.rating DESC
       LIMIT ?`,
      [categoryId, productId, limit]
    );
    return rows;
  }
}

module.exports = Product;
