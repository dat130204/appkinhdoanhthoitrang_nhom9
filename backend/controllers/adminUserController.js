const pool = require('../config/database');

// GET /api/admin/users - Get all users with pagination, search, and filters
exports.getUsers = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      role = 'all',
      status = 'all',
      search = '',
      sortBy = 'created_at',
      sortOrder = 'DESC'
    } = req.query;

    const offset = (parseInt(page) - 1) * parseInt(limit);

    // Build WHERE clause
    let whereConditions = [];
    const params = [];

    if (role !== 'all') {
      whereConditions.push('u.role = ?');
      params.push(role);
    }

    if (status !== 'all') {
      whereConditions.push('u.is_active = ?');
      params.push(status === 'active' ? 1 : 0);
    }

    if (search) {
      whereConditions.push('(u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern, searchPattern);
    }

    const whereClause = whereConditions.length > 0 ? 'WHERE ' + whereConditions.join(' AND ') : '';

    // Get total count
    const [countResult] = await pool.query(
      `SELECT COUNT(*) as total 
       FROM users u 
       ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    // Validate sort column - map frontend names to actual DB columns
    const sortColumnMap = {
      'name': 'u.full_name',
      'email': 'u.email',
      'role': 'u.role',
      'status': 'u.is_active',
      'created_at': 'u.created_at',
      'orders_count': 'orders_count',
      'total_spent': 'total_spent'
    };
    const sortColumn = sortColumnMap[sortBy] || 'u.created_at';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

    // Get users with statistics
    const [users] = await pool.query(
      `SELECT 
        u.id,
        u.full_name as name,
        u.email,
        u.phone,
        u.role,
        u.is_active as status,
        u.avatar,
        u.created_at,
        COUNT(DISTINCT o.id) as orders_count,
        COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN o.total_amount ELSE 0 END), 0) as total_spent,
        MAX(o.created_at) as last_order_date
       FROM users u
       LEFT JOIN orders o ON u.id = o.user_id AND o.deleted_at IS NULL
       ${whereClause}
       GROUP BY u.id
       ORDER BY ${sortColumn} ${order}
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    res.json({
      success: true,
      data: {
        users: users.map(user => ({
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          status: user.status === 1 || user.status === '1' ? 'active' : 'blocked',
          avatar: user.avatar,
          createdAt: user.created_at,
          ordersCount: parseInt(user.orders_count),
          totalSpent: parseFloat(user.total_spent),
          lastOrderDate: user.last_order_date
        })),
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / parseInt(limit)),
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNextPage: offset + users.length < total,
          hasPreviousPage: parseInt(page) > 1
        }
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách người dùng',
      error: error.message
    });
  }
};

// GET /api/admin/users/:id - Get user detail with order history
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    // Get user info
    const [users] = await pool.query(
      `SELECT 
        u.id,
        u.full_name as name,
        u.email,
        u.phone,
        u.role,
        u.is_active as status,
        u.avatar,
        u.address,
        u.created_at,
        u.updated_at
       FROM users u
       WHERE u.id = ?`,
      [id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    const user = users[0];

    // Get user statistics
    const [stats] = await pool.query(
      `SELECT 
        COUNT(DISTINCT o.id) as total_orders,
        COALESCE(SUM(CASE WHEN o.status = 'pending' THEN 1 ELSE 0 END), 0) as pending_orders,
        COALESCE(SUM(CASE WHEN o.status = 'processing' THEN 1 ELSE 0 END), 0) as processing_orders,
        COALESCE(SUM(CASE WHEN o.status = 'shipped' THEN 1 ELSE 0 END), 0) as shipped_orders,
        COALESCE(SUM(CASE WHEN o.status = 'delivered' THEN 1 ELSE 0 END), 0) as delivered_orders,
        COALESCE(SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END), 0) as cancelled_orders,
        COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN o.total_amount ELSE 0 END), 0) as total_spent,
        COALESCE(AVG(CASE WHEN o.status != 'cancelled' THEN o.total_amount ELSE NULL END), 0) as average_order_value,
        MAX(o.created_at) as last_order_date
       FROM orders o
       WHERE o.user_id = ? AND o.deleted_at IS NULL`,
      [id]
    );

    // Get order history (last 10 orders)
    const [orders] = await pool.query(
      `SELECT 
        o.id,
        o.order_number,
        o.status,
        o.total_amount,
        o.payment_method,
        o.created_at,
        COUNT(oi.id) as items_count
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       WHERE o.user_id = ? AND o.deleted_at IS NULL
       GROUP BY o.id
       ORDER BY o.created_at DESC
       LIMIT 10`,
      [id]
    );

    // Get monthly spending (last 6 months)
    const [monthlySpending] = await pool.query(
      `SELECT 
        DATE_FORMAT(o.created_at, '%Y-%m') as month,
        COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN o.total_amount ELSE 0 END), 0) as total,
        COUNT(DISTINCT o.id) as orders_count
       FROM orders o
       WHERE o.user_id = ? 
         AND o.deleted_at IS NULL
         AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
       GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
       ORDER BY month DESC`,
      [id]
    );

    // Get favorite categories
    const [categories] = await pool.query(
      `SELECT 
        c.id,
        c.name,
        COUNT(DISTINCT o.id) as orders_count,
        COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN oi.subtotal ELSE 0 END), 0) as total_spent
       FROM orders o
       JOIN order_items oi ON o.id = oi.order_id
       JOIN products p ON oi.product_id = p.id
       JOIN categories c ON p.category_id = c.id
       WHERE o.user_id = ? AND o.deleted_at IS NULL
       GROUP BY c.id
       ORDER BY orders_count DESC
       LIMIT 5`,
      [id]
    );

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          status: user.status === 1 || user.status === '1' ? 'active' : 'blocked',
          avatar: user.avatar,
          address: user.address,
          createdAt: user.created_at,
          updatedAt: user.updated_at
        },
        statistics: {
          totalOrders: parseInt(stats[0].total_orders),
          pendingOrders: parseInt(stats[0].pending_orders),
          processingOrders: parseInt(stats[0].processing_orders),
          shippedOrders: parseInt(stats[0].shipped_orders),
          deliveredOrders: parseInt(stats[0].delivered_orders),
          cancelledOrders: parseInt(stats[0].cancelled_orders),
          totalSpent: parseFloat(stats[0].total_spent),
          averageOrderValue: parseFloat(stats[0].average_order_value),
          lastOrderDate: stats[0].last_order_date
        },
        orders: orders.map(order => ({
          id: order.id,
          orderNumber: order.order_number,
          status: order.status,
          totalAmount: parseFloat(order.total_amount),
          paymentMethod: order.payment_method,
          createdAt: order.created_at,
          itemsCount: parseInt(order.items_count)
        })),
        monthlySpending: monthlySpending.map(item => ({
          month: item.month,
          total: parseFloat(item.total),
          ordersCount: parseInt(item.orders_count)
        })),
        favoriteCategories: categories.map(cat => ({
          id: cat.id,
          name: cat.name,
          ordersCount: parseInt(cat.orders_count),
          totalSpent: parseFloat(cat.total_spent)
        }))
      }
    });
  } catch (error) {
    console.error('Get user detail error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin người dùng',
      error: error.message
    });
  }
};

