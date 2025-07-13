import { Router } from 'express';
import { WebhookController } from '../controllers/webhook.controller';

const router = Router();
const webhookController = new WebhookController();

router.post(
  '/stripe',
  express.raw({ type: 'application/json' }), // Required for Stripe webhooks
  webhookController.handleStripeWebhook.bind(webhookController)
);

export default router; 