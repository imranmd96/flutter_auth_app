import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { promClient } from '../config/prometheus';

// Create metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new promClient.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

export const metricsMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = Date.now();
  activeConnections.inc();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const route = req.route?.path || req.path;
    const statusCode = res.statusCode;

    // Record metrics
    httpRequestDuration
      .labels(req.method, route, statusCode.toString())
      .observe(duration / 1000);

    httpRequestsTotal
      .labels(req.method, route, statusCode.toString())
      .inc();

    activeConnections.dec();

    // Log metrics
    logger.info('Request metrics', {
      method: req.method,
      route,
      statusCode,
      duration,
      activeConnections: activeConnections.get()
    });
  });

  next();
}; 