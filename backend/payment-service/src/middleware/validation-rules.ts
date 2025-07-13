import { body, param, query } from 'express-validator';
import { ValidationError } from '../utils/errors';

export const validationRules = {
  // Payment validation rules
  payment: {
    create: [
      body('amount')
        .isFloat({ min: 0.01, max: 1000000 })
        .withMessage('Amount must be between 0.01 and 1,000,000'),
      body('currency')
        .isIn(['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD'])
        .withMessage('Invalid currency'),
      body('paymentMethod')
        .isIn(['apple_pay', 'google_pay', 'credit_card'])
        .withMessage('Invalid payment method'),
      body('paymentToken')
        .isString()
        .isLength({ min: 10, max: 1000 })
        .withMessage('Invalid payment token'),
      body('orderId')
        .isString()
        .matches(/^[A-Za-z0-9-_]+$/)
        .withMessage('Invalid order ID format'),
      body('userId')
        .isString()
        .matches(/^[A-Za-z0-9-_]+$/)
        .withMessage('Invalid user ID format')
    ]
  }
}; 