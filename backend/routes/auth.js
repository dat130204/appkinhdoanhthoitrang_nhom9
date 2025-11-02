const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const passport = require('../config/passport');
const authController = require('../controllers/authController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const registerValidation = [
  body('email').isEmail().withMessage('Email không hợp lệ'),
  body('password').isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
  body('full_name').notEmpty().withMessage('Họ tên không được để trống'),
  body('phone').optional().isMobilePhone('vi-VN').withMessage('Số điện thoại không hợp lệ')
];

const loginValidation = [
  body('email').isEmail().withMessage('Email không hợp lệ'),
  body('password').notEmpty().withMessage('Mật khẩu không được để trống')
];

const changePasswordValidation = [
  body('current_password').notEmpty().withMessage('Mật khẩu hiện tại không được để trống'),
  body('new_password').isLength({ min: 6 }).withMessage('Mật khẩu mới phải có ít nhất 6 ký tự')
];

const forgotPasswordValidation = [
  body('email').isEmail().withMessage('Email không hợp lệ')
];

const resetPasswordValidation = [
  body('token').notEmpty().withMessage('Token không được để trống'),
  body('new_password').isLength({ min: 6 }).withMessage('Mật khẩu mới phải có ít nhất 6 ký tự')
];

const addressValidation = [
  body('name').notEmpty().withMessage('Tên địa chỉ không được để trống'),
  body('phone').notEmpty().withMessage('Số điện thoại không được để trống'),
  body('address').notEmpty().withMessage('Địa chỉ không được để trống')
];

const googleMobileValidation = [
  body('idToken').notEmpty().withMessage('ID token không được để trống')
];

// Standard auth routes
router.post('/register', registerValidation, validate, authController.register);
router.post('/login', loginValidation, validate, authController.login);
router.post('/forgot-password', forgotPasswordValidation, validate, authController.forgotPassword);
router.post('/reset-password', resetPasswordValidation, validate, authController.resetPassword);
router.get('/profile', auth, authController.getProfile);
router.put('/profile', auth, authController.updateProfile);
router.put('/change-password', auth, changePasswordValidation, validate, authController.changePassword);

// Admin notifications
router.get('/admin/notifications', auth, authController.getAdminNotifications);

// User addresses
router.get('/addresses', auth, authController.getUserAddresses);
router.post('/addresses', auth, addressValidation, validate, authController.addAddress);
router.put('/addresses/:id', auth, addressValidation, validate, authController.updateAddress);
router.delete('/addresses/:id', auth, authController.deleteAddress);

// Google OAuth routes (web)
router.get('/google',
  passport.authenticate('google', { 
    scope: ['profile', 'email'],
    session: false 
  })
);

router.get('/google/callback',
  passport.authenticate('google', { 
    session: false,
    failureRedirect: `${process.env.FRONTEND_URL}/login?error=google_auth_failed`
  }),
  authController.googleCallback
);

// Google OAuth for mobile (Flutter)
router.post('/google/mobile', 
  googleMobileValidation, 
  validate, 
  authController.googleMobileAuth
);

// Unlink Google account
router.delete('/google/unlink', 
  auth, 
  authController.unlinkGoogle
);

module.exports = router;
