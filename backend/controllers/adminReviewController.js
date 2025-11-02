const Review = require('../models/Review');

// GET /api/admin/reviews - Get all reviews with filters
exports.getReviews = async (req, res) => {
  try {
    const { page = 1, limit = 20, status = 'all', sortBy = 'created_at', sortOrder = 'DESC' } = req.query;

    const result = await Review.findAll({
      page,
      limit,
      status,
      sortBy,
      sortOrder
    });

    res.json({
      success: true,
      reviews: result.reviews || [],
      pagination: result.pagination || {}
    });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách đánh giá',
      error: error.message
    });
  }
};

// GET /api/admin/reviews/stats - Get review statistics
exports.getReviewStats = async (req, res) => {
  try {
    const stats = await Review.getAdminStats();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Get review stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thống kê đánh giá',
      error: error.message
    });
  }
};

// PUT /api/admin/reviews/:id/approve - Approve a review
exports.approveReview = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if review exists
    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đánh giá'
      });
    }

    // Update status to approved
    const updatedReview = await Review.updateStatus(id, 'approved');

    res.json({
      success: true,
      message: 'Đã duyệt đánh giá',
      data: updatedReview
    });
  } catch (error) {
    console.error('Approve review error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi duyệt đánh giá',
      error: error.message
    });
  }
};

// PUT /api/admin/reviews/:id/reject - Reject a review
exports.rejectReview = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if review exists
    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đánh giá'
      });
    }

    // Update status to rejected
    const updatedReview = await Review.updateStatus(id, 'rejected');

    res.json({
      success: true,
      message: 'Đã từ chối đánh giá',
      data: updatedReview
    });
  } catch (error) {
    console.error('Reject review error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi từ chối đánh giá',
      error: error.message
    });
  }
};

// DELETE /api/admin/reviews/:id - Delete a review
exports.deleteReview = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if review exists
    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đánh giá'
      });
    }

    // Delete review (admin can delete any review)
    await Review.delete(id, null, true);

    res.json({
      success: true,
      message: 'Đã xóa đánh giá thành công'
    });
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa đánh giá',
      error: error.message
    });
  }
};
