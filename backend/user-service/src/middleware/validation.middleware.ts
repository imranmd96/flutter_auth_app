import { Request, Response, NextFunction } from 'express';
import { AppError } from './error.middleware.js';

export const validateUpdateProfile = (req: Request, res: Response, next: NextFunction) => {
  const { name, phone, address, preferences } = req.body;

  if (name && name.length < 2) {
    return next(new AppError('Name must be at least 2 characters long', 400));
  }

  if (phone && !phone.match(/^\+?[\d\s-]{10,}$/)) {
    return next(new AppError('Please provide a valid phone number', 400));
  }

  if (preferences) {
    if (preferences.language && !['en', 'es', 'fr'].includes(preferences.language)) {
      return next(new AppError('Invalid language preference', 400));
    }

    if (preferences.theme && !['light', 'dark'].includes(preferences.theme)) {
      return next(new AppError('Invalid theme preference', 400));
    }
  }

  next();
};

export const validateUpdatePassword = (req: Request, res: Response, next: NextFunction) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return next(new AppError('Please provide both current and new password', 400));
  }

  if (newPassword.length < 6) {
    return next(new AppError('New password must be at least 6 characters long', 400));
  }

  if (currentPassword === newPassword) {
    return next(new AppError('New password must be different from current password', 400));
  }

  next();
}; 