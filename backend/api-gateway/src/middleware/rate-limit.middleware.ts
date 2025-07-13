import rateLimit from 'express-rate-limit';
import { AppError } from './error.middleware';

export const createRateLimiter = (windowMs: number, max: number) => {
  return rateLimit({
    windowMs,
    max,
    message: new AppError('Too many requests from this IP, please try again later', 429),
    standardHeaders: true,
    legacyHeaders: false
  });
};

// Create different rate limiters for different routes
export const authLimiter = createRateLimiter(15 * 60 * 1000, 100); // 100 requests per 15 minutes
export const apiLimiter = createRateLimiter(60 * 60 * 1000, 1000); // 1000 requests per hour
export const strictLimiter = createRateLimiter(60 * 1000, 10); // 10 requests per minute 