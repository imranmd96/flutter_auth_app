import Stripe from 'stripe';
import { Payment, PaymentMethod } from '../models/payment.model';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error.middleware';

export class StripeProvider {
  private stripe: Stripe;

  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
      apiVersion: '2022-11-15', // Use compatible API version
      typescript: true
    });
  }

  async createPaymentIntent(payment: Payment): Promise<Stripe.PaymentIntent> {
    try {
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: Math.round(payment.amount * 100), // Convert to cents
        currency: payment.currency.toLowerCase(),
        payment_method_types: [this.mapPaymentMethod(payment.paymentMethod)],
        metadata: {
          orderId: payment.orderId,
          userId: payment.userId,
          restaurantId: payment.restaurantId
        }
      });

      logger.info('Created Stripe payment intent', {
        paymentId: payment.id,
        intentId: paymentIntent.id
      });

      return paymentIntent;
    } catch (error) {
      logger.error('Failed to create payment intent', {
        error,
        paymentId: payment.id
      });
      throw new AppError('Payment processing failed', 500);
    }
  }

  async confirmPayment(payment: Payment, paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    try {
      const paymentIntent = await this.stripe.paymentIntents.confirm(paymentIntentId);
      
      logger.info('Confirmed Stripe payment', {
        paymentId: payment.id,
        intentId: paymentIntentId
      });

      return paymentIntent;
    } catch (error) {
      logger.error('Failed to confirm payment', {
        error,
        paymentId: payment.id,
        intentId: paymentIntentId
      });
      throw new AppError('Payment confirmation failed', 500);
    }
  }

  async processRefund(payment: Payment, amount?: number): Promise<Stripe.Refund> {
    try {
      const refundParams: Stripe.RefundCreateParams = {
        payment_intent: payment.metadata?.stripePaymentIntentId as string,
        amount: amount ? Math.round(amount * 100) : undefined, // Convert to cents
        metadata: {
          orderId: payment.orderId,
          userId: payment.userId,
          restaurantId: payment.restaurantId
        }
      };

      const refund = await this.stripe.refunds.create(refundParams);

      logger.info('Processed Stripe refund', {
        paymentId: payment.id,
        refundId: refund.id
      });

      return refund;
    } catch (error) {
      logger.error('Failed to process refund', {
        error,
        paymentId: payment.id
      });
      throw new AppError('Refund processing failed', 500);
    }
  }

  async handleWebhook(event: Stripe.Event): Promise<void> {
    try {
      switch (event.type) {
        case 'payment_intent.succeeded':
          await this.handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
          break;
        case 'payment_intent.payment_failed':
          await this.handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
          break;
        case 'charge.refunded':
          await this.handleRefundSuccess(event.data.object as Stripe.Charge);
          break;
        default:
          logger.info('Unhandled Stripe webhook event', { type: event.type });
      }
    } catch (error) {
      logger.error('Failed to handle webhook event', {
        error,
        eventType: event.type
      });
      throw new AppError('Webhook processing failed', 500);
    }
  }

  private async handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent): Promise<void> {
    const { orderId } = paymentIntent.metadata;
    // Update payment status in your database
    // Notify relevant services
  }

  private async handlePaymentFailure(paymentIntent: Stripe.PaymentIntent): Promise<void> {
    const { orderId } = paymentIntent.metadata;
    // Update payment status in your database
    // Notify relevant services
  }

  private async handleRefundSuccess(charge: Stripe.Charge): Promise<void> {
    const { orderId } = charge.metadata;
    // Update refund status in your database
    // Notify relevant services
  }

  private mapPaymentMethod(method: PaymentMethod): string {
    const methodMap: Record<PaymentMethod, string> = {
      'credit_card': 'card',
      'debit_card': 'card',
      'paypal': 'paypal',
      'bank_transfer': 'bank_transfer'
    };
    return methodMap[method];
  }
} 