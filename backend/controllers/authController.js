const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const emailService = require('../services/emailService');

// Google OAuth client for mobile token verification
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

class AuthController {
  async register(req, res) {
    try {
      const { email, password, full_name, phone } = req.body;

      // Check if user exists
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email đã được sử dụng'
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user
      const userId = await User.create({
        email,
        password: hashedPassword,
        full_name,
        phone,
        role: 'customer'
      });

      const user = await User.findById(userId);

      // Generate token
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      res.status(201).json({
        success: true,
        message: 'Đăng ký thành công',
        data: {
          user: {
            id: user.id,
            email: user.email,
            full_name: user.full_name,
            phone: user.phone,
            role: user.role
          },
          token
        }
      });
    } catch (error) {
      console.error('Register error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi đăng ký tài khoản'
      });
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Find user
      const user = await User.findByEmail(email);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Email hoặc mật khẩu không đúng'
        });
      }

      // Check if account is active
      if (!user.is_active) {
        return res.status(403).json({
          success: false,
          message: 'Tài khoản đã bị khóa'
        });
      }

      // Verify password
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Email hoặc mật khẩu không đúng'
        });
      }

      // Generate token
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      res.json({
        success: true,
        message: 'Đăng nhập thành công',
        data: {
          user: {
            id: user.id,
            email: user.email,
            full_name: user.full_name,
            phone: user.phone,
            address: user.address,
            role: user.role,
            avatar: user.avatar
          },
          token
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi đăng nhập'
      });
    }
  }

  async getProfile(req, res) {
    try {
      const user = await User.findById(req.user.id);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Người dùng không tồn tại'
        });
      }

      res.json({
        success: true,
        data: {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          phone: user.phone,
          address: user.address,
          role: user.role,
          avatar: user.avatar,
          created_at: user.created_at
        }
      });
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thông tin người dùng'
      });
    }
  }

  async updateProfile(req, res) {
    try {
      const { full_name, phone, address } = req.body;
      const updates = {};

      if (full_name) updates.full_name = full_name;
      if (phone) updates.phone = phone;
      if (address) updates.address = address;

      const updated = await User.update(req.user.id, updates);

      if (!updated) {
        return res.status(400).json({
          success: false,
          message: 'Không thể cập nhật thông tin'
        });
      }

      const user = await User.findById(req.user.id);

      res.json({
        success: true,
        message: 'Cập nhật thông tin thành công',
        data: {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          phone: user.phone,
          address: user.address,
          role: user.role,
          avatar: user.avatar
        }
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật thông tin'
      });
    }
  }

  async changePassword(req, res) {
    try {
      const { current_password, new_password } = req.body;

      // Get user with password
      const user = await User.findByEmail(req.user.email);

      // Verify current password
      const isPasswordValid = await bcrypt.compare(current_password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Mật khẩu hiện tại không đúng'
        });
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(new_password, 10);

      // Update password
      await User.updatePassword(req.user.id, hashedPassword);

      res.json({
        success: true,
        message: 'Đổi mật khẩu thành công'
      });
    } catch (error) {
      console.error('Change password error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi đổi mật khẩu'
      });
    }
  }

  async getAdminNotifications(req, res) {
    try {
      // Check if user is admin
      if (req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Không có quyền truy cập'
        });
      }

      const db = require('../config/database');

      // Get recent orders count
      const [newOrders] = await db.query(
        'SELECT COUNT(*) as count FROM orders WHERE status = ? AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)',
        ['pending']
      );

      // Get pending reviews count
      const [pendingReviews] = await db.query(
        "SELECT COUNT(*) as count FROM reviews WHERE status = 'pending'"
      );

      // Get new users count (last 7 days)
      const [newUsers] = await db.query(
        'SELECT COUNT(*) as count FROM users WHERE created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)'
      );

      // Build notifications
      const notifications = [];

      if (newOrders[0].count > 0) {
        notifications.push({
          id: 1,
          title: 'Đơn hàng mới',
          message: `Có ${newOrders[0].count} đơn hàng mới cần xử lý`,
          type: 'order',
          time: '5 phút trước',
          isRead: false
        });
      }

      if (pendingReviews[0].count > 0) {
        notifications.push({
          id: 2,
          title: 'Đánh giá chờ duyệt',
          message: `Có ${pendingReviews[0].count} đánh giá cần phê duyệt`,
          type: 'review',
          time: '1 giờ trước',
          isRead: false
        });
      }

      if (newUsers[0].count > 0) {
        notifications.push({
          id: 3,
          title: 'Người dùng mới',
          message: `${newUsers[0].count} người dùng đã đăng ký tuần này`,
          type: 'user',
          time: '2 giờ trước',
          isRead: true
        });
      }

      res.json({
        success: true,
        data: notifications
      });
    } catch (error) {
      console.error('Get admin notifications error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thông báo'
      });
    }
  }

  async getUserAddresses(req, res) {
    try {
      const db = require('../config/database');
      const [addresses] = await db.query(
        'SELECT * FROM user_addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC',
        [req.user.id]
      );

      res.json({
        success: true,
        data: addresses
      });
    } catch (error) {
      console.error('Get addresses error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách địa chỉ'
      });
    }
  }

  async addAddress(req, res) {
    try {
      const { name, phone, address, is_default } = req.body;
      const db = require('../config/database');

      // If this is default, unset other defaults
      if (is_default) {
        await db.query(
          'UPDATE user_addresses SET is_default = 0 WHERE user_id = ?',
          [req.user.id]
        );
      }

      const [result] = await db.query(
        'INSERT INTO user_addresses (user_id, name, phone, address, is_default) VALUES (?, ?, ?, ?, ?)',
        [req.user.id, name, phone, address, is_default ? 1 : 0]
      );

      res.status(201).json({
        success: true,
        message: 'Thêm địa chỉ thành công',
        data: {
          id: result.insertId,
          user_id: req.user.id,
          name,
          phone,
          address,
          is_default: is_default ? 1 : 0
        }
      });
    } catch (error) {
      console.error('Add address error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi thêm địa chỉ'
      });
    }
  }

  async updateAddress(req, res) {
    try {
      const { id } = req.params;
      const { name, phone, address, is_default } = req.body;
      const db = require('../config/database');

      // Verify ownership
      const [existing] = await db.query(
        'SELECT * FROM user_addresses WHERE id = ? AND user_id = ?',
        [id, req.user.id]
      );

      if (existing.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Địa chỉ không tồn tại'
        });
      }

      // If this is default, unset other defaults
      if (is_default) {
        await db.query(
          'UPDATE user_addresses SET is_default = 0 WHERE user_id = ? AND id != ?',
          [req.user.id, id]
        );
      }

      await db.query(
        'UPDATE user_addresses SET name = ?, phone = ?, address = ?, is_default = ? WHERE id = ?',
        [name, phone, address, is_default ? 1 : 0, id]
      );

      res.json({
        success: true,
        message: 'Cập nhật địa chỉ thành công'
      });
    } catch (error) {
      console.error('Update address error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật địa chỉ'
      });
    }
  }

  async deleteAddress(req, res) {
    try {
      const { id } = req.params;
      const db = require('../config/database');

      // Verify ownership
      const [existing] = await db.query(
        'SELECT * FROM user_addresses WHERE id = ? AND user_id = ?',
        [id, req.user.id]
      );

      if (existing.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Địa chỉ không tồn tại'
        });
      }

      await db.query('DELETE FROM user_addresses WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Xóa địa chỉ thành công'
      });
    } catch (error) {
      console.error('Delete address error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa địa chỉ'
      });
    }
  }

  async forgotPassword(req, res) {
    try {
      const { email } = req.body;

      // Check if user exists
      const user = await User.findByEmail(email);
      if (!user) {
        // Don't reveal if user exists
        return res.json({
          success: true,
          message: 'Nếu email tồn tại, chúng tôi đã gửi link đặt lại mật khẩu'
        });
      }

      // Generate reset token
      const resetToken = crypto.randomBytes(32).toString('hex');
      const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');
      const resetTokenExpires = new Date(Date.now() + 3600000); // 1 hour

      // Save reset token to database
      await User.setPasswordResetToken(user.id, hashedToken, resetTokenExpires);

      // Send reset email
      await emailService.sendPasswordReset(email, resetToken);

      res.json({
        success: true,
        message: 'Nếu email tồn tại, chúng tôi đã gửi link đặt lại mật khẩu'
      });
    } catch (error) {
      console.error('Forgot password error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xử lý yêu cầu đặt lại mật khẩu'
      });
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, new_password } = req.body;

      // Hash the token to compare with database
      const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

      // Find user with valid reset token
      const user = await User.findByResetToken(hashedToken);

      if (!user) {
        return res.status(400).json({
          success: false,
          message: 'Token không hợp lệ hoặc đã hết hạn'
        });
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(new_password, 10);

      // Update password and clear reset token
      await User.resetPassword(user.id, hashedPassword);

      res.json({
        success: true,
        message: 'Đặt lại mật khẩu thành công'
      });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi đặt lại mật khẩu'
      });
    }
  }

  /**
   * Google OAuth callback handler (web)
   * Called by Passport after successful Google authentication
   */
  async googleCallback(req, res) {
    try {
      // User is attached to req by Passport middleware
      const user = req.user;

      if (!user) {
        return res.redirect(`${process.env.FRONTEND_URL}/login?error=authentication_failed`);
      }

      // Generate JWT token
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      // Redirect to frontend with token
      const redirectUrl = `${process.env.FRONTEND_URL}/auth/google/callback?token=${token}`;
      res.redirect(redirectUrl);
    } catch (error) {
      console.error('Google callback error:', error);
      res.redirect(`${process.env.FRONTEND_URL}/login?error=server_error`);
    }
  }

  /**
   * Google OAuth handler for mobile (Flutter)
   * Accepts Google ID token from Flutter google_sign_in package
   */
  async googleMobileAuth(req, res) {
    try {
      const { idToken } = req.body;

      if (!idToken) {
        return res.status(400).json({
          success: false,
          message: 'ID token là bắt buộc'
        });
      }

      // Verify Google ID token
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID
      });

      const payload = ticket.getPayload();
      const googleId = payload.sub;
      const email = payload.email;
      const emailVerified = payload.email_verified;
      const firstName = payload.given_name || '';
      const lastName = payload.family_name || '';
      const avatar = payload.picture || null;

      if (!emailVerified) {
        return res.status(400).json({
          success: false,
          message: 'Email chưa được xác thực bởi Google'
        });
      }

      // Check if user exists with Google ID
      let user = await User.findByGoogleId(googleId);

      if (!user) {
        // Check if user exists with email (link account)
        user = await User.findByEmail(email);

        if (user) {
          // Link Google account to existing user
          await User.linkGoogleAccount(user.id, googleId);
          user = await User.findById(user.id);
        } else {
          // Create new user
          const newUserData = {
            email,
            firstName,
            lastName,
            googleId,
            avatar,
            emailVerified,
            role: 'customer'
          };
          user = await User.createFromGoogle(newUserData);
        }
      }

      // Check if user account is active
      if (!user.is_active) {
        return res.status(403).json({
          success: false,
          message: 'Tài khoản đã bị khóa'
        });
      }

      // Generate JWT token
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      res.json({
        success: true,
        message: 'Đăng nhập Google thành công',
        data: {
          user: {
            id: user.id,
            email: user.email,
            full_name: user.full_name,
            phone: user.phone,
            address: user.address,
            role: user.role,
            avatar: user.avatar,
            google_id: user.google_id
          },
          token
        }
      });
    } catch (error) {
      console.error('Google mobile auth error:', error);
      
      // Handle specific Google verification errors
      if (error.message && error.message.includes('Token used too late')) {
        return res.status(400).json({
          success: false,
          message: 'Token đã hết hạn, vui lòng đăng nhập lại'
        });
      }

      if (error.message && error.message.includes('Invalid token')) {
        return res.status(400).json({
          success: false,
          message: 'Token không hợp lệ'
        });
      }

      res.status(500).json({
        success: false,
        message: 'Lỗi xác thực Google'
      });
    }
  }

  /**
   * Unlink Google account from current user
   */
  async unlinkGoogle(req, res) {
    try {
      const userId = req.user.id;

      // Check if user has password set (prevent locking out)
      const user = await User.findById(userId);
      if (!user.password) {
        return res.status(400).json({
          success: false,
          message: 'Không thể hủy liên kết Google vì bạn chưa đặt mật khẩu. Vui lòng đặt mật khẩu trước.'
        });
      }

      // Unlink Google account
      const success = await User.unlinkGoogleAccount(userId);

      if (!success) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy tài khoản Google liên kết'
        });
      }

      res.json({
        success: true,
        message: 'Đã hủy liên kết tài khoản Google thành công'
      });
    } catch (error) {
      console.error('Unlink Google error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi hủy liên kết tài khoản Google'
      });
    }
  }
}

module.exports = new AuthController();
