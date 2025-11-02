const pool = require('../config/database');

class Notification {
  // Get all notifications for a user
  static async findByUserId(userId, options = {}) {
    const { isRead, type, limit = 50, offset = 0 } = options;
    
    let query = 'SELECT * FROM notifications WHERE user_id = ?';
    const params = [userId];
    
    if (isRead !== undefined) {
      query += ' AND is_read = ?';
      params.push(isRead);
    }
    
    if (type) {
      query += ' AND type = ?';
      params.push(type);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    return rows;
  }

  // Get unread count for a user
  static async getUnreadCount(userId) {
    const [rows] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE',
      [userId]
    );
    return rows[0].count;
  }

  // Create a notification
  static async create(notificationData) {
    const { userId, title, message, type = 'system', data = null } = notificationData;
    
    if (!userId || !title || !message) {
      throw new Error('Missing required fields: userId, title, message');
    }

    const validTypes = ['order', 'promotion', 'system', 'review', 'account'];
    if (!validTypes.includes(type)) {
      throw new Error(`Invalid notification type. Must be one of: ${validTypes.join(', ')}`);
    }

    const [result] = await pool.query(
      `INSERT INTO notifications (user_id, title, message, type, data) 
       VALUES (?, ?, ?, ?, ?)`,
      [userId, title, message, type, data ? JSON.stringify(data) : null]
    );
    
    return this.findById(result.insertId);
  }

  // Create multiple notifications (bulk insert)
  static async createBulk(userIds, title, message, type = 'system', data = null) {
    if (!Array.isArray(userIds) || userIds.length === 0) {
      throw new Error('userIds must be a non-empty array');
    }

    if (!title || !message) {
      throw new Error('Missing required fields: title, message');
    }

    const validTypes = ['order', 'promotion', 'system', 'review', 'account'];
    if (!validTypes.includes(type)) {
      throw new Error(`Invalid notification type. Must be one of: ${validTypes.join(', ')}`);
    }

    const values = userIds.map(userId => [
      userId,
      title,
      message,
      type,
      data ? JSON.stringify(data) : null
    ]);

    const [result] = await pool.query(
      `INSERT INTO notifications (user_id, title, message, type, data) 
       VALUES ?`,
      [values]
    );

    return {
      success: true,
      insertedCount: result.affectedRows,
      insertId: result.insertId
    };
  }

  // Find notification by ID
  static async findById(id) {
    const [rows] = await pool.query(
      'SELECT * FROM notifications WHERE id = ?',
      [id]
    );
    return rows[0];
  }

  // Mark notification as read
  static async markAsRead(id, userId) {
    const [result] = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  }

  // Mark all notifications as read for a user
  static async markAllAsRead(userId) {
    const [result] = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE',
      [userId]
    );
    return result.affectedRows;
  }

  // Delete a notification
  static async delete(id, userId) {
    const [result] = await pool.query(
      'DELETE FROM notifications WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  }

  // Delete all read notifications for a user
  static async deleteAllRead(userId) {
    const [result] = await pool.query(
      'DELETE FROM notifications WHERE user_id = ? AND is_read = TRUE',
      [userId]
    );
    return result.affectedRows;
  }

  // Get notification statistics for admin
  static async getStatistics() {
    const [stats] = await pool.query(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN is_read = FALSE THEN 1 ELSE 0 END) as unread,
        SUM(CASE WHEN is_read = TRUE THEN 1 ELSE 0 END) as read,
        SUM(CASE WHEN type = 'order' THEN 1 ELSE 0 END) as order_notifications,
        SUM(CASE WHEN type = 'promotion' THEN 1 ELSE 0 END) as promotion_notifications,
        SUM(CASE WHEN type = 'system' THEN 1 ELSE 0 END) as system_notifications,
        SUM(CASE WHEN type = 'review' THEN 1 ELSE 0 END) as review_notifications,
        SUM(CASE WHEN type = 'account' THEN 1 ELSE 0 END) as account_notifications,
        COUNT(DISTINCT user_id) as unique_users,
        DATE(created_at) as date
      FROM notifications
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      GROUP BY DATE(created_at)
      ORDER BY date DESC
    `);
    
    return stats;
  }

  // Clean old notifications (older than 90 days)
  static async cleanOldNotifications(daysOld = 90) {
    const [result] = await pool.query(
      'DELETE FROM notifications WHERE is_read = TRUE AND created_at < DATE_SUB(NOW(), INTERVAL ? DAY)',
      [daysOld]
    );
    return result.affectedRows;
  }
}

module.exports = Notification;
