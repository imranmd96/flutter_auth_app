import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { AppError } from '../middleware/error.middleware';
import { logger } from '../utils/logger';

declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string;
        email: string;
        role: string;
      };
    }
  }
}

export class AuthMiddleware {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  authenticate = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader?.startsWith('Bearer ')) {
        throw new AppError('No token provided', 401);
      }

      const token = authHeader.split(' ')[1];
      const decoded = await this.authService.verifyToken(token);

      req.user = decoded;
      next();
    } catch (error) {
      next(error);
    }
  };

  authorize = (roles: string[]) => {
    return (req: Request, res: Response, next: NextFunction) => {
      try {
        if (!req.user) {
          throw new AppError('User not authenticated', 401);
        }

        if (!roles.includes(req.user.role)) {
          throw new AppError('Not authorized', 403);
        }

        next();
      } catch (error) {
        next(error);
      }
    };
  };

  validateOAuth = (provider: 'google' | 'apple') => {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        const { token } = req.body;
        if (!token) {
          throw new AppError('No OAuth token provided', 401);
        }

        const userPayload = await this.authService.validateOAuthToken(provider, token);
        const jwtToken = await this.authService.generateToken(userPayload);

        res.json({
          status: 'success',
          data: {
            token: jwtToken,
            user: userPayload
          }
        });
      } catch (error) {
        next(error);
      }
    };
  };
} 