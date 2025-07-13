import { Router } from 'express';
import { body } from 'express-validator';
import { validateRequest } from '../middleware/validation.middleware';
import { AuthController } from './auth.controller';
import { AuthMiddleware } from './auth.middleware';

const router = Router();
const authController = new AuthController();
const authMiddleware = new AuthMiddleware();

// Login route
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').isString().withMessage('Password is required'),
    validateRequest
  ],
  authController.login.bind(authController)
);

// Logout route
router.post(
  '/logout',
  authMiddleware.authenticate,
  authController.logout.bind(authController)
);

// Refresh token route
router.post(
  '/refresh-token',
  authMiddleware.authenticate,
  authController.refreshToken.bind(authController)
);

// OAuth routes
router.post(
  '/google',
  authMiddleware.validateOAuth('google'),
  authController.validateOAuth.bind(authController)
);

router.post(
  '/apple',
  authMiddleware.validateOAuth('apple'),
  authController.validateOAuth.bind(authController)
);

export default router; 