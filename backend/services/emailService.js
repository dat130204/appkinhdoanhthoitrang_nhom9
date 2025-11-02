const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    // Create transporter with Gmail (can be changed to other providers)
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER || 'noreply@fashionshop.com',
        pass: process.env.EMAIL_PASSWORD || 'your-app-password'
      }
    });
  }

  // Send order confirmation email
  async sendOrderConfirmation(order, customerEmail) {
    try {
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: customerEmail,
        subject: `Xác nhận đơn hàng #${order.order_number}`,
        html: this.generateOrderConfirmationHTML(order)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Order confirmation email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending order confirmation email:', error);
      return { success: false, error: error.message };
    }
  }

  // Send order status update email
  async sendOrderStatusUpdate(order, customerEmail, newStatus) {
    try {
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: customerEmail,
        subject: `Cập nhật đơn hàng #${order.order_number}`,
        html: this.generateOrderStatusUpdateHTML(order, newStatus)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Order status update email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending order status update email:', error);
      return { success: false, error: error.message };
    }
  }

  // Send password reset email
  async sendPasswordReset(email, resetToken) {
    try {
      const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
      
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: email,
        subject: 'Đặt lại mật khẩu - Fashion Shop',
        html: this.generatePasswordResetHTML(resetLink)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Password reset email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending password reset email:', error);
      return { success: false, error: error.message };
    }
  }

  // Generate order confirmation HTML
  generateOrderConfirmationHTML(order) {
    const itemsHTML = order.items.map(item => `
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #eee;">
          ${item.product_name}
          ${item.size ? `<br><small>Size: ${item.size}</small>` : ''}
          ${item.color ? `<br><small>Màu: ${item.color}</small>` : ''}
        </td>
        <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: center;">
          ${item.quantity}
        </td>
        <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: right;">
          ${this.formatCurrency(item.price)}
        </td>
        <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: right;">
          ${this.formatCurrency(item.price * item.quantity)}
        </td>
      </tr>
    `).join('');

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2C3E50; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .order-info { background: white; padding: 15px; margin: 15px 0; border-radius: 5px; }
          table { width: 100%; border-collapse: collapse; margin: 15px 0; }
          th { background: #f0f0f0; padding: 10px; text-align: left; }
          .total { font-weight: bold; font-size: 18px; }
          .footer { text-align: center; padding: 20px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Fashion Shop</h1>
            <p>Cảm ơn bạn đã đặt hàng!</p>
          </div>
          <div class="content">
            <h2>Đơn hàng #${order.order_number}</h2>
            <div class="order-info">
              <p><strong>Khách hàng:</strong> ${order.customer_name}</p>
              <p><strong>Số điện thoại:</strong> ${order.customer_phone}</p>
              <p><strong>Email:</strong> ${order.customer_email || 'Chưa cung cấp'}</p>
              <p><strong>Địa chỉ giao hàng:</strong> ${order.shipping_address}</p>
              <p><strong>Phương thức thanh toán:</strong> ${this.getPaymentMethodText(order.payment_method)}</p>
            </div>
            
            <h3>Chi tiết đơn hàng:</h3>
            <table>
              <thead>
                <tr>
                  <th>Sản phẩm</th>
                  <th style="text-align: center;">Số lượng</th>
                  <th style="text-align: right;">Đơn giá</th>
                  <th style="text-align: right;">Thành tiền</th>
                </tr>
              </thead>
              <tbody>
                ${itemsHTML}
                <tr>
                  <td colspan="3" style="padding: 10px; text-align: right;"><strong>Tạm tính:</strong></td>
                  <td style="padding: 10px; text-align: right;">${this.formatCurrency(order.subtotal)}</td>
                </tr>
                <tr>
                  <td colspan="3" style="padding: 10px; text-align: right;"><strong>Phí vận chuyển:</strong></td>
                  <td style="padding: 10px; text-align: right;">${this.formatCurrency(order.shipping_fee)}</td>
                </tr>
                ${order.discount > 0 ? `
                <tr>
                  <td colspan="3" style="padding: 10px; text-align: right;"><strong>Giảm giá:</strong></td>
                  <td style="padding: 10px; text-align: right; color: #27ae60;">-${this.formatCurrency(order.discount)}</td>
                </tr>
                ` : ''}
                <tr class="total">
                  <td colspan="3" style="padding: 15px; text-align: right; border-top: 2px solid #333;">Tổng cộng:</td>
                  <td style="padding: 15px; text-align: right; border-top: 2px solid #333; color: #e74c3c;">${this.formatCurrency(order.total_amount)}</td>
                </tr>
              </tbody>
            </table>

            ${order.notes ? `<p><strong>Ghi chú:</strong> ${order.notes}</p>` : ''}

            <p style="margin-top: 20px;">
              Đơn hàng của bạn đang được xử lý. Chúng tôi sẽ thông báo khi đơn hàng được giao đến đơn vị vận chuyển.
            </p>
          </div>
          <div class="footer">
            <p>Mọi thắc mắc xin vui lòng liên hệ: <a href="tel:1900xxxx">1900xxxx</a></p>
            <p>Fashion Shop - Thời trang phong cách Việt</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Generate order status update HTML
  generateOrderStatusUpdateHTML(order, newStatus) {
    const statusMessages = {
      'confirmed': 'Đơn hàng của bạn đã được xác nhận và đang được chuẩn bị.',
      'processing': 'Đơn hàng của bạn đang được đóng gói.',
      'shipping': 'Đơn hàng của bạn đã được giao cho đơn vị vận chuyển.',
      'delivered': 'Đơn hàng của bạn đã được giao thành công. Cảm ơn bạn đã mua hàng!',
      'cancelled': 'Đơn hàng của bạn đã bị hủy.'
    };

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2C3E50; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .status-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #3498db; }
          .footer { text-align: center; padding: 20px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Fashion Shop</h1>
            <p>Cập nhật trạng thái đơn hàng</p>
          </div>
          <div class="content">
            <h2>Đơn hàng #${order.order_number}</h2>
            <div class="status-box">
              <h3>Trạng thái mới: ${this.getStatusText(newStatus)}</h3>
              <p>${statusMessages[newStatus] || 'Đơn hàng của bạn đã được cập nhật.'}</p>
            </div>
            <p>Tổng tiền: <strong>${this.formatCurrency(order.total_amount)}</strong></p>
          </div>
          <div class="footer">
            <p>Mọi thắc mắc xin vui lòng liên hệ: <a href="tel:1900xxxx">1900xxxx</a></p>
            <p>Fashion Shop - Thời trang phong cách Việt</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Generate password reset HTML
  generatePasswordResetHTML(resetLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2C3E50; color: white; padding: 20px; text-align: center; }
          .content { padding: 30px; background: #f9f9f9; }
          .button { display: inline-block; padding: 15px 30px; background: #e74c3c; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Fashion Shop</h1>
            <p>Đặt lại mật khẩu</p>
          </div>
          <div class="content">
            <p>Xin chào,</p>
            <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Fashion Shop của mình.</p>
            <p>Nhấn vào nút bên dưới để đặt lại mật khẩu:</p>
            <p style="text-align: center;">
              <a href="${resetLink}" class="button">Đặt lại mật khẩu</a>
            </p>
            <p>Hoặc sao chép liên kết sau vào trình duyệt:</p>
            <p style="word-break: break-all; background: white; padding: 10px; border-radius: 5px;">${resetLink}</p>
            <p><strong>Lưu ý:</strong> Liên kết này chỉ có hiệu lực trong 1 giờ.</p>
            <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
          </div>
          <div class="footer">
            <p>Email này được gửi tự động, vui lòng không trả lời.</p>
            <p>Fashion Shop - Thời trang phong cách Việt</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Helper methods
  formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  }

  getPaymentMethodText(method) {
    const methods = {
      'cod': 'Thanh toán khi nhận hàng (COD)',
      'bank_transfer': 'Chuyển khoản ngân hàng',
      'momo': 'Ví MoMo',
      'vnpay': 'VNPAY'
    };
    return methods[method] || method;
  }

  getStatusText(status) {
    const statuses = {
      'pending': 'Chờ xác nhận',
      'confirmed': 'Đã xác nhận',
      'processing': 'Đang xử lý',
      'shipping': 'Đang giao hàng',
      'delivered': 'Đã giao hàng',
      'cancelled': 'Đã hủy'
    };
    return statuses[status] || status;
  }

  // Send custom notification email
  async sendNotificationEmail(email, title, message, type = 'system') {
    try {
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: email,
        subject: title,
        html: this.generateNotificationHTML(title, message, type)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Notification email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending notification email:', error);
      return { success: false, error: error.message };
    }
  }

  // Send promotion notification email
  async sendPromotionEmail(email, title, message, promotionData = {}) {
    try {
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: email,
        subject: title,
        html: this.generatePromotionHTML(title, message, promotionData)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Promotion email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending promotion email:', error);
      return { success: false, error: error.message };
    }
  }

  // Send account notification email
  async sendAccountEmail(email, title, message) {
    try {
      const mailOptions = {
        from: `"Fashion Shop" <${process.env.EMAIL_USER || 'noreply@fashionshop.com'}>`,
        to: email,
        subject: title,
        html: this.generateAccountNotificationHTML(title, message)
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Account notification email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('Error sending account notification email:', error);
      return { success: false, error: error.message };
    }
  }

  // Generate notification HTML template
  generateNotificationHTML(title, message, type) {
    const typeColors = {
      'order': '#3498db',
      'promotion': '#e74c3c',
      'system': '#2C3E50',
      'review': '#f39c12',
      'account': '#27ae60'
    };

    const typeIcons = {
      'order': '📦',
      'promotion': '🎁',
      'system': '🔔',
      'review': '⭐',
      'account': '👤'
    };

    const color = typeColors[type] || typeColors['system'];
    const icon = typeIcons[type] || typeIcons['system'];

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; background: #f4f4f4; margin: 0; padding: 0; }
          .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .header { background: ${color}; color: white; padding: 30px 20px; text-align: center; }
          .header h1 { margin: 0; font-size: 32px; }
          .icon { font-size: 48px; margin-bottom: 10px; }
          .content { padding: 30px 20px; }
          .message { background: #f9f9f9; padding: 20px; border-left: 4px solid ${color}; border-radius: 5px; margin: 20px 0; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; color: #666; font-size: 14px; }
          .footer a { color: ${color}; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <div class="icon">${icon}</div>
            <h1>${title}</h1>
          </div>
          <div class="content">
            <div class="message">
              ${message.replace(/\n/g, '<br>')}
            </div>
            <p style="text-align: center; margin-top: 30px;">
              <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}" style="display: inline-block; padding: 12px 30px; background: ${color}; color: white; text-decoration: none; border-radius: 5px; font-weight: bold;">
                Truy cập Fashion Shop
              </a>
            </p>
          </div>
          <div class="footer">
            <p>Fashion Shop - Thời trang phong cách Việt</p>
            <p>Email: contact@fashionshop.com | Hotline: 1900xxxx</p>
            <p><a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/unsubscribe">Hủy đăng ký nhận email</a></p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Generate promotion HTML template
  generatePromotionHTML(title, message, promotionData) {
    const { discountPercent, code, validUntil, imageUrl } = promotionData;

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; background: #f4f4f4; margin: 0; padding: 0; }
          .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .header { background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); color: white; padding: 40px 20px; text-align: center; }
          .header h1 { margin: 0; font-size: 36px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
          .badge { display: inline-block; background: #f39c12; color: white; padding: 10px 20px; border-radius: 50px; font-size: 20px; font-weight: bold; margin: 15px 0; }
          ${imageUrl ? `.promo-image { width: 100%; height: auto; display: block; }` : ''}
          .content { padding: 30px 20px; }
          .message { font-size: 16px; margin: 20px 0; }
          .code-box { background: #f9f9f9; border: 2px dashed #e74c3c; padding: 20px; text-align: center; margin: 25px 0; border-radius: 10px; }
          .code { font-size: 32px; font-weight: bold; color: #e74c3c; letter-spacing: 3px; font-family: monospace; }
          .valid-until { color: #666; font-size: 14px; margin-top: 10px; }
          .cta-button { display: inline-block; padding: 15px 40px; background: #e74c3c; color: white; text-decoration: none; border-radius: 50px; font-weight: bold; font-size: 18px; margin: 20px 0; box-shadow: 0 4px 15px rgba(231,76,60,0.3); transition: all 0.3s; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎁 ${title}</h1>
            ${discountPercent ? `<div class="badge">GIẢM ${discountPercent}%</div>` : ''}
          </div>
          ${imageUrl ? `<img src="${imageUrl}" alt="Promotion" class="promo-image">` : ''}
          <div class="content">
            <div class="message">
              ${message.replace(/\n/g, '<br>')}
            </div>
            ${code ? `
              <div class="code-box">
                <p style="margin: 0 0 10px 0; font-size: 14px; color: #666;">MÃ GIẢM GIÁ</p>
                <div class="code">${code}</div>
                ${validUntil ? `<p class="valid-until">Có hiệu lực đến: ${new Date(validUntil).toLocaleDateString('vi-VN')}</p>` : ''}
              </div>
            ` : ''}
            <p style="text-align: center;">
              <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/products" class="cta-button">
                MUA NGAY
              </a>
            </p>
          </div>
          <div class="footer">
            <p>Fashion Shop - Thời trang phong cách Việt</p>
            <p>Email: contact@fashionshop.com | Hotline: 1900xxxx</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Generate account notification HTML template
  generateAccountNotificationHTML(title, message) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; background: #f4f4f4; margin: 0; padding: 0; }
          .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .header { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); color: white; padding: 30px 20px; text-align: center; }
          .header h1 { margin: 0; font-size: 32px; }
          .icon { font-size: 48px; margin-bottom: 10px; }
          .content { padding: 30px 20px; }
          .message { background: #f9f9f9; padding: 20px; border-left: 4px solid #27ae60; border-radius: 5px; margin: 20px 0; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <div class="icon">👤</div>
            <h1>${title}</h1>
          </div>
          <div class="content">
            <div class="message">
              ${message.replace(/\n/g, '<br>')}
            </div>
            <p style="text-align: center; margin-top: 30px;">
              <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/profile" style="display: inline-block; padding: 12px 30px; background: #27ae60; color: white; text-decoration: none; border-radius: 5px; font-weight: bold;">
                Xem tài khoản
              </a>
            </p>
          </div>
          <div class="footer">
            <p>Fashion Shop - Thời trang phong cách Việt</p>
            <p>Email: contact@fashionshop.com | Hotline: 1900xxxx</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}

module.exports = new EmailService();
