const Notification = require('../models/Notification');
const User = require('../models/User');
const emailService = require('../services/emailService');

// Get all notifications for current user
exports.getUserNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const { isRead, type, limit = 50, offset = 0 } = req.query;

    const options = {
      limit: parseInt(limit),
      offset: parseInt(offset)
    };

    if (isRead !== undefined) {
      options.isRead = isRead === 'true';
    }

    if (type) {
      options.type = type;
    }

    const notifications = await Notification.findByUserId(userId, options);
    const unreadCount = await Notification.getUnreadCount(userId);

    res.json({
      success: true,
      data: {
        notifications,
        unreadCount,
        pagination: {
          limit: options.limit,
          offset: options.offset,
          hasMore: notifications.length === options.limit
        }
      }
    });
  } catch (error) {
    console.error('Error getting user notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy danh sách thông báo',
      error: error.message
    });
  }
};

// Get unread count
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await Notification.getUnreadCount(userId);

    res.json({
      success: true,
      data: { unreadCount: count }
    });
  } catch (error) {
    console.error('Error getting unread count:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy số lượng thông báo chưa đọc',
      error: error.message
    });
  }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const success = await Notification.markAsRead(id, userId);

    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông báo'
      });
    }

    res.json({
      success: true,
      message: 'Đã đánh dấu thông báo là đã đọc'
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể đánh dấu thông báo',
      error: error.message
    });
  }
};

// Mark all notifications as read
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await Notification.markAllAsRead(userId);

    res.json({
      success: true,
      message: `Đã đánh dấu ${count} thông báo là đã đọc`,
      data: { markedCount: count }
    });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể đánh dấu tất cả thông báo',
      error: error.message
    });
  }
};

// Delete notification
exports.deleteNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const success = await Notification.delete(id, userId);

    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông báo'
      });
    }

    res.json({
      success: true,
      message: 'Đã xóa thông báo'
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể xóa thông báo',
      error: error.message
    });
  }
};

// Delete all read notifications
exports.deleteAllRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await Notification.deleteAllRead(userId);

    res.json({
      success: true,
      message: `Đã xóa ${count} thông báo đã đọc`,
      data: { deletedCount: count }
    });
  } catch (error) {
    console.error('Error deleting all read notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể xóa thông báo',
      error: error.message
    });
  }
};

// Admin: Send notification to users
exports.sendNotification = async (req, res) => {
  try {
    const { userIds, title, message, type = 'system', sendEmail = false } = req.body;

    // Validation
    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'userIds phải là một mảng không rỗng'
      });
    }

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu title hoặc message'
      });
    }

    const validTypes = ['order', 'promotion', 'system', 'review', 'account'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: `Type không hợp lệ. Phải là một trong: ${validTypes.join(', ')}`
      });
    }

    // Create notifications in database
    const result = await Notification.createBulk(userIds, title, message, type);

    // Send emails if requested
    let emailResults = [];
    if (sendEmail) {
      const users = await Promise.all(
        userIds.map(id => User.findById(id))
      );

      emailResults = await Promise.all(
        users
          .filter(user => user && user.email)
          .map(async user => {
            try {
              let emailResult;
              
              switch (type) {
                case 'promotion':
                  emailResult = await emailService.sendPromotionEmail(
                    user.email,
                    title,
                    message,
                    req.body.promotionData || {}
                  );
                  break;
                case 'account':
                  emailResult = await emailService.sendAccountEmail(
                    user.email,
                    title,
                    message
                  );
                  break;
                default:
                  emailResult = await emailService.sendNotificationEmail(
                    user.email,
                    title,
                    message,
                    type
                  );
              }
              
              return {
                userId: user.id,
                email: user.email,
                success: emailResult.success
              };
            } catch (error) {
              return {
                userId: user.id,
                email: user.email,
                success: false,
                error: error.message
              };
            }
          })
      );
    }

    res.json({
      success: true,
      message: `Đã gửi thông báo đến ${result.insertedCount} người dùng`,
      data: {
        notificationsCreated: result.insertedCount,
        emailsSent: emailResults.filter(r => r.success).length,
        emailResults: sendEmail ? emailResults : undefined
      }
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể gửi thông báo',
      error: error.message
    });
  }
};

// Admin: Get notification statistics
exports.getStatistics = async (req, res) => {
  try {
    const stats = await Notification.getStatistics();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error getting notification statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy thống kê thông báo',
      error: error.message
    });
  }
};

// Admin: Clean old notifications
exports.cleanOldNotifications = async (req, res) => {
  try {
    const { daysOld = 90 } = req.query;
    const count = await Notification.cleanOldNotifications(parseInt(daysOld));

    res.json({
      success: true,
      message: `Đã xóa ${count} thông báo cũ`,
      data: { deletedCount: count }
    });
  } catch (error) {
    console.error('Error cleaning old notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể xóa thông báo cũ',
      error: error.message
    });
  }
};