// PUT /api/admin/users/:id/role - Update user role
exports.updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    // Validate role
    if (!role || !['user', 'admin'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Role không hợp lệ. Chỉ chấp nhận: user, admin'
      });
    }

    // Check if user exists
    const [users] = await pool.query(
      'SELECT id, role, email FROM users WHERE id = ?',
      [id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    // Prevent changing own role
    if (parseInt(id) === req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Không thể thay đổi quyền của chính bạn'
      });
    }

    // Update role
    await pool.query(
      'UPDATE users SET role = ?, updated_at = NOW() WHERE id = ?',
      [role, id]
    );

    res.json({
      success: true,
      message: `Đã cập nhật quyền người dùng thành ${role === 'admin' ? 'Quản trị viên' : 'Người dùng'}`
    });
  } catch (error) {
    console.error('Update user role error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật quyền người dùng',
      error: error.message
    });
  }
};

// PUT /api/admin/users/:id/status - Update user status (block/unblock)
exports.updateUserStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Validate status
    if (!status || !['active', 'blocked'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Status không hợp lệ. Chỉ chấp nhận: active, blocked'
      });
    }

    // Check if user exists
    const [users] = await pool.query(
      'SELECT id, is_active as status, email FROM users WHERE id = ?',
      [id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    // Prevent changing own status
    if (parseInt(id) === req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Không thể thay đổi trạng thái của chính bạn'
      });
    }

    // Update status
    const isActive = status === 'active' ? 1 : 0;
    await pool.query(
      'UPDATE users SET is_active = ?, updated_at = NOW() WHERE id = ?',
      [isActive, id]
    );

    res.json({
      success: true,
      message: status === 'blocked' 
        ? 'Đã chặn người dùng' 
        : 'Đã mở khóa người dùng'
    });
  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật trạng thái người dùng',
      error: error.message
    });
  }
};

// DELETE /api/admin/users/:id - Soft delete user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const [users] = await pool.query(
      'SELECT id, email FROM users WHERE id = ?',
      [id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    // Prevent deleting yourself
    if (parseInt(id) === req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Không thể xóa tài khoản của chính bạn'
      });
    }

    // Check if user has active orders
    const [activeOrders] = await pool.query(
      `SELECT COUNT(*) as count 
       FROM orders 
       WHERE user_id = ? 
         AND status IN ('pending', 'processing', 'shipped')`,
      [id]
    );

    if (activeOrders[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Không thể xóa người dùng có đơn hàng đang xử lý. Vui lòng hoàn thành hoặc hủy các đơn hàng trước.'
      });
    }

    // Soft delete user (disable account)
    await pool.query(
      'UPDATE users SET is_active = 0, updated_at = NOW() WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Đã xóa người dùng thành công'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa người dùng',
      error: error.message
    });
  }
};
