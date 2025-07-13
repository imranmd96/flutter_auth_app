import { Request, Response, NextFunction } from 'express';
import { body, validationResult, ValidationChain } from 'express-validator';
import { ValidationError } from '../utils/errors';
import { AppError } from './error.middleware';
import { logger } from '../utils/logger';

export const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    await Promise.all(validations.map(validation => validation.run(req)));

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new ValidationError(errors.array().map(err => err.msg).join(', '));
    }
    next();
  };
};

export const paymentValidation = {
  create: [
    body('amount')
      .isFloat({ min: 0.01 })
      .withMessage('Amount must be greater than 0'),
    body('currency')
      .isIn(['USD', 'EUR', 'GBP'])
      .withMessage('Invalid currency'),
    body('paymentMethod')
      .isIn(['apple_pay', 'google_pay'])
      .withMessage('Invalid payment method'),
    body('paymentToken')
      .isString()
      .notEmpty()
      .withMessage('Payment token is required'),
    body('orderId')
      .isString()
      .notEmpty()
      .withMessage('Order ID is required'),
    body('userId')
      .isString()
      .notEmpty()
      .withMessage('User ID is required'),
    body('restaurantId')
      .isString()
      .notEmpty()
      .withMessage('Restaurant ID is required')
  ],
  
  subscription: [
    body('planId')
      .isString()
      .notEmpty()
      .withMessage('Plan ID is required'),
    body('interval')
      .isIn(['monthly', 'yearly'])
      .withMessage('Invalid subscription interval'),
    body('trialPeriod.duration')
      .optional()
  ]
};

export const validateRequest = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => err.msg);
    logger.warn('Validation failed', {
      path: req.path,
      errors: errorMessages
    });
    throw new AppError(
      `Validation failed: ${errorMessages.join(', ')}`,
      400
    );
  }
  next();
};

export const sanitizeRequest = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        // Remove any potential XSS or injection attempts
        req.body[key] = req.body[key]
          .replace(/<[^>]*>/g, '') // Remove HTML tags
          .replace(/javascript:/gi, '') // Remove javascript: protocol
          .replace(/on\w+=/gi, '') // Remove event handlers
          .trim();
      }
    });
  }
  next();
}; 