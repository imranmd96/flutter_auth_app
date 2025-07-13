import { Request, Response, NextFunction } from 'express';
import { StripeProvider } from '../providers/stripe.provider';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error.middleware';
import Stripe from 'stripe';

export class WebhookController {
  private stripeProvider: StripeProvider;
  private stripe: Stripe;

  constructor() {
    this.stripeProvider = new StripeProvider();
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
      apiVersion: '2023-10-16'
    });
  }

  async handleStripeWebhook(req: Request, res: Response, next: NextFunction) {
    try {
      const sig = req.headers['stripe-signature'];
      if (!sig) {
        throw new AppError('No Stripe signature found', 400);
      }

      const event = this.stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET!
      );

      await this.stripeProvider.handleWebhook(event);

      res.json({ received: true });
    } catch (error) {
      if (error instanceof Stripe.errors.StripeError) {
        next(new AppError(error.message, 400));
      } else {
        next(error);
      }
    }
  }
} 