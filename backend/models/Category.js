const db = require('../config/database');

class Category {
  static async findAll(filters = {}) {
    let query = `
      SELECT c.*, 
      (SELECT COUNT(*) FROM products WHERE category_id = c.id AND is_active = 1) as product_count,
      (SELECT name FROM categories WHERE id = c.parent_id) as parent_name
      FROM categories c
      WHERE c.is_active = 1
    `;
    const params = [];

    if (filters.parent_id !== undefined) {
      if (filters.parent_id === null) {
        query += ' AND c.parent_id IS NULL';
      } else {
        query += ' AND c.parent_id = ?';
        params.push(filters.parent_id);
      }
    }

    query += ' ORDER BY c.display_order, c.name';

    const [rows] = await db.query(query, params);
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.query(
      `SELECT c.*, 
       (SELECT COUNT(*) FROM products WHERE category_id = c.id AND is_active = 1) as product_count,
       (SELECT name FROM categories WHERE id = c.parent_id) as parent_name
       FROM categories c
       WHERE c.id = ?`,
      [id]
    );
    return rows[0];
  }

  static async create(categoryData) {
    const { name, description, image, parent_id, display_order } = categoryData;
    const [result] = await db.query(
      'INSERT INTO categories (name, description, image, parent_id, display_order) VALUES (?, ?, ?, ?, ?)',
      [name, description, image || null, parent_id || null, display_order || 0]
    );
    return result.insertId;
  }

  static async update(id, categoryData) {
    const fields = [];
    const values = [];
    
    Object.keys(categoryData).forEach(key => {
      if (categoryData[key] !== undefined && key !== 'id') {
        fields.push(`${key} = ?`);
        values.push(categoryData[key]);
      }
    });
    
    if (fields.length === 0) return false;
    
    values.push(id);
    const [result] = await db.query(
      `UPDATE categories SET ${fields.join(', ')} WHERE id = ?`,
      values
    );
    return result.affectedRows > 0;
  }

  static async delete(id) {
    const [result] = await db.query('UPDATE categories SET is_active = 0 WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  static async getTree() {
    const [parents] = await db.query(
      `SELECT c.*, 
       (SELECT COUNT(*) FROM products WHERE category_id = c.id AND is_active = 1) as product_count
       FROM categories c
       WHERE c.parent_id IS NULL AND c.is_active = 1
       ORDER BY c.display_order, c.name`
    );

    for (let parent of parents) {
      const [children] = await db.query(
        `SELECT c.*, 
         (SELECT COUNT(*) FROM products WHERE category_id = c.id AND is_active = 1) as product_count
         FROM categories c
         WHERE c.parent_id = ? AND c.is_active = 1
         ORDER BY c.display_order, c.name`,
        [parent.id]
      );
      parent.children = children;
    }

    return parents;
  }
}

module.exports = Category;
