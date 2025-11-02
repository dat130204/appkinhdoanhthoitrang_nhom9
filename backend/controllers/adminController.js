const db = require('../config/database');

class AdminController {
  // GET /api/admin/dashboard/stats
  async getDashboardStats(req, res) {
    try {
      const conn = await db.getConnection();
      
      try {
        // 1. Tổng doanh thu từ các đơn hàng đã giao thành công
        const [revenueResult] = await conn.query(
          `SELECT COALESCE(SUM(total_amount), 0) as total_revenue 
           FROM orders 
           WHERE status = 'delivered'`
        );
        const totalRevenue = parseFloat(revenueResult[0].total_revenue) || 0;

        // 2. Tổng số đơn hàng
        const [orderCountResult] = await conn.query(
          `SELECT COUNT(*) as total_orders FROM orders`
        );
        const totalOrders = parseInt(orderCountResult[0].total_orders) || 0;

        // 3. Tổng số sản phẩm đang hoạt động
        const [productCountResult] = await conn.query(
          `SELECT COUNT(*) as total_products FROM products WHERE is_active = 1`
        );
        const totalProducts = parseInt(productCountResult[0].total_products) || 0;

        // 4. Tổng số người dùng
        const [userCountResult] = await conn.query(
          `SELECT COUNT(*) as total_users FROM users`
        );
        const totalUsers = parseInt(userCountResult[0].total_users) || 0;

        // 5. Số lượng đơn hàng theo trạng thái
        const [ordersByStatusResult] = await conn.query(
          `SELECT 
            status,
            COUNT(*) as count
           FROM orders
           GROUP BY status`
        );
        
        const ordersByStatus = {
          pending: 0,
          processing: 0,
          shipped: 0,
          delivered: 0,
          cancelled: 0
        };
        
        ordersByStatusResult.forEach(row => {
          if (ordersByStatus.hasOwnProperty(row.status)) {
            ordersByStatus[row.status] = parseInt(row.count);
          }
        });

        // 6. Đơn hàng gần đây (10 đơn mới nhất)
        const [recentOrders] = await conn.query(
          `SELECT 
            o.id,
            o.order_number,
            o.total_amount,
            o.status,
            o.payment_method,
            o.customer_name,
            o.customer_phone,
            o.created_at,
            COUNT(oi.id) as item_count
           FROM orders o
           LEFT JOIN order_items oi ON o.id = oi.order_id
           GROUP BY o.id
           ORDER BY o.created_at DESC
           LIMIT 10`
        );

        // 7. Sản phẩm sắp hết hàng (stock < 10)
        const [lowStockProducts] = await conn.query(
          `SELECT 
            p.id,
            p.name,
            p.sku,
            p.stock_quantity,
            p.price,
            c.name as category_name,
            (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as image_url
           FROM products p
           LEFT JOIN categories c ON p.category_id = c.id
           WHERE p.is_active = 1 AND p.stock_quantity < 10
           ORDER BY p.stock_quantity ASC
           LIMIT 20`
        );

        res.json({
          success: true,
          data: {
            totalRevenue,
            totalOrders,
            totalProducts,
            totalUsers,
            ordersByStatus,
            recentOrders: recentOrders.map(order => ({
              id: order.id,
              orderNumber: order.order_number,
              totalAmount: parseFloat(order.total_amount),
              status: order.status,
              paymentMethod: order.payment_method,
              customerName: order.customer_name,
              customerPhone: order.customer_phone,
              itemCount: parseInt(order.item_count),
              createdAt: order.created_at
            })),
            lowStockProducts: lowStockProducts.map(product => ({
              id: product.id,
              name: product.name,
              sku: product.sku,
              stockQuantity: parseInt(product.stock_quantity),
              price: parseFloat(product.price),
              categoryName: product.category_name,
              imageUrl: product.image_url
            }))
          }
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getDashboardStats:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy thống kê dashboard',
        error: error.message
      });
    }
  }

  // GET /api/admin/dashboard/revenue?period=week|month|year
  async getRevenue(req, res) {
    try {
      const { period = 'week' } = req.query;
      const conn = await db.getConnection();

      try {
        let labels = [];
        let data = [];
        let dateFormat = '';
        let groupBy = '';
        let dateRange = '';

        // Xác định format và range dựa trên period
        switch (period) {
          case 'week':
            // 7 ngày gần đây
            dateFormat = '%Y-%m-%d';
            groupBy = 'DATE(created_at)';
            dateRange = 'DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
            
            // Tạo labels cho 7 ngày
            const today = new Date();
            for (let i = 6; i >= 0; i--) {
              const date = new Date(today);
              date.setDate(date.getDate() - i);
              labels.push(date.toISOString().split('T')[0]);
            }
            break;

          case 'month':
            // 30 ngày gần đây
            dateFormat = '%Y-%m-%d';
            groupBy = 'DATE(created_at)';
            dateRange = 'DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)';
            
            // Tạo labels cho 30 ngày
            const today30 = new Date();
            for (let i = 29; i >= 0; i--) {
              const date = new Date(today30);
              date.setDate(date.getDate() - i);
              labels.push(date.toISOString().split('T')[0]);
            }
            break;

          case 'year':
            // 12 tháng gần đây
            dateFormat = '%Y-%m';
            groupBy = 'DATE_FORMAT(created_at, "%Y-%m")';
            dateRange = 'created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)';
            
            // Tạo labels cho 12 tháng
            const today12 = new Date();
            for (let i = 11; i >= 0; i--) {
              const date = new Date(today12);
              date.setMonth(date.getMonth() - i);
              const year = date.getFullYear();
              const month = String(date.getMonth() + 1).padStart(2, '0');
              labels.push(`${year}-${month}`);
            }
            break;

          default:
            return res.status(400).json({
              success: false,
              message: 'Period không hợp lệ. Chỉ chấp nhận: week, month, year'
            });
        }

        // Query doanh thu theo period
        const [revenueData] = await conn.query(
          `SELECT 
            DATE_FORMAT(created_at, ?) as period_key,
            COALESCE(SUM(total_amount), 0) as revenue
           FROM orders
           WHERE status = 'delivered' AND ${dateRange}
           GROUP BY ${groupBy}
           ORDER BY period_key ASC`,
          [dateFormat]
        );

        // Tạo map từ kết quả query
        const revenueMap = {};
        revenueData.forEach(row => {
          revenueMap[row.period_key] = parseFloat(row.revenue) || 0;
        });

        // Fill data theo labels (điền 0 cho ngày không có doanh thu)
        data = labels.map(label => revenueMap[label] || 0);

        // Tính tổng doanh thu
        const total = data.reduce((sum, value) => sum + value, 0);

        res.json({
          success: true,
          data: {
            labels,
            data,
            total,
            period
          }
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getRevenue:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy dữ liệu doanh thu',
        error: error.message
      });
    }
  }

  // GET /api/admin/dashboard/top-products?limit=10
  async getTopProducts(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 10;
      
      if (limit < 1 || limit > 100) {
        return res.status(400).json({
          success: false,
          message: 'Limit phải từ 1 đến 100'
        });
      }

      const conn = await db.getConnection();

      try {
        // Query sản phẩm bán chạy nhất dựa trên order_items
        // Chỉ tính các đơn hàng đã giao thành công
        const [topProducts] = await conn.query(
          `SELECT 
            p.id as product_id,
            p.name,
            p.sku,
            p.price,
            p.sale_price,
            c.name as category_name,
            SUM(oi.quantity) as total_sold,
            SUM(oi.subtotal) as revenue,
            (SELECT image_url FROM product_images WHERE product_id = p.id AND is_primary = 1 LIMIT 1) as image_url
           FROM order_items oi
           INNER JOIN products p ON oi.product_id = p.id
           INNER JOIN orders o ON oi.order_id = o.id
           LEFT JOIN categories c ON p.category_id = c.id
           WHERE o.status = 'delivered'
           GROUP BY p.id, p.name, p.sku, p.price, p.sale_price, c.name
           ORDER BY total_sold DESC
           LIMIT ?`,
          [limit]
        );

        res.json({
          success: true,
          data: topProducts.map(product => ({
            productId: product.product_id,
            name: product.name,
            sku: product.sku,
            price: parseFloat(product.price),
            salePrice: product.sale_price ? parseFloat(product.sale_price) : null,
            categoryName: product.category_name,
            totalSold: parseInt(product.total_sold),
            revenue: parseFloat(product.revenue),
            imageUrl: product.image_url
          }))
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getTopProducts:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy sản phẩm bán chạy',
        error: error.message
      });
    }
  }

  // Thống kê tổng quan theo tháng hiện tại
  async getCurrentMonthStats(req, res) {
    try {
      const conn = await db.getConnection();

      try {
        // Doanh thu tháng hiện tại
        const [currentMonth] = await conn.query(
          `SELECT 
            COALESCE(SUM(total_amount), 0) as revenue,
            COUNT(*) as order_count
           FROM orders
           WHERE status = 'delivered'
           AND MONTH(created_at) = MONTH(CURDATE())
           AND YEAR(created_at) = YEAR(CURDATE())`
        );

        // Doanh thu tháng trước
        const [lastMonth] = await conn.query(
          `SELECT 
            COALESCE(SUM(total_amount), 0) as revenue,
            COUNT(*) as order_count
           FROM orders
           WHERE status = 'delivered'
           AND MONTH(created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
           AND YEAR(created_at) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))`
        );

        const currentRevenue = parseFloat(currentMonth[0].revenue);
        const lastRevenue = parseFloat(lastMonth[0].revenue);
        const revenueGrowth = lastRevenue > 0 
          ? ((currentRevenue - lastRevenue) / lastRevenue * 100).toFixed(2)
          : 0;

        const currentOrders = parseInt(currentMonth[0].order_count);
        const lastOrders = parseInt(lastMonth[0].order_count);
        const orderGrowth = lastOrders > 0
          ? ((currentOrders - lastOrders) / lastOrders * 100).toFixed(2)
          : 0;

        res.json({
          success: true,
          data: {
            currentMonth: {
              revenue: currentRevenue,
              orderCount: currentOrders
            },
            lastMonth: {
              revenue: lastRevenue,
              orderCount: lastOrders
            },
            growth: {
              revenue: parseFloat(revenueGrowth),
              orders: parseFloat(orderGrowth)
            }
          }
        });
      } finally {
        conn.release();
      }
    } catch (error) {
      console.error('Error in getCurrentMonthStats:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi lấy thống kê tháng hiện tại',
        error: error.message
      });
    }
  }
}

module.exports = new AdminController();
