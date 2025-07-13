import rateLimit from 'express-rate-limit';
import { logger } from '../utils/logger';

export const rateLimitScenarios = {
  // Global API rate limiter
  global: rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // 100 requests per window
    message: 'Too many requests from this IP',
    handler: (req, res) => {
      logger.warn('Global rate limit exceeded', {
        ip: req.ip,
        path: req.path
      });
      res.status(429).json({
        status: 'error',
        message: 'Too many requests from this IP'
      });
    }
  }),

  // Payment-specific rate limiter
  payment: rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 50, // 50 payment requests per hour
    message: 'Too many payment requests',
    handler: (req, res) => {
      logger.warn('Payment rate limit exceeded', {
        ip: req.ip,
        path: req.path
      });
      res.status(429).json({
        status: 'error',
        message: 'Too many payment requests'
      });
    }
  }),

  // Subscription-specific rate limiter
  subscription: rateLimit({
    windowMs: 24 * 60 * 60 * 1000, // 24 hours
    max: 10, // 10 subscription requests per day
    message: 'Too many subscription requests',
    handler: (req, res) => {
      logger.warn('Subscription rate limit exceeded', {
        ip: req.ip,
        path: req.path
      });
      res.status(429).json({
        status: 'error',
        message: 'Too many subscription requests'
      });
    }
  }),

  // Refund-specific rate limiter
  refund: rateLimit({
    windowMs: 24 * 60 * 60 * 1000, // 24 hours
    max: 5, // 5 refund requests per day
    message: 'Too many refund requests',
    handler: (req, res) => {
      logger.warn('Refund rate limit exceeded', {
        ip: req.ip,
        path: req.path
      });
      res.status(429).json({
        status: 'error',
        message: 'Too many refund requests'
      });
    }
  }),

  // IP-based rate limiter
  ipBased: rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 30, // 30 requests per minute
    message: 'Too many requests from this IP',
    handler: (req, res) => {
      logger.warn('IP-based rate limit exceeded', {
        ip: req.ip,
        path: req.path
      });
      res.status(429).json({
        status: 'error',
        message: 'Too many requests from this IP'
      });
    }
  })
}; 