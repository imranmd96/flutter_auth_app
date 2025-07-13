import { metrics } from '../utils/metrics';
import { logger } from '../utils/logger';

export class SubscriptionMetrics {
  // Revenue metrics
  static trackRevenue(amount: number, currency: string, planId: string): void {
    metrics.increment('subscription_revenue_total', { currency, planId }, amount);
    metrics.gauge('subscription_revenue_current', amount, { currency, planId });
  }

  static trackMRR(amount: number, currency: string): void {
    metrics.gauge('subscription_mrr', amount, { currency });
  }

  static trackARR(amount: number, currency: string): void {
    metrics.gauge('subscription_arr', amount, { currency });
  }

  // User metrics
  static trackUserEngagement(userId: string, action: string): void {
    metrics.increment('subscription_user_engagement', { userId, action });
  }

  static trackUserRetention(userId: string, days: number): void {
    metrics.gauge('subscription_user_retention', days, { userId });
  }

  // Trial metrics
  static trackTrialStart(userId: string, planId: string): void {
    metrics.increment('subscription_trial_started', { userId, planId });
  }

  static trackTrialConversion(userId: string, planId: string): void {
    metrics.increment('subscription_trial_converted', { userId, planId });
  }

  // Churn metrics
  static trackChurn(userId: string, planId: string, reason: string): void {
    metrics.increment('subscription_churn', { userId, planId, reason });
  }

  // Feature usage metrics
  static trackFeatureUsage(userId: string, feature: string, quantity: number): void {
    metrics.increment('subscription_feature_usage', { userId, feature }, quantity);
  }

  // Error metrics
  static trackError(error: Error, context: string): void {
    metrics.increment('subscription_error', { 
      error: error.name,
      context,
      message: error.message
    });
    logger.error('Subscription error', { error, context });
  }

  // Performance metrics
  static trackOperationDuratio
} 