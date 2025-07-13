import { Router } from 'express';
import { body } from 'express-validator';
import { validateRequest } from '../middleware/validation.middleware';
import { PaymentController } from '../controllers/payment.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validateApiKey, requirePermission } from '../middleware/api-key.middleware';

const router = Router();
const paymentController = new PaymentController();

// Apply API key validation to all routes
router.use(validateApiKey);

router.post(
  '/',
  requirePermission('payment:create'),
  [
    body('amount').isNumeric().withMessage('Amount must be a number'),
    body('currency').isString().withMessage('Currency is required'),
    body('paymentMethod').isString().withMessage('Payment method is required'),
    validateRequest
  ],
  paymentController.createPayment
);

router.get(
  '/:id',
  requirePermission('payment:read'),
  paymentController.getPayment
);

router.post(
  '/:id/refund',
  requirePermission('payment:refund'),
  [
    body('amount').optional().isNumeric().withMessage('Amount must be a number'),
    validateRequest
  ],
  paymentController.refundPayment
);

router.get(
  '/user/:userId',
  authMiddleware,
  paymentController.getUserPayments.bind(paymentController)
);

router.get(
  '/restaurant/:restaurantId',
  authMiddleware,
  paymentController.getRestaurantPayments.bind(paymentController)
);

export default router; 