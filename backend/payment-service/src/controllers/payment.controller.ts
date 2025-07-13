import { Request, Response, NextFunction } from 'express';
import { PaymentModel, CreatePaymentDTO, UpdatePaymentDTO } from '../models/payment.model';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error.middleware';
import { StripeProvider } from '../providers/stripe.provider';

export class PaymentController {
  private stripeProvider: StripeProvider;

  constructor() {
    this.stripeProvider = new StripeProvider();
  }

  async createPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const paymentData: CreatePaymentDTO = {
        ...req.body,
        userId: req.user!.userId
      };

      // Create payment record
      const payment = await PaymentModel.create(paymentData);

      // Create Stripe payment intent
      const paymentIntent = await this.stripeProvider.createPaymentIntent(payment);

      // Update payment with Stripe data
      payment.metadata = {
        ...payment.metadata,
        stripePaymentIntentId: paymentIntent.id,
        stripeClientSecret: paymentIntent.client_secret
      };
      await payment.save();

      res.status(201).json({
        status: 'success',
        data: {
          payment,
          clientSecret: paymentIntent.client_secret
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async getPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const payment = await PaymentModel.findById(id);

      if (!payment) {
        throw new AppError('Payment not found', 404);
      }

      res.status(200).json({
        status: 'success',
        data: payment
      });
    } catch (error) {
      next(error);
    }
  }

  async refundPayment(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { amount, reason } = req.body;

      const payment = await PaymentModel.findById(id);
      if (!payment) {
        throw new AppError('Payment not found', 404);
      }

      if (payment.status !== 'completed') {
        throw new AppError('Only completed payments can be refunded', 400);
      }

      if (amount && amount > payment.amount) {
        throw new AppError('Refund amount exceeds payment amount', 400);
      }

      // Process refund through provider
      const result = await this.stripeProvider.processRefund(payment, amount);
      
      payment.status = 'refunded';
      payment.metadata = {
        ...payment.metadata,
        refund: { amount, reason, date: new Date() },
        providerResponse: result
      };
      await payment.save();

      res.status(200).json({
        status: 'success',
        data: payment
      });
    } catch (error) {
      next(error);
    }
  }

  async getUserPayments(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      
      // Check if user is requesting their own payments
      if (req.user!.userId !== userId && req.user!.role !== 'admin') {
        throw new AppError('Not authorized to view these payments', 403);
      }

      const payments = await PaymentModel.find({ userId })
        .sort({ createdAt: -1 });

      res.status(200).json({
        status: 'success',
        data: payments
      });
    } catch (error) {
      next(error);
    }
  }

  async getRestaurantPayments(req: Request, res: Response, next: NextFunction) {
    try {
      const { restaurantId } = req.params;
      
      // Check if user is authorized to view restaurant payments
      if (req.user!.role !== 'admin' && req.user!.role !== 'restaurant_owner') {
        throw new AppError('Not authorized to view restaurant payments', 403);
      }

      const payments = await PaymentModel.find({ restaurantId })
        .sort({ createdAt: -1 });

      res.status(200).json({
        status: 'success',
        data: payments
      });
    } catch (error) {
      next(error);
    }
  }
} 