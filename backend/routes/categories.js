const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const categoryController = require('../controllers/categoryController');
const { auth, isAdmin } = require('../middleware/auth');
const validate = require('../middleware/validate');
const upload = require('../middleware/upload');

// Validation rules
const categoryValidation = [
  body('name').notEmpty().withMessage('Tên danh mục không được để trống')
];

// Public routes
router.get('/', categoryController.getAll);
router.get('/tree', categoryController.getTree);
router.get('/:id', categoryController.getById);

// Admin routes
router.get('/admin/stats', auth, isAdmin, categoryController.getStats);
router.post('/', auth, isAdmin, upload.single('image'), categoryValidation, validate, categoryController.create);
router.put('/:id', auth, isAdmin, upload.single('image'), categoryValidation, validate, categoryController.update);
router.delete('/:id', auth, isAdmin, categoryController.delete);

module.exports = router;
