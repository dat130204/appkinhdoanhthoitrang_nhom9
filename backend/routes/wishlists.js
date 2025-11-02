const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const wishlistController = require('../controllers/wishlistController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const addToWishlistValidation = [
  body('product_id').isInt().withMessage('ID sản phẩm không hợp lệ')
];

// All wishlist routes require authentication
router.get('/', auth, wishlistController.getAll);
router.post('/', auth, addToWishlistValidation, validate, wishlistController.add);
router.delete('/clear', auth, wishlistController.clear);
router.get('/check/:product_id', auth, wishlistController.check);
router.delete('/:product_id', auth, wishlistController.remove);

module.exports = router;
