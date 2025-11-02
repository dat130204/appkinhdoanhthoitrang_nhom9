const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const cartController = require('../controllers/cartController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const addItemValidation = [
  body('product_id').isInt().withMessage('Sản phẩm không hợp lệ'),
  body('quantity').isInt({ min: 1 }).withMessage('Số lượng phải lớn hơn 0')
];

const updateItemValidation = [
  body('quantity').isInt({ min: 1 }).withMessage('Số lượng phải lớn hơn 0')
];

// Cart routes
router.get('/', auth, cartController.getCart);
router.post('/items', auth, addItemValidation, validate, cartController.addItem);
router.put('/items/:id', auth, updateItemValidation, validate, cartController.updateItem);
router.delete('/items/:id', auth, cartController.removeItem);
router.delete('/clear', auth, cartController.clearCart);

module.exports = router;
