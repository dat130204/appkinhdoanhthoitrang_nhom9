const db = require('../config/database');

class Review {
  // Get all reviews for a product (with status filter for admin)
  static async findByProductId(productId, options = {}) {
    const { limit = 10, offset = 0, sortBy = 'created_at DESC', status = 'approved' } = options;
    
    try {
      let query = `SELECT 
          r.*,
          u.full_name as user_name,
          u.email as user_email
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.product_id = ? AND r.deleted_at IS NULL`;
      
      const params = [productId];
      
      if (status) {
        query += ` AND r.status = ?`;
        params.push(status);
      }
      
      query += ` ORDER BY ${sortBy} LIMIT ? OFFSET ?`;
      params.push(parseInt(limit), parseInt(offset));
      
      const [reviews] = await db.query(query, params);
      
      return reviews;
    } catch (error) {
      throw error;  
    }
  }

  // Get review statistics for a product (approved only for users)
  static async getStatistics(productId, includeAll = false) {
    try {
      let query = `SELECT 
          COUNT(*) as total_reviews,
          AVG(rating) as average_rating,
          SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star,
          SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star,
          SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star,
          SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star,
          SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star
        FROM reviews
        WHERE product_id = ? AND deleted_at IS NULL`;
      
      const params = [productId];
      
      if (!includeAll) {
        query += ` AND status = 'approved'`;
      }
      
      const [stats] = await db.query(query, params);
      
      return stats[0] || {
        total_reviews: 0,
        average_rating: 0,
        five_star: 0,
        four_star: 0,
        three_star: 0,
        two_star: 0,
        one_star: 0
      };
    } catch (error) {
      throw error;
    }
  }

  // Create a new review (with pending status for moderation)
  static async create(reviewData) {
    const { user_id, product_id, rating, comment } = reviewData;
    
    try {
      // Check if user already reviewed this product
      const [existing] = await db.query(
        'SELECT id FROM reviews WHERE user_id = ? AND product_id = ? AND deleted_at IS NULL',
        [user_id, product_id]
      );
      
      if (existing.length > 0) {
        throw new Error('Bạn đã đánh giá sản phẩm này rồi');
      }
      
      const [result] = await db.query(
        `INSERT INTO reviews (user_id, product_id, rating, comment, status)
         VALUES (?, ?, ?, ?, 'pending')`,
        [user_id, product_id, rating, comment]
      );
      
      return this.findById(result.insertId);
    } catch (error) {
      throw error;
    }
  }

  // Find review by ID
  static async findById(id) {
    try {
      const [reviews] = await db.query(
        `SELECT 
          r.*,
          u.full_name as user_name,
          u.email as user_email,
          u.avatar as user_avatar,
          p.name as product_name,
          p.price as product_price
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        LEFT JOIN products p ON r.product_id = p.id
        WHERE r.id = ? AND r.deleted_at IS NULL`,
        [id]
      );
      
      return reviews[0];
    } catch (error) {
      throw error;
    }
  }

  // Update review
  static async update(id, userId, updateData) {
    const { rating, comment } = updateData;
    
    try {
      // Verify ownership
      const [review] = await db.query(
        'SELECT user_id FROM reviews WHERE id = ?',
        [id]
      );
      
      if (!review[0] || review[0].user_id !== userId) {
        throw new Error('Không có quyền chỉnh sửa đánh giá này');
      }
      
      await db.query(
        `UPDATE reviews 
         SET rating = ?, comment = ?, updated_at = NOW()
         WHERE id = ?`,
        [rating, comment, id]
      );
      
      return this.findById(id);
    } catch (error) {
      throw error;
    }
  }

  // Delete review (soft delete)
  static async delete(id, userId = null, isAdmin = false) {
    try {
      if (!isAdmin) {
        // Verify ownership for regular users
        const [review] = await db.query(
          'SELECT user_id FROM reviews WHERE id = ? AND deleted_at IS NULL',
          [id]
        );
        
        if (!review[0] || review[0].user_id !== userId) {
          throw new Error('Không có quyền xóa đánh giá này');
        }
      }
      
      await db.query(
        'UPDATE reviews SET deleted_at = NOW() WHERE id = ?',
        [id]
      );
      return true;
    } catch (error) {
      throw error;
    }
  }

  // Admin methods
  
  // Get all reviews with filters (for admin)
  static async findAll(options = {}) {
    const {
      page = 1,
      limit = 20,
      status = 'all',
      sortBy = 'created_at',
      sortOrder = 'DESC'
    } = options;
    
    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    try {
      let whereClause = 'r.deleted_at IS NULL';
      const params = [];
      
      if (status !== 'all') {
        whereClause += ' AND r.status = ?';
        params.push(status);
      }
      
      // Get total count
      const [countResult] = await db.query(
        `SELECT COUNT(*) as total FROM reviews r WHERE ${whereClause}`,
        params
      );
      
      // Get reviews
      const allowedSortColumns = ['created_at', 'rating', 'status'];
      const sortColumn = allowedSortColumns.includes(sortBy) ? sortBy : 'created_at';
      const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
      
      const [reviews] = await db.query(
        `SELECT 
          r.*,
          u.full_name as user_name,
          u.email as user_email,
          u.avatar as user_avatar,
          p.name as product_name,
          p.price as product_price,
          (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as product_image
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        LEFT JOIN products p ON r.product_id = p.id
        WHERE ${whereClause}
        ORDER BY r.${sortColumn} ${order}
        LIMIT ? OFFSET ?`,
        [...params, parseInt(limit), offset]
      );
      
      // Convert price to number
      const formattedReviews = reviews.map(review => ({
        ...review,
        product_price: parseFloat(review.product_price) || 0
      }));
      
      return {
        reviews: formattedReviews,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(countResult[0].total / parseInt(limit)),
          totalItems: countResult[0].total,
          itemsPerPage: parseInt(limit)
        }
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Get review statistics (for admin)
  static async getAdminStats() {
    try {
      const [stats] = await db.query(
        `SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
          SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
          SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
          AVG(CASE WHEN status = 'approved' THEN rating ELSE NULL END) as avg_rating
        FROM reviews
        WHERE deleted_at IS NULL`
      );
      
      const result = stats[0];
      
      // Convert string numbers to proper types
      return {
        total: parseInt(result.total) || 0,
        pending: parseInt(result.pending) || 0,
        approved: parseInt(result.approved) || 0,
        rejected: parseInt(result.rejected) || 0,
        avg_rating: parseFloat(result.avg_rating) || 0.0
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Update review status (approve/reject)
  static async updateStatus(id, status) {
    try {
      const validStatuses = ['pending', 'approved', 'rejected'];
      if (!validStatuses.includes(status)) {
        throw new Error('Invalid status');
      }
      
      await db.query(
        'UPDATE reviews SET status = ?, updated_at = NOW() WHERE id = ?',
        [status, id]
      );
      
      return this.findById(id);
    } catch (error) {
      throw error;
    }
  }

  // Mark review as helpful
  static async markHelpful(reviewId, userId) {
    try {
      // Check if already marked
      const [existing] = await db.query(
        'SELECT id FROM review_helpful WHERE review_id = ? AND user_id = ?',
        [reviewId, userId]
      );
      
      if (existing.length > 0) {
        // Remove helpful mark
        await db.query(
          'DELETE FROM review_helpful WHERE review_id = ? AND user_id = ?',
          [reviewId, userId]
        );
        await db.query(
          'UPDATE reviews SET helpful_count = helpful_count - 1 WHERE id = ?',
          [reviewId]
        );
        return { helpful: false };
      } else {
        // Add helpful mark
        await db.query(
          'INSERT INTO review_helpful (review_id, user_id) VALUES (?, ?)',
          [reviewId, userId]
        );
        await db.query(
          'UPDATE reviews SET helpful_count = helpful_count + 1 WHERE id = ?',
          [reviewId]
        );
        return { helpful: true };
      }
    } catch (error) {
      throw error;
    }
  }

  // Check if user can review (must have purchased the product)
  static async canReview(userId, productId) {
    try {
      const [orders] = await db.query(
        `SELECT COUNT(*) as count
         FROM orders o
         JOIN order_items oi ON o.id = oi.order_id
         WHERE o.user_id = ? 
         AND oi.product_id = ?
         AND o.status = 'delivered'
         AND o.deleted_at IS NULL`,
        [userId, productId]
      );
      
      return orders[0].count > 0;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Review;
