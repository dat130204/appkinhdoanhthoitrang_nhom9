const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const adminOrderController = require('../controllers/adminOrderController');
const adminUserController = require('../controllers/adminUserController');
const adminReviewController = require('../controllers/adminReviewController');
const notificationController = require('../controllers/notificationController');
const settingsController = require('../controllers/settingsController');
const { auth } = require('../middleware/auth');
const isAdmin = require('../middleware/isAdmin');

// All routes require authentication and admin role
const adminAuth = [auth, isAdmin];

// Dashboard statistics
router.get('/dashboard/stats', adminAuth, adminController.getDashboardStats);

// Revenue data by period
router.get('/dashboard/revenue', adminAuth, adminController.getRevenue);

// Top selling products
router.get('/dashboard/top-products', adminAuth, adminController.getTopProducts);

// Current month statistics with growth comparison
router.get('/dashboard/current-month', adminAuth, adminController.getCurrentMonthStats);

// Order Management
// Export orders (must be before /:id routes)
router.get('/orders/export', adminAuth, adminOrderController.exportOrders);

// Get all orders with filters
router.get('/orders', adminAuth, adminOrderController.getOrders);

// Get order by ID
router.get('/orders/:id', adminAuth, adminOrderController.getOrderById);

// Update order status
router.put('/orders/:id/status', adminAuth, adminOrderController.updateOrderStatus);

// Delete order (soft delete)
router.delete('/orders/:id', adminAuth, adminOrderController.deleteOrder);

// User Management
// Get all users with pagination and filters
router.get('/users', adminAuth, adminUserController.getUsers);

// Get user by ID with statistics
router.get('/users/:id', adminAuth, adminUserController.getUserById);

// Update user role
router.put('/users/:id/role', adminAuth, adminUserController.updateUserRole);

// Update user status (block/unblock)
router.put('/users/:id/status', adminAuth, adminUserController.updateUserStatus);

// Delete user (soft delete)
router.delete('/users/:id', adminAuth, adminUserController.deleteUser);

// Review Management
// Get review statistics
router.get('/reviews/stats', adminAuth, adminReviewController.getReviewStats);

// Get all reviews with filters
router.get('/reviews', adminAuth, adminReviewController.getReviews);

// Approve review
router.put('/reviews/:id/approve', adminAuth, adminReviewController.approveReview);

// Reject review
router.put('/reviews/:id/reject', adminAuth, adminReviewController.rejectReview);

// Delete review
router.delete('/reviews/:id', adminAuth, adminReviewController.deleteReview);

// Notification Management
// Send notification to users
router.post('/notifications/send', adminAuth, notificationController.sendNotification);

// Get notification statistics
router.get('/notifications/stats', adminAuth, notificationController.getStatistics);

// Clean old notifications
router.delete('/notifications/clean', adminAuth, notificationController.cleanOldNotifications);

// Settings Management
// Get all settings (admin)
router.get('/settings', adminAuth, settingsController.getAllSettings);

// Get settings grouped by category
router.get('/settings/by-category', adminAuth, settingsController.getSettingsByCategory);

// Get setting by key
router.get('/settings/:key', adminAuth, settingsController.getSettingByKey);

// Update setting by key
router.put('/settings/:key', adminAuth, settingsController.updateSetting);

// Update multiple settings
router.put('/settings', adminAuth, settingsController.updateBulkSettings);

// Create new setting
router.post('/settings', adminAuth, settingsController.createSetting);

// Delete setting
router.delete('/settings/:key', adminAuth, settingsController.deleteSetting);

// Reset settings to default
router.post('/settings/reset', adminAuth, settingsController.resetToDefaults);

module.exports = router;
