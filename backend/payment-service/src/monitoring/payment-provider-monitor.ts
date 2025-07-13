import { PaymentProvider } from '../providers/payment-provider.interface';
import { logger } from '../utils/logger';
import { metrics } from '../utils/metrics';

export class PaymentProviderMonitor {
  private providers: Map<string, PaymentProvider>;
  private checkInterval: number;

  constructor(providers: Map<string, PaymentProvider>, checkInterval = 60000) {
    this.providers = providers;
    this.checkInterval = checkInterval;
  }

  startMonitoring(): void {
    setInterval(() => this.checkProviders(), this.checkInterval);
  }

  private async checkProviders(): Promise<void> {
    for (const [name, provider] of this.providers.entries()) {
      try {
        // Check provider health
        await this.checkProviderHealth(name, provider);

        // Record metrics
        this.recordMetrics(name);

        logger.info(`Provider ${name} health check passed`);
      } catch (error) {
        logger.error(`Provider ${name} health check failed`, { error });
        metrics.increment('payment_provider_health_check_failed', { provider: name });
      }
    }
  }

  private async checkProviderHealth(name: string, provider: PaymentProvider): Promise<void> {
    const startTime = Date.now();

    try {
      // Test payment creation
      const testPayment = await provider.createPayment({
        amount: 0.01,
        currency: 'USD',
        orderId: `health-check-${Date.now()}`,
        userId: 'health-check',
        restaurantId: 'health-check',
        paymentMethod: name === 'apple_pay' ? 'apple_pay' : 'google_pay',
        paymentToken: 'health-check-token'
      });

      // Record success metrics
      metrics.timing('payment_provider_health_check_duration', Date.now() - startTime, { provider: name });
      metrics.increment('payment_provider_health_check_success', { provider: name });

      // Clean up test payment
      await provider.refundPayment(testPayment.paymentId, 0.01);
    } catch (error) {
      metrics.increment('payment_provider_health_check_error', { provider: name, error: error.message });
      throw error;
    }
  }

  private recordMetrics(providerName: string): void {
    // Record provider-specific metrics
    metrics.gauge('payment_provider_active_subscriptions', this.getActiveSubscriptions(providerName), { provider: providerName });
    metrics.gauge('payment_provider_success_rate', this.getSuccessRate(providerName), { provider: providerName });
    metrics.gauge('payment_provider_error_rate', this.getErrorRate(providerName), { provider: providerName });
  }

  private getActiveSubscriptions(providerName: string): number {
    // Implement subscription counting logic
    return 0;
  }

  private getSuccessRate(providerName: string): number {
    // Implement success rate calculation
    return 0;
  }

  private getErrorRate(providerName: string): number {
    // Implement error rate calculation
    return 0;
  }
} 