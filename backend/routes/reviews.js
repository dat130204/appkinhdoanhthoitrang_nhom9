const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { auth } = require('../middleware/auth');
const { body } = require('express-validator');

// Validation middleware
const reviewValidation = [
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment').optional().isString().trim()
];

// Get reviews for a product (public)
router.get('/products/:productId', reviewController.getProductReviews);

// Check if user can review (requires auth)
router.get(
  '/products/:productId/can-review',
  auth,
  reviewController.canReview
);

// Create a review (requires auth)
router.post(
  '/products/:productId',
  auth,
  reviewValidation,
  reviewController.createReview
);

// Update a review (requires auth)
router.put(
  '/:reviewId',
  auth,
  reviewValidation,
  reviewController.updateReview
);

// Delete a review (requires auth)
router.delete(
  '/:reviewId',
  auth,
  reviewController.deleteReview
);

// Mark review as helpful (requires auth)
router.post(
  '/:reviewId/helpful',
  auth,
  reviewController.markHelpful
);

module.exports = router;
