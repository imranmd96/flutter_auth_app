import { Request, Response, NextFunction } from 'express';
import { ApiKeyMiddleware } from '../middleware/api-key.middleware';
import { logger } from '../utils/logger';

export class ApiKeyController {
  async createApiKey(req: Request, res: Response, next: NextFunction) {
    try {
      const { clientId, permissions } = req.body;
      const apiKey = await ApiKeyMiddleware.createApiKey(clientId, permissions);

      res.status(201).json({
        status: 'success',
        data: {
          apiKey,
          clientId,
          permissions
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async revokeApiKey(req: Request, res: Response, next: NextFunction) {
    try {
      const { apiKey } = req.params;
      await ApiKeyMiddleware.revokeApiKey(apiKey);

      res.json({
        status: 'success',
        message: 'API key revoked successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async updatePermissions(req: Request, res: Response, next: NextFunction) {
    try {
      const { apiKey } = req.params;
      const { permissions } = req.body;
      await ApiKeyMiddleware.updateApiKeyPermissions(apiKey, permissions);

      res.json({
        status: 'success',
        message: 'API key permissions updated successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async updateRateLimit(req: Request, res: Response, next: NextFunction) {
    try {
      const { apiKey } = req.params;
      const { limit, window } = req.body;
      await ApiKeyMiddleware.updateApiKeyRateLimit(apiKey, limit, window);

      res.json({
        status: 'success',
        message: 'API key rate limit updated successfully'
      });
    } catch (error) {
      next(error);
    }
  }
} 