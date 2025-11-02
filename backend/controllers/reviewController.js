const Review = require('../models/Review');

// Get reviews for a product (approved only for public)
exports.getProductReviews = async (req, res) => {
  try {
    const { productId } = req.params;
    const { limit = 10, offset = 0, sortBy = 'created_at DESC' } = req.query;
    
    const reviews = await Review.findByProductId(productId, {
      limit,
      offset,
      sortBy,
      status: 'approved' // Only show approved reviews to public
    });
    
    const stats = await Review.getStatistics(productId, false); // Only approved
    
    res.json({
      success: true,
      data: {
        reviews,
        statistics: stats
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tải đánh giá',
      error: error.message
    });
  }
};

// Create a review (will be pending for admin approval)
exports.createReview = async (req, res) => {
  try {
    const { productId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;
    
    // Validate rating
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Đánh giá phải từ 1 đến 5 sao'
      });
    }
    
    // Check if user can review (purchased the product)
    const canReview = await Review.canReview(userId, productId);
    if (!canReview) {
      return res.status(403).json({
        success: false,
        message: 'Bạn chỉ có thể đánh giá sản phẩm đã mua và nhận hàng'
      });
    }
    
    const review = await Review.create({
      user_id: userId,
      product_id: productId,
      rating,
      comment: comment || ''
    });
    
    res.status(201).json({
      success: true,
      message: 'Đánh giá của bạn đã được gửi và đang chờ duyệt',
      data: review
    });
  } catch (error) {
    if (error.message.includes('đã đánh giá')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo đánh giá',
      error: error.message
    });
  }
};

// Update a review
exports.updateReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;
    
    // Validate rating
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Đánh giá phải từ 1 đến 5 sao'
      });
    }
    
    const review = await Review.update(reviewId, userId, {
      rating,
      comment: comment || ''
    });
    
    res.json({
      success: true,
      message: 'Cập nhật đánh giá thành công',
      data: review
    });
  } catch (error) {
    if (error.message.includes('Không có quyền')) {
      return res.status(403).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật đánh giá',
      error: error.message
    });
  }
};

// Delete a review
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.id;
    
    await Review.delete(reviewId, userId);
    
    res.json({
      success: true,
      message: 'Xóa đánh giá thành công'
    });
  } catch (error) {
    if (error.message.includes('Không có quyền')) {
      return res.status(403).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa đánh giá',
      error: error.message
    });
  }
};

// Mark review as helpful
exports.markHelpful = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.id;
    
    const result = await Review.markHelpful(reviewId, userId);
    
    res.json({
      success: true,
      message: result.helpful ? 'Đã đánh dấu hữu ích' : 'Đã bỏ đánh dấu',
      data: result
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi đánh dấu hữu ích',
      error: error.message
    });
  }
};

// Check if user can review a product
exports.canReview = async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;
    
    const canReview = await Review.canReview(userId, productId);
    
    res.json({
      success: true,
      data: { canReview }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi kiểm tra quyền đánh giá',
      error: error.message
    });
  }
};
