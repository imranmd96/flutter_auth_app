import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { AppError } from '../middleware/error.middleware';
import { logger } from '../utils/logger';

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      // TODO: Get user from database
      const user = {
        userId: 'user123',
        email,
        password: 'hashed_password',
        role: 'user'
      };

      const isValidPassword = await this.authService.comparePasswords(
        password,
        user.password
      );

      if (!isValidPassword) {
        throw new AppError('Invalid credentials', 401);
      }

      const token = await this.authService.generateToken({
        userId: user.userId,
        email: user.email,
        role: user.role
      });

      res.json({
        status: 'success',
        data: {
          token,
          user: {
            userId: user.userId,
            email: user.email,
            role: user.role
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError('User not authenticated', 401);
      }

      await this.authService.revokeToken(req.user.userId);

      res.json({
        status: 'success',
        message: 'Logged out successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError('User not authenticated', 401);
      }

      const token = await this.authService.generateToken(req.user);

      res.json({
        status: 'success',
        data: {
          token
        }
      });
    } catch (error) {
      next(error);
    }
  }
} 