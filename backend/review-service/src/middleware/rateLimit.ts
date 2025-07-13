import rateLimit from 'express-rate-limit';
import { redis } from '../config/database';

// Redis store for rate limiting
const RedisStore = {
  incr: async (key: string) => {
    const count = await redis.incr(key);
    if (count === 1) {
      await redis.expire(key, 60); // 1 minute window
    }
    return count;
  },
  decrement: async (key: string) => {
    await redis.decr(key);
  },
  resetKey: async (key: string) => {
    await redis.del(key);
  }
};

// Rate limit configuration
export const reviewLimiter = rateLimit({
  store: RedisStore,
  windowMs: 60 * 1000, // 1 minute
  max: 5, // 5 requests per minute
  message: 'Too many review submissions, please try again later'
});

export const analyticsLimiter = rateLimit({
  store: RedisStore,
  windowMs: 60 * 1000, // 1 minute
  max: 30, // 30 requests per minute
  message: 'Too many analytics requests, please try again later'
}); 