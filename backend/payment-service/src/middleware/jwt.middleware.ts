import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthenticationError, AuthorizationError } from '../utils/errors';
import { logger } from '../utils/logger';
import { redisClient } from '../config/redis';

interface JwtPayload {
  userId: string;
  role: string;
  restaurantId?: string;
  permissions: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}

export const jwtAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      throw new AuthenticationError('JWT token is required');
    }

    // Check if token is blacklisted
    const isBlacklisted = await redisClient.get(`blacklist:${token}`);
    if (isBlacklisted) {
      throw new AuthenticationError('Token has been revoked');
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;
    
    // Check token expiration
    if (decoded.exp && Date.now() >= decoded.exp * 1000) {
      throw new AuthenticationError('Token has expired');
    }

    // Add user info to request
    req.user = decoded;

    next();
  } catch (error) {
    logger.error('JWT authentication failed', { error });
    next(error);
  }
};

export const requireRole = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AuthenticationError('User not authenticated');
    }

    if (!roles.includes(req.user.role)) {
      throw new AuthorizationError('Insufficient permissions');
    }

    next();
  };
};

export const requirePermission = (permissions: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AuthenticationError('User not authenticated');
    }

    const hasPermission = permissions.every(permission => 
      req.user!.permissions.includes(permission)
    );

    if (!hasPermission) {
      throw new AuthorizationError('Insufficient permissions');
    }

    next();
  };
};

export const requireRestaurantAccess = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    throw new AuthenticationError('User not authenticated');
  }

  const restaurantId = req.params.restaurantId || req.body.restaurantId;
  
  if (restaurantId && req.user.restaurantId !== restaurantId) {
    throw new AuthorizationError('Access to this restaurant is not allowed');
  }

  next();
}; 