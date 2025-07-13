import express from 'express';
import { config } from 'dotenv';
import cors from 'cors';
import compression from 'compression';
import { connectDB } from './config/database';
import { securityMiddleware } from './middleware/security.middleware';
import { performanceMiddleware } from './middleware/performance.middleware';
import { metricsMiddleware } from './middleware/metrics.middleware';
import { loggingMiddleware } from './middleware/logging.middleware';
import { errorHandler } from './middleware/error.middleware';
import { apiLimiter, paymentLimiter, subscriptionLimiter, globalLimiter, authLimiter } from './middleware/rate-limit.middleware';
import paymentRoutes from './routes/payment.routes';
import webhookRoutes from './routes/webhook.routes';
import { logger } from './utils/logger';
import authRoutes from './auth/auth.routes';
import { authMiddleware } from './auth/auth.middleware';

// Load environment variables
config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(compression());
securityMiddleware(app);
app.use(performanceMiddleware);
app.use(metricsMiddleware);
app.use(loggingMiddleware);

// Rate limiting
app.use('/api', apiLimiter);
app.use('/api/payments', paymentLimiter);
app.use('/api/subscriptions', subscriptionLimiter);
app.use(globalLimiter);
app.use('/api/auth', authLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Webhook routes (must be before body parsing middleware)
app.use('/api/webhooks', webhookRoutes);

// Auth routes
app.use('/api/auth', authRoutes);

// Protected routes
app.use('/api/payments', authMiddleware.authenticate, paymentRoutes);

// Error handling
app.use(errorHandler);

// Connect to database and start server
const startServer = async () => {
  try {
    await connectDB();
    const PORT = process.env.PORT || 3011;
    app.listen(PORT, () => {
      logger.info(`Payment service running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (error) => {
  logger.error('Unhandled Rejection:', error);
  process.exit(1);
});

startServer();

export default app; 