const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settingsController');
const { auth } = require('../middleware/auth');

// Public routes (no authentication required)
router.get('/public', settingsController.getPublicSettings);
router.get('/store-info', settingsController.getStoreInfo);

// Protected routes (require authentication)
router.get('/', auth, settingsController.getAllSettings);
router.get('/by-category', auth, settingsController.getSettingsByCategory);
router.get('/:key', auth, settingsController.getSettingByKey);

module.exports = router;
