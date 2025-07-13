import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './error.middleware.js';
import { User } from '../models/user.model.js';

declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

export const protect = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    console.log('Auth Header:', authHeader);
    if (!authHeader?.startsWith('Bearer ')) {
      return next(new AppError('Not authorized to access this route', 401));
    }

    const token = authHeader.split(' ')[1];
    console.log('Token:', token);

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      console.log('Decoded JWT:', decoded);
    } catch (err) {
      console.error('JWT verification error:', err);
      return next(new AppError('Not authorized to access this route', 401));
    }

    // Get user from token
    const userId = typeof decoded === 'object' && 'id' in decoded ? (decoded as any).id : undefined;
    const user = userId ? await User.findById(userId).select('-password') : null;
    console.log('User lookup result:', user);
    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Add user to request
    req.user = user;
    next();
  } catch (error) {
    console.error('Protect middleware error:', error);
    next(new AppError('Not authorized to access this route', 401));
  }
};

export const restrictTo = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return next(new AppError('Not authorized to access this route', 401));
    }
    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key') as { role: string };
      if (!roles.includes(decoded.role)) {
      return next(new AppError('Not authorized to access this route', 403));
    }
    next();
    } catch (error) {
      return next(new AppError('Not authorized to access this route', 401));
    }
  };
}; 