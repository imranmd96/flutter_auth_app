import { Counter, Histogram, Gauge } from 'prom-client';
import { logger } from './monitoring';

// Payment metrics
export const paymentCounter = new Counter({
  name: 'payment_total',
  help: 'Total number of payments processed',
  labelNames: ['status', 'payment_method']
});

export const paymentAmountGauge = new Gauge({
  name: 'payment_amount_total',
  help: 'Total amount of payments processed',
  labelNames: ['currency']
});

export const paymentProcessingTime = new Histogram({
  name: 'payment_processing_seconds',
  help: 'Time taken to process payments',
  labelNames: ['operation'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

// Error metrics
export const errorCounter = new Counter({
  name: 'payment_errors_total',
  help: 'Total number of errors',
  labelNames: ['type', 'endpoint']
});

// System metrics
export const activeConnectionsGauge = new Gauge({
  name: 'active_connections',
  help: 'Number of active database connections'
});

export const memoryUsageGauge = new Gauge({
  name: 'memory_usage_bytes',
  help: 'Memory usage in bytes'
});

// Update system metrics periodically
setInterval(() => {
  const memoryUsage = process.memoryUsage();
  memoryUsageGauge.set(memoryUsage.heapUsed);
}, 5000); 