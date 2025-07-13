import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export class AppError extends Error {
  statusCode: number;
  status: string;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: Error | AppError,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.error(`[${err.statusCode}] ${err.message}`);
    return res.status(err.statusCode).json({
      status: err.status,
      message: err.message
    });
  }

  // Handle MongoDB duplicate key error
  if (err.name === 'MongoError' && (err as any).code === 11000) {
    logger.error(`[409] Duplicate key error`);
    return res.status(409).json({
      status: 'fail',
      message: 'Duplicate field value entered'
    });
  }

  // Handle MongoDB validation error
  if (err.name === 'ValidationError') {
    logger.error(`[400] Validation error`);
    return res.status(400).json({
      status: 'fail',
      message: err.message
    });
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    logger.error(`[401] Invalid token`);
    return res.status(401).json({
      status: 'fail',
      message: 'Invalid token. Please log in again'
    });
  }

  if (err.name === 'TokenExpiredError') {
    logger.error(`[401] Token expired`);
    return res.status(401).json({
      status: 'fail',
      message: 'Your token has expired. Please log in again'
    });
  }

  // Default error
  logger.error(`[500] ${err.message}`);
  return res.status(500).json({
    status: 'error',
    message: 'Something went wrong'
  });
}; 