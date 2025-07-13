import { Request, Response, NextFunction } from 'express';
import { AppError } from './error.middleware';
import { logger } from '../utils/logger';
import { redisClient } from '../config/redis';
import crypto from 'crypto';

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      apiKey?: {
        key: string;
        clientId: string;
        permissions: string[];
        requestsRemaining: number;
        rateLimit: {
          limit: number;
          window: number;
        };
      };
    }
  }
}

interface ApiKeyConfig {
  key: string;
  clientId: string;
  permissions: string[];
  rateLimit: {
    limit: number;
    window: number;
  };
  isActive: boolean;
  createdAt: Date;
  lastUsed?: Date;
}

export class ApiKeyMiddleware {
  private static readonly API_KEY_PREFIX = 'api_key:';
  private static readonly RATE_LIMIT_PREFIX = 'rate_limit:';
  private static readonly DEFAULT_RATE_LIMIT = {
    limit: 1000,
    window: 3600 // 1 hour in seconds
  };

  static async validate(req: Request, res: Response, next: NextFunction) {
    try {
      if (!redisClient.isOpen) {
        throw new AppError('Service temporarily unavailable', 503);
      }

      const apiKey = this.extractApiKey(req);
      if (!apiKey) {
        throw new AppError('API key is required', 401);
      }

      const apiKeyConfig = await this.getApiKeyConfig(apiKey);
      if (!apiKeyConfig) {
        throw new AppError('Invalid API key', 401);
      }

      if (!apiKeyConfig.isActive) {
        throw new AppError('API key is inactive', 401);
      }

      await this.checkRateLimit(apiKey, apiKeyConfig.rateLimit);

      // Add API key info to request
      req.apiKey = {
        key: apiKey,
        clientId: apiKeyConfig.clientId,
        permissions: apiKeyConfig.permissions,
        requestsRemaining: await this.getRemainingRequests(apiKey, apiKeyConfig.rateLimit),
        rateLimit: apiKeyConfig.rateLimit
      };

      // Update last used timestamp
      await this.updateLastUsed(apiKey);

      next();
    } catch (error) {
      logger.error('API key validation failed', {
        error,
        path: req.path,
        method: req.method,
        ip: req.ip
      });
      next(error);
    }
  }

  static async requirePermission(permission: string) {
    return (req: Request, res: Response, next: NextFunction) => {
      if (!req.apiKey) {
        return next(new AppError('API key is required', 401));
      }

      if (!req.apiKey.permissions.includes(permission)) {
        return next(new AppError('Insufficient permissions', 403));
      }

      next();
    };
  }

  private static extractApiKey(req: Request): string | null {
    const apiKey = req.headers['x-api-key'] || req.query.apiKey;
    return apiKey ? String(apiKey) : null;
  }

  private static async getApiKeyConfig(apiKey: string): Promise<ApiKeyConfig | null> {
    try {
      const key = `${this.API_KEY_PREFIX}${apiKey}`;
      const config = await redisClient.get(key);

      if (!config) {
        return null;
      }

      return JSON.parse(config) as ApiKeyConfig;
    } catch (error) {
      logger.error('Failed to get API key config', { error, apiKey });
      return null;
    }
  }

  private static async checkRateLimit(apiKey: string, rateLimit: { limit: number; window: number }) {
    const key = `${this.RATE_LIMIT_PREFIX}${apiKey}`;
    const requests = await redisClient.incr(key);

    if (requests === 1) {
      await redisClient.expire(key, rateLimit.window);
    }

    if (requests > rateLimit.limit) {
      throw new AppError('Rate limit exceeded', 429);
    }
  }

  private static async getRemainingRequests(apiKey: string, rateLimit: { limit: number; window: number }): Promise<number> {
    const key = `${this.RATE_LIMIT_PREFIX}${apiKey}`;
    const requests = await redisClient.get(key);
    return rateLimit.limit - (parseInt(requests || '0', 10));
  }

  private static async updateLastUsed(apiKey: string): Promise<void> {
    try {
      const key = `${this.API_KEY_PREFIX}${apiKey}`;
      const config = await this.getApiKeyConfig(apiKey);

      if (config) {
        config.lastUsed = new Date();
        await redisClient.set(key, JSON.stringify(config));
      }
    } catch (error) {
      logger.error('Failed to update API key last used timestamp', { error, apiKey });
    }
  }

  static async createApiKey(clientId: string, permissions: string[]): Promise<string> {
    try {
      const apiKey = crypto.randomBytes(32).toString('hex');
      const config: ApiKeyConfig = {
        key: apiKey,
        clientId,
        permissions,
        rateLimit: this.DEFAULT_RATE_LIMIT,
        isActive: true,
        createdAt: new Date()
      };

      await redisClient.set(
        `${this.API_KEY_PREFIX}${apiKey}`,
        JSON.stringify(config)
      );

      return apiKey;
    } catch (error) {
      logger.error('Failed to create API key', { error, clientId });
      throw new AppError('Failed to create API key', 500);
    }
  }

  static async revokeApiKey(apiKey: string): Promise<void> {
    try {
      const key = `${this.API_KEY_PREFIX}${apiKey}`;
      const config = await this.getApiKeyConfig(apiKey);

      if (config) {
        config.isActive = false;
        await redisClient.set(key, JSON.stringify(config));
      }
    } catch (error) {
      logger.error('Failed to revoke API key', { error, apiKey });
      throw new AppError('Failed to revoke API key', 500);
    }
  }

  static async updateApiKeyPermissions(apiKey: string, permissions: string[]): Promise<void> {
    try {
      const key = `${this.API_KEY_PREFIX}${apiKey}`;
      const config = await this.getApiKeyConfig(apiKey);

      if (config) {
        config.permissions = permissions;
        await redisClient.set(key, JSON.stringify(config));
      }
    } catch (error) {
      logger.error('Failed to update API key permissions', { error, apiKey });
      throw new AppError('Failed to update API key permissions', 500);
    }
  }

  static async updateApiKeyRateLimit(apiKey: string, limit: number, window: number): Promise<void> {
    try {
      const key = `${this.API_KEY_PREFIX}${apiKey}`;
      const config = await this.getApiKeyConfig(apiKey);

      if (config) {
        config.rateLimit = { limit, window };
        await redisClient.set(key, JSON.stringify(config));
      }
    } catch (error) {
      logger.error('Failed to update API key rate limit', { error, apiKey });
      throw new AppError('Failed to update API key rate limit', 500);
    }
  }
}

// Export middleware functions
export const validateApiKey = ApiKeyMiddleware.validate;
export const requirePermission = ApiKeyMiddleware.requirePermission; 