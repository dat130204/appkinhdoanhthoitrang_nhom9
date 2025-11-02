const vnpayService = require('../services/vnpayService');
const Order = require('../models/Order');
const moment = require('moment');

/**
 * Payment Controller
 * Handles VNPay payment integration
 */
class PaymentController {
  /**
   * Create VNPay payment URL
   * POST /api/payment/vnpay/create
   */
  async createPayment(req, res) {
    try {
      const { orderId, amount, orderInfo, bankCode } = req.body;

      // Validate input
      if (!orderId || !amount) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu thông tin đơn hàng hoặc số tiền'
        });
      }

      // Verify order exists
      const order = await Order.findById(orderId);
      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng'
        });
      }

      // Check if order already paid
      if (order.payment_status === 'paid') {
        return res.status(400).json({
          success: false,
          message: 'Đơn hàng đã được thanh toán'
        });
      }

      // Get client IP address
      const ipAddr = req.headers['x-forwarded-for'] ||
                     req.connection.remoteAddress ||
                     req.socket.remoteAddress ||
                     req.connection.socket?.remoteAddress ||
                     '127.0.0.1';

      // Create payment URL
      const paymentUrl = vnpayService.createPaymentUrl(
        order.order_number,
        amount,
        orderInfo || `Thanh toán đơn hàng ${order.order_number}`,
        ipAddr,
        bankCode || ''
      );

      // Update order payment method to VNPay
      await Order.update(orderId, { payment_method: 'VNPay' });

      res.json({
        success: true,
        message: 'Tạo URL thanh toán thành công',
        data: {
          paymentUrl,
          orderId: order.id,
          orderNumber: order.order_number,
          amount
        }
      });
    } catch (error) {
      console.error('Create payment error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi tạo URL thanh toán'
      });
    }
  }

  /**
   * Handle VNPay return URL
   * GET /api/payment/vnpay/return
   */
  async handleReturn(req, res) {
    try {
      const vnp_Params = req.query;

      // Verify signature
      const isValid = vnpayService.verifyReturnUrl(vnp_Params);
      
      if (!isValid) {
        return res.redirect(
          `${process.env.FRONTEND_URL || 'http://localhost:8080'}/payment/failed?reason=invalid_signature`
        );
      }

      // Parse payment result
      const paymentResult = vnpayService.parseReturnParams(vnp_Params);
      const isSuccess = vnpayService.isPaymentSuccess(paymentResult.responseCode);

      // Find order by order number (vnp_TxnRef)
      const order = await Order.findByOrderNumber(paymentResult.orderId);

      if (!order) {
        return res.redirect(
          `${process.env.FRONTEND_URL || 'http://localhost:8080'}/payment/failed?reason=order_not_found`
        );
      }

      // Update order payment information
      const paymentStatus = isSuccess ? 'paid' : 'failed';
      await Order.updatePaymentInfo(order.id, {
        payment_status: paymentStatus,
        transaction_id: paymentResult.transactionNo,
        payment_date: paymentResult.payDate ? 
          moment(paymentResult.payDate, 'YYYYMMDDHHmmss').toDate() : 
          new Date(),
        payment_response: vnp_Params
      });

      // Update order status if payment successful
      if (isSuccess) {
        await Order.updateStatus(order.id, 'confirmed');
      }

      // Redirect to frontend with result
      const redirectUrl = isSuccess
        ? `${process.env.FRONTEND_URL || 'http://localhost:8080'}/payment/success?orderId=${order.id}&orderNumber=${order.order_number}&amount=${paymentResult.amount}`
        : `${process.env.FRONTEND_URL || 'http://localhost:8080'}/payment/failed?orderId=${order.id}&reason=${paymentResult.responseCode}&message=${encodeURIComponent(vnpayService.getResponseMessage(paymentResult.responseCode))}`;

      res.redirect(redirectUrl);
    } catch (error) {
      console.error('Handle return error:', error);
      res.redirect(
        `${process.env.FRONTEND_URL || 'http://localhost:8080'}/payment/failed?reason=system_error`
      );
    }
  }

  /**
   * Handle VNPay mobile callback (for Flutter deep link)
   * POST /api/payment/vnpay/callback
   */
  async handleMobileCallback(req, res) {
    try {
      const vnp_Params = req.body;

      // Verify signature
      const isValid = vnpayService.verifyReturnUrl(vnp_Params);
      
      if (!isValid) {
        return res.status(400).json({
          success: false,
          message: 'Chữ ký không hợp lệ'
        });
      }

      // Parse payment result
      const paymentResult = vnpayService.parseReturnParams(vnp_Params);
      const isSuccess = vnpayService.isPaymentSuccess(paymentResult.responseCode);

      // Find order by order number
      const order = await Order.findByOrderNumber(paymentResult.orderId);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng'
        });
      }

      // Update order payment information
      const paymentStatus = isSuccess ? 'paid' : 'failed';
      await Order.updatePaymentInfo(order.id, {
        payment_status: paymentStatus,
        transaction_id: paymentResult.transactionNo,
        payment_date: paymentResult.payDate ? 
          moment(paymentResult.payDate, 'YYYYMMDDHHmmss').toDate() : 
          new Date(),
        payment_response: vnp_Params
      });

      // Update order status if payment successful
      if (isSuccess) {
        await Order.updateStatus(order.id, 'confirmed');
      }

      res.json({
        success: true,
        message: isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
        data: {
          orderId: order.id,
          orderNumber: order.order_number,
          paymentStatus,
          amount: paymentResult.amount,
          transactionNo: paymentResult.transactionNo,
          responseCode: paymentResult.responseCode,
          responseMessage: vnpayService.getResponseMessage(paymentResult.responseCode)
        }
      });
    } catch (error) {
      console.error('Handle mobile callback error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xử lý callback thanh toán'
      });
    }
  }

  /**
   * Get list of supported banks
   * GET /api/payment/vnpay/banks
   */
  async getSupportedBanks(req, res) {
    try {
      const banks = vnpayService.getSupportedBanks();
      
      res.json({
        success: true,
        data: banks
      });
    } catch (error) {
      console.error('Get banks error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách ngân hàng'
      });
    }
  }

  /**
   * Get payment status by order ID
   * GET /api/payment/vnpay/status/:orderId
   */
  async getPaymentStatus(req, res) {
    try {
      const { orderId } = req.params;

      const order = await Order.findById(orderId);

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy đơn hàng'
        });
      }

      res.json({
        success: true,
        data: {
          orderId: order.id,
          orderNumber: order.order_number,
          paymentMethod: order.payment_method,
          paymentStatus: order.payment_status,
          transactionId: order.transaction_id,
          paymentDate: order.payment_date,
          amount: order.total_amount
        }
      });
    } catch (error) {
      console.error('Get payment status error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy trạng thái thanh toán'
      });
    }
  }
}

module.exports = new PaymentController();
