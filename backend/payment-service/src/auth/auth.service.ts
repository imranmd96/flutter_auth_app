import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { OAuth2Provider } from './oauth2.provider';
import { logger } from '../utils/logger';
import { AppError } from '../utils/errors';
import { redisClient } from '../config/redis';

export interface UserPayload {
  userId: string;
  email: string;
  role: string;
}

export class AuthService {
  private oauth2Provider: OAuth2Provider;

  constructor() {
    this.oauth2Provider = new OAuth2Provider();
  }

  async generateToken(payload: UserPayload): Promise<string> {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        throw new AppError('JWT_SECRET is not configured', 500);
      }
      
      const token = jwt.sign(
        payload,
        secret,
        { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
      );

      // Store token in Redis for blacklisting
      await redisClient.setEx(
        `token:${payload.userId}`,
        3600, // 1 hour
        token
      );

      return token;
    } catch (error) {
      logger.error('Token generation failed', { error });
      throw new AppError('Token generation failed', 500);
    }
  }

  async verifyToken(token: string): Promise<UserPayload> {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        throw new AppError('JWT_SECRET is not configured', 500);
      }
      
      const decoded = jwt.verify(token, secret) as UserPayload;
      
      // Check if token is blacklisted
      const storedToken = await redisClient.get(`token:${decoded.userId}`);
      if (!storedToken || storedToken !== token) {
        throw new AppError('Token is invalid or expired', 401);
      }

      return decoded;
    } catch (error) {
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AppError('Invalid token', 401);
      }
      throw error;
    }
  }

  async hashPassword(password: string): Promise<string> {
    try {
      const salt = await bcrypt.genSalt(10);
      return bcrypt.hash(password, salt);
    } catch (error) {
      logger.error('Password hashing failed', { error });
      throw new AppError('Password hashing failed', 500);
    }
  }

  async comparePasswords(password: string, hashedPassword: string): Promise<boolean> {
    try {
      return bcrypt.compare(password, hashedPassword);
    } catch (error) {
      logger.error('Password comparison failed', { error });
      throw new AppError('Password comparison failed', 500);
    }
  }

  async validateOAuthToken(provider: 'google' | 'apple', token: string): Promise<UserPayload> {
    try {
      let payload;
      if (provider === 'google') {
        payload = await this.oauth2Provider.validateGoogleToken(token);
      } else {
        payload = await this.oauth2Provider.validateAppleToken(token);
      }

      // Map OAuth payload to UserPayload
      return {
        userId: payload.sub,
        email: payload.email,
        role: 'user' // Default role for OAuth users
      };
    } catch (error) {
      logger.error('OAuth token validation failed', { error, provider });
      throw new AppError('OAuth token validation failed', 401);
    }
  }

  async revokeToken(userId: string): Promise<void> {
    try {
      await redisClient.del(`token:${userId}`);
    } catch (error) {
      logger.error('Token revocation failed', { error, userId });
      throw new AppError('Token revocation failed', 500);
    }
  }
} 