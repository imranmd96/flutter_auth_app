import { Router } from 'express';
import { AnalyticsController } from '../controllers/analyticsController';
import { authenticate, authorize } from '../middleware/auth';
import { analyticsLimiter } from '../middleware/rateLimit';

const router = Router();

router.get(
  '/restaurant/:restaurantId',
  authenticate,
  authorize(['admin', 'restaurant']),
  analyticsLimiter,
  AnalyticsController.getRestaurantAnalytics
);

router.post(
  '/sentiment',
  analyticsLimiter,
  AnalyticsController.getSentimentAnalysis
);

export default router; 