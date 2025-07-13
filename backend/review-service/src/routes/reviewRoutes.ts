import { Router } from 'express';
import { ReviewController } from '../controllers/reviewController';
import { AnalyticsController } from '../controllers/analyticsController';
import { authenticate, authorize } from '../middleware/auth';
import { validateReview, validateReviewUpdate } from '../middleware/validation';
import { reviewLimiter, analyticsLimiter } from '../middleware/rateLimit';

const router = Router();

// Review routes
router.post(
  '/',
  authenticate,
  authorize(['customer']),
  reviewLimiter,
  validateReview,
  ReviewController.createReview
);

router.get(
  '/restaurant/:restaurantId',
  analyticsLimiter,
  ReviewController.getRestaurantReviews
);

router.get(
  '/user',
  authenticate,
  analyticsLimiter,
  ReviewController.getUserReviews
);

router.put(
  '/:id',
  authenticate,
  validateReviewUpdate,
  ReviewController.updateReview
);

router.delete(
  '/:id',
  authenticate,
  ReviewController.deleteReview
);

// Analytics routes
router.get(
  '/analytics/:restaurantId',
  authenticate,
  authorize(['admin', 'restaurant']),
  analyticsLimiter,
  AnalyticsController.getRestaurantAnalytics
);

router.post(
  '/analytics/sentiment',
  analyticsLimiter,
  AnalyticsController.getSentimentAnalysis
);

export default router; 