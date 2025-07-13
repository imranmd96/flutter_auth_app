import rateLimit from 'express-rate-limit';
import { logger } from '../utils/logger';

export const roleRateLimits = {
  // Admin rate limits
  admin: {
    global: rateLimit({
      windowMs: 60 * 1000, // 1 minute
      max: 100, // 100 requests per minute
      message: 'Too many requests from admin',
      handler: (req, res) => {
        logger.warn('Admin rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many requests from admin'
        });
      }
    }),

    restaurant: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 50, // 50 restaurant operations per hour
      message: 'Too many restaurant operations from admin',
      handler: (req, res) => {
        logger.warn('Admin restaurant rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many restaurant operations from admin'
        });
      }
    })
  },

  // Restaurant owner rate limits
  restaurantOwner: {
    global: rateLimit({
      windowMs: 60 * 1000, // 1 minute
      max: 50, // 50 requests per minute
      message: 'Too many requests from restaurant owner',
      handler: (req, res) => {
        logger.warn('Restaurant owner rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many requests from restaurant owner'
        });
      }
    }),

    menu: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 30, // 30 menu operations per hour
      message: 'Too many menu operations from restaurant owner',
      handler: (req, res) => {
        logger.warn('Restaurant owner menu rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many menu operations from restaurant owner'
        });
      }
    })
  },

  // Customer rate limits
  customer: {
    global: rateLimit({
      windowMs: 60 * 1000, // 1 minute
      max: 30, // 30 requests per minute
      message: 'Too many requests from customer',
      handler: (req, res) => {
        logger.warn('Customer rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many requests from customer'
        });
      }
    }),

    order: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 10, // 10 orders per hour
      message: 'Too many orders from customer',
      handler: (req, res) => {
        logger.warn('Customer order rate limit exceeded', {
          ip: req.ip,
          userId: req.user?.userId
        });
        res.status(429).json({
          status: 'error',
          message: 'Too many orders from customer'
        });
      }
    })
  }
}; 