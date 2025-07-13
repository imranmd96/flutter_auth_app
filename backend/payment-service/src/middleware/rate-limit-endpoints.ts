import rateLimit from 'express-rate-limit';
import { logger } from '../utils/logger';

export const rateLimitEndpoints = {
  // Restaurant endpoints
  restaurant: {
    create: rateLimit({
      windowMs: 24 * 60 * 60 * 1000, // 24 hours
      max: 5, // 5 restaurant creations per day
      message: 'Too many restaurant creation requests',
      handler: (req, res) => {
        logger.warn('Restaurant creation rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many restaurant creation requests'
        });
      }
    }),

    update: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 20, // 20 updates per hour
      message: 'Too many restaurant update requests',
      handler: (req, res) => {
        logger.warn('Restaurant update rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many restaurant update requests'
        });
      }
    })
  },

  // Menu endpoints
  menu: {
    update: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 50, // 50 menu updates per hour
      message: 'Too many menu update requests',
      handler: (req, res) => {
        logger.warn('Menu update rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many menu update requests'
        });
      }
    })
  },

  // Order endpoints
  order: {
    create: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 30, // 30 orders per hour
      message: 'Too many order creation requests',
      handler: (req, res) => {
        logger.warn('Order creation rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many order creation requests'
        });
      }
    }),

    cancel: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 5, // 5 cancellations per hour
      message: 'Too many order cancellation requests',
      handler: (req, res) => {
        logger.warn('Order cancellation rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many order cancellation requests'
        });
      }
    })
  }
}; 