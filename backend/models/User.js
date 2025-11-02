const db = require('../config/database');

class User {
  static async findById(id) {
    const [rows] = await db.query(
      'SELECT id, email, full_name, phone, address, role, avatar, is_active, created_at, updated_at FROM users WHERE id = ?',
      [id]
    );
    return rows[0];
  }

  static async findByEmail(email) {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return rows[0];
  }

  static async create(userData) {
    const { email, password, full_name, phone, role = 'customer' } = userData;
    const [result] = await db.query(
      'INSERT INTO users (email, password, full_name, phone, role) VALUES (?, ?, ?, ?, ?)',
      [email, password, full_name, phone, role]
    );
    return result.insertId;
  }

  static async update(id, userData) {
    const fields = [];
    const values = [];
    
    Object.keys(userData).forEach(key => {
      if (userData[key] !== undefined && key !== 'id' && key !== 'password') {
        fields.push(`${key} = ?`);
        values.push(userData[key]);
      }
    });
    
    if (fields.length === 0) return false;
    
    values.push(id);
    const [result] = await db.query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
      values
    );
    return result.affectedRows > 0;
  }

  static async updatePassword(id, newPassword) {
    const [result] = await db.query(
      'UPDATE users SET password = ? WHERE id = ?',
      [newPassword, id]
    );
    return result.affectedRows > 0;
  }

  static async findAll(filters = {}) {
    let query = 'SELECT id, email, full_name, phone, address, role, avatar, is_active, created_at FROM users WHERE 1=1';
    const params = [];

    if (filters.role) {
      query += ' AND role = ?';
      params.push(filters.role);
    }

    if (filters.is_active !== undefined) {
      query += ' AND is_active = ?';
      params.push(filters.is_active);
    }

    if (filters.search) {
      query += ' AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    query += ' ORDER BY created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ? OFFSET ?';
      params.push(parseInt(filters.limit), parseInt(filters.offset || 0));
    }

    const [rows] = await db.query(query, params);
    return rows;
  }

  static async count(filters = {}) {
    let query = 'SELECT COUNT(*) as total FROM users WHERE 1=1';
    const params = [];

    if (filters.role) {
      query += ' AND role = ?';
      params.push(filters.role);
    }

    if (filters.is_active !== undefined) {
      query += ' AND is_active = ?';
      params.push(filters.is_active);
    }

    const [rows] = await db.query(query, params);
    return rows[0].total;
  }

  static async delete(id) {
    const [result] = await db.query('DELETE FROM users WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  static async setPasswordResetToken(id, token, expires) {
    const [result] = await db.query(
      'UPDATE users SET password_reset_token = ?, password_reset_expires = ? WHERE id = ?',
      [token, expires, id]
    );
    return result.affectedRows > 0;
  }

  static async findByResetToken(token) {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE password_reset_token = ? AND password_reset_expires > NOW()',
      [token]
    );
    return rows[0];
  }

  static async resetPassword(id, newPassword) {
    const [result] = await db.query(
      'UPDATE users SET password = ?, password_reset_token = NULL, password_reset_expires = NULL WHERE id = ?',
      [newPassword, id]
    );
    return result.affectedRows > 0;
  }

  /**
   * Find user by Google ID
   * @param {string} googleId - Google OAuth user ID
   * @returns {Object|null} User object or null
   */
  static async findByGoogleId(googleId) {
    const [rows] = await db.query(
      'SELECT id, email, full_name, phone, address, role, avatar, google_id, is_active, created_at, updated_at FROM users WHERE google_id = ?',
      [googleId]
    );
    return rows[0];
  }

  /**
   * Create new user from Google OAuth data
   * @param {Object} userData - Google user data
   * @returns {number} New user ID
   */
  static async createFromGoogle(userData) {
    const { email, firstName, lastName, googleId, avatar, emailVerified, role = 'customer' } = userData;
    const fullName = `${firstName} ${lastName}`.trim();
    
    const [result] = await db.query(
      `INSERT INTO users (email, full_name, google_id, avatar, role, is_active) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [email, fullName, googleId, avatar, role, emailVerified ? 1 : 0]
    );
    
    return this.findById(result.insertId);
  }

  /**
   * Link Google account to existing user
   * @param {number} userId - User ID
   * @param {string} googleId - Google OAuth user ID
   * @returns {boolean} Success status
   */
  static async linkGoogleAccount(userId, googleId) {
    const [result] = await db.query(
      'UPDATE users SET google_id = ? WHERE id = ?',
      [googleId, userId]
    );
    return result.affectedRows > 0;
  }

  /**
   * Unlink Google account from user
   * @param {number} userId - User ID
   * @returns {boolean} Success status
   */
  static async unlinkGoogleAccount(userId) {
    const [result] = await db.query(
      'UPDATE users SET google_id = NULL WHERE id = ?',
      [userId]
    );
    return result.affectedRows > 0;
  }

  /**
   * Check if user has Google account linked
   * @param {number} userId - User ID
   * @returns {boolean} True if Google account is linked
   */
  static async hasGoogleAccount(userId) {
    const [rows] = await db.query(
      'SELECT google_id FROM users WHERE id = ?',
      [userId]
    );
    return rows[0] && rows[0].google_id !== null;
  }
}

module.exports = User;
