import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export const performanceMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = process.hrtime();

  res.on('finish', () => {
    const [seconds, nanoseconds] = process.hrtime(start);
    const duration = seconds * 1000 + nanoseconds / 1000000; // Convert to milliseconds

    // Log slow requests
    if (duration > 1000) { // More than 1 second
      logger.warn('Slow request detected', {
        method: req.method,
        path: req.path,
        duration,
        statusCode: res.statusCode
      });
    }

    // Log performance metrics
    logger.info('Request performance', {
      method: req.method,
      path: req.path,
      duration,
      statusCode: res.statusCode,
      memoryUsage: process.memoryUsage()
    });
  });

  next();
}; 