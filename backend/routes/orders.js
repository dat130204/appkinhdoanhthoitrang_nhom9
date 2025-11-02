const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const orderController = require('../controllers/orderController');
const { auth, isAdmin } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const createOrderValidation = [
  body('items').isArray({ min: 1 }).withMessage('Giỏ hàng trống'),
  body('customer_name').notEmpty().withMessage('Tên người nhận không được để trống'),
  body('customer_phone').notEmpty().withMessage('Số điện thoại không được để trống'),
  body('shipping_address').notEmpty().withMessage('Địa chỉ giao hàng không được để trống'),
  body('shipping_city').notEmpty().withMessage('Thành phố không được để trống')
];

// Customer routes
router.post('/', auth, createOrderValidation, validate, orderController.create);
router.get('/my-orders', auth, orderController.getMyOrders);
router.get('/:id', auth, orderController.getOrderDetail);
router.put('/:id/cancel', auth, orderController.cancelOrder);

// Admin routes
router.get('/', auth, isAdmin, orderController.getAllOrders);
router.put('/:id/status', auth, isAdmin, orderController.updateOrderStatus);
router.get('/statistics/summary', auth, isAdmin, orderController.getStatistics);

module.exports = router;
