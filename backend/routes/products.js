const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const productController = require('../controllers/productController');
const { auth, isAdmin } = require('../middleware/auth');
const validate = require('../middleware/validate');
const upload = require('../middleware/upload');

// Validation rules for create
const productCreateValidation = [
  body('name').notEmpty().withMessage('Tên sản phẩm không được để trống'),
  body('price').isFloat({ min: 0 }).withMessage('Giá phải là số dương'),
  body('category_id').isInt().withMessage('Danh mục không hợp lệ'),
  body('stock_quantity').optional().isInt({ min: 0 }).withMessage('Số lượng phải là số nguyên dương')
];

// Validation rules for update (all optional - checkFalsy: false to allow empty values)
const productUpdateValidation = [
  body('name').optional({ checkFalsy: false }).notEmpty().withMessage('Tên sản phẩm không được để trống'),
  body('price').optional({ checkFalsy: false }).isFloat({ min: 0 }).withMessage('Giá phải là số dương'),
  body('category_id').optional({ checkFalsy: false }).isInt().withMessage('Danh mục không hợp lệ'),
  body('stock_quantity').optional({ checkFalsy: false }).isInt({ min: 0 }).withMessage('Số lượng phải là số nguyên dương')
];

// Public routes
router.get('/', productController.getAll);
router.get('/featured', productController.getFeatured);
router.get('/brands', productController.getBrands);
router.get('/:id', productController.getById);

// Admin routes
// Export products (must be before /:id route)
router.get('/admin/export', auth, isAdmin, productController.exportProducts);

router.post('/', auth, isAdmin, productCreateValidation, validate, productController.create);
router.put('/:id', auth, isAdmin, productUpdateValidation, validate, productController.update);
router.delete('/:id', auth, isAdmin, productController.delete);

// Upload product images (admin only)
router.post('/upload-images', auth, isAdmin, upload.array('images', 10), productController.uploadImages);

module.exports = router;
