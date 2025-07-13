import { body, param, query } from 'express-validator';
import { ValidationError } from '../utils/errors';

export const validationScenarios = {
  // Restaurant validation
  restaurant: {
    create: [
      body('name')
        .isString()
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Restaurant name must be between 2 and 100 characters'),
      body('address')
        .isObject()
        .withMessage('Address must be an object'),
      body('address.street')
        .isString()
        .trim()
        .notEmpty()
        .withMessage('Street address is required'),
      body('address.city')
        .isString()
        .trim()
        .notEmpty()
        .withMessage('City is required'),
      body('address.country')
        .isString()
        .trim()
        .isLength({ min: 2, max: 2 })
        .withMessage('Country must be a 2-letter code'),
      body('cuisine')
        .isArray()
        .withMessage('Cuisine must be an array'),
    ],
  },
}; 