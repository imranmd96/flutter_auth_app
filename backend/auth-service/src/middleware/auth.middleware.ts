import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './error.middleware';
import { AuthUser } from '../models/authUser.model';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export interface AuthRequest extends Request {
  user?: any;
}

export const protect = async (req: AuthRequest, _res: Response, next: NextFunction) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return next(new AppError('Not authorized to access this route', 401));
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    const decoded = jwt.verify(token, JWT_SECRET) as { id: string, role: string };

    // Get user from token
    const user = await AuthUser.findById(decoded.id);
    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Add user and role to request
    req.user = user;
    req.user.role = decoded.role; // Attach role from JWT
    next();
  } catch (error) {
    next(new AppError('Not authorized to access this route', 401));
  }
}; 