const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const paymentController = require('../controllers/paymentController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

/**
 * Payment Routes for VNPay Integration
 * Base URL: /api/payment/vnpay
 */

// Validation rules
const createPaymentValidation = [
  body('orderId').isInt().withMessage('Order ID phải là số'),
  body('amount').isFloat({ min: 1000 }).withMessage('Số tiền phải lớn hơn 1,000 VND'),
  body('orderInfo').optional().isString().withMessage('Thông tin đơn hàng phải là chuỗi'),
  body('bankCode').optional().isString().withMessage('Mã ngân hàng phải là chuỗi'),
];

// Create payment URL (protected - requires authentication)
router.post(
  '/create',
  auth,
  createPaymentValidation,
  validate,
  paymentController.createPayment
);

// VNPay return URL (public - called by VNPay)
router.get(
  '/return',
  paymentController.handleReturn
);

// Mobile callback endpoint (public - called by Flutter app)
router.post(
  '/callback',
  paymentController.handleMobileCallback
);

// Get supported banks list (public)
router.get(
  '/banks',
  paymentController.getSupportedBanks
);

// Get payment status by order ID (protected)
router.get(
  '/status/:orderId',
  auth,
  paymentController.getPaymentStatus
);

module.exports = router;
