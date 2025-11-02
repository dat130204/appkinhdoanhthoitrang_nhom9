// Middleware to check if user has admin role
const isAdmin = (req, res, next) => {
  try {
    // Check if user is authenticated (should be called after auth middleware)
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Vui lòng đăng nhập để tiếp tục'
      });
    }

    // Check if user has admin role
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bạn không có quyền truy cập tài nguyên này'
      });
    }

    next();
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi kiểm tra quyền truy cập',
      error: error.message
    });
  }
};

module.exports = isAdmin;
