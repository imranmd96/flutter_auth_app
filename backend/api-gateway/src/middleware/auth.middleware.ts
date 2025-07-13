import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './error.middleware';
import { logger } from '../utils/logger';

interface JwtPayload {
  id: string;
  iat: number;
  exp: number;
}

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
      };
    }
  }
}

export const protect = async (
  req: Request,
  _res: Response,
  next: NextFunction
) => {
  try {
    // 1) Check if token exists
    let token;
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return next(new AppError('You are not logged in', 401));
    }

    // 2) Verify token
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your-secret-key'
    ) as JwtPayload;

    // 3) Check if user still exists
    // Note: In a real application, you would verify the user exists in the database
    // For the API Gateway, we'll just pass the user ID to the microservices
    req.user = {
      id: decoded.id
    };

    next();
  } catch (error) {
    logger.error(`Authentication error: ${error}`);
    next(new AppError('Authentication failed', 401));
  }
};

export const restrictTo = (..._roles: string[]) => {
  return (_req: Request, _res: Response, next: NextFunction) => {
    // Note: In a real application, you would check the user's role from the database
    // For the API Gateway, we'll just pass the role check to the microservices
    next();
  };
}; 