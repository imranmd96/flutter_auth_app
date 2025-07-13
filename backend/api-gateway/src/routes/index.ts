import { Router } from 'express';
import { proxyConfig } from '../config/proxy.config';
import { protect } from '../middleware/auth.middleware';
import { apiLimiter, authLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

// Health check endpoint
router.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'API Gateway is running'
  });
});
router.post('/test-health', (_req, res) => {
  console.log(_req.body);
  res.status(200).json({
    
    status: 'success',
    message: 'API Gateway is running'
  });
});

// Auth service routes
router.use('/api/auth', proxyConfig.auth);

// router.use('/api/auth', authLimiter, proxyConfig.auth);

// User service routes
router.use('/api/users', authLimiter, proxyConfig.user);

// Restaurant service routes
router.use('/api/restaurants', apiLimiter, proxyConfig.restaurant);

// Order service routes
router.use('/api/orders', protect, apiLimiter, proxyConfig.order);

// Booking service routes
router.use('/api/bookings', protect, apiLimiter, proxyConfig.booking);

// Inventory service routes
router.use('/api/inventory', protect, apiLimiter, proxyConfig.inventory);

// Notification service routes
router.use('/api/notification', protect, apiLimiter, proxyConfig.notification);

// Review service routes
router.use('/api/review', apiLimiter, proxyConfig.review);

// Menu service routes
router.use('/api/menu', apiLimiter, proxyConfig.menu);

// Payment service routes
router.use('/api/payment', protect, apiLimiter, proxyConfig.payment);

// Analytics service routes
router.use('/api/analytics', protect, apiLimiter, proxyConfig.analytics);

// Chat service routes
router.use('/api/chat', protect, apiLimiter, proxyConfig.chat);

// Media service routes
router.use('/api/media', apiLimiter, proxyConfig.media);

export default router; 