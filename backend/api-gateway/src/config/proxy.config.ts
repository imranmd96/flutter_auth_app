import { createProxyMiddleware, Options } from 'http-proxy-middleware';
import { RequestHandler } from 'express';
import chalk from 'chalk';
import { logDataTable } from '../utils/logger.utils';

// Define interface for errors with code property
interface ErrorWithCode extends Error {
  code?: string;
}

type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'silent';

interface ProxyConfig extends Omit<Options, 'logLevel'> {
  target: string;
  pathRewrite: { [key: string]: string };
  changeOrigin: boolean;
  secure: boolean;
  logLevel: LogLevel;
}

const createServiceProxy = (config: ProxyConfig): RequestHandler => {
  return createProxyMiddleware({
    target: config.target,
    pathRewrite: config.pathRewrite,
    logLevel: config.logLevel,
    secure: config.secure,
    timeout: 300000,        // 5 minutes
    proxyTimeout: 300000,   // 5 minutes
    ws: true,
    changeOrigin: true,
    followRedirects: true,
    onProxyReq: (proxyReq, req, _res) => {
     
      console.log(chalk.cyan(`[PROXY] ${req.method} ${chalk.yellow(req.originalUrl)} -> ${chalk.green(config.target)}${chalk.yellow(proxyReq.path)}`));
      console.log(chalk.dim('[PROXY REQ HEADERS]'), chalk.dim(JSON.stringify(req.headers)));
     
      // Handle JSON body for POST/PUT/PATCH requests
      if ((req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH') && 
          req.body && Object.keys(req.body).length > 0) {
            // req.body ) {
            
        // If we have a parsed body and content-type is JSON, stringify and write it
        if (req.headers['content-type']?.includes('application/json')) {
          console.log(chalk.bgGreenBright("imran++++ahmed"));
          const bodyData = JSON.stringify(req.body);
          proxyReq.setHeader('Content-Type', 'application/json');
          proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
          console.log(chalk.cyan('[PROXY]') + chalk.dim(' Setting body: '), chalk.yellow(bodyData));
          
          // Write body data to the proxied request
          proxyReq.write(bodyData);
          proxyReq.end();
        } 
        // For form data
        else if (req.headers['content-type']?.includes('application/x-www-form-urlencoded')) {
          const bodyData = new URLSearchParams(req.body).toString();
          proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
          console.log(chalk.cyan('[PROXY]') + chalk.dim(' Setting form body: '), chalk.yellow(bodyData));
          
          // Write form data to the proxied request
          proxyReq.write(bodyData);
          proxyReq.end();
        }
      }
    },
    onError: (err: ErrorWithCode, req, res) => {
      console.error(chalk.red.bold(`[PROXY ERROR] ${req.method} ${req.originalUrl}:`), chalk.red(err.message));
      console.error(chalk.red.dim(`[PROXY ERROR DETAILS] ${err.stack}`));
      console.error(chalk.red.dim(`[PROXY ERROR CODE] ${err.code}`));
      console.error(chalk.red.dim(`[PROXY ERROR TARGET] ${config.target}`));
      console.error(chalk.red.dim(`[PROXY ERROR PATH] ${req.path}`));
      console.error(chalk.red.dim(`[PROXY ERROR HEADERS] ${JSON.stringify(req.headers)}`));
      console.error(chalk.red.dim(`[PROXY ERROR BODY] ${JSON.stringify(req.body || {})}`));
      
      if (err.code === 'ECONNREFUSED') {
        res.status(503).json({
          status: 'error',
          message: 'Service is currently unavailable, please try again later',
          code: 'SERVICE_UNAVAILABLE'
        });
      } else if (err.code === 'ECONNRESET') {
        res.status(504).json({
          status: 'error',
          message: 'Connection was reset, please try again',
          code: 'CONNECTION_RESET'
        });
      } else if (err.code === 'ETIMEDOUT') {
        res.status(504).json({
          status: 'error',
          message: 'Request timed out, please try again',
          code: 'REQUEST_TIMEOUT'
        });
      } else {
        res.status(500).json({
          status: 'error',
          message: 'Service temporarily unavailable',
          code: err.code || 'UNKNOWN_ERROR'
        });
      }
    },
    onProxyRes: (proxyRes, req, _res) => {
      const statusCode = proxyRes.statusCode || 0;
      const statusColor = statusCode < 400 ? chalk.green : chalk.red;
      console.log(chalk.cyan(`[PROXY RESPONSE] ${req.method} ${chalk.yellow(req.originalUrl)} - `) + statusColor(`${statusCode}`));
      console.log(chalk.dim('[PROXY RES HEADERS]'), chalk.dim(JSON.stringify(proxyRes.headers)));
    }
  });
};

// Get the base URL based on environment
const getBaseUrl = (serviceName: string, port: number): string => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  const isDocker = process.env.DOCKER_ENV === 'true';
  
  // Use service name in Docker environment, even in development
  if (isDocker) {
    return `http://${serviceName}:${port}`;
  }
  
  // Use localhost for local development outside Docker
  if (isDevelopment) {
    return `http://localhost:${port}`;
  }
  
  return `http://${serviceName}:${port}`;
};

export const proxyConfig = {
  auth: createServiceProxy({
    target: process.env.AUTH_SERVICE_URL || getBaseUrl('auth-service', 3001),
    pathRewrite: { '^/api/auth': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel,
    agent: false
  }),

  user: createServiceProxy({
    target: process.env.USER_SERVICE_URL || getBaseUrl('user-service', 3015),
    pathRewrite: { '^/api/users': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  restaurant: createServiceProxy({
    target: process.env.RESTAURANT_SERVICE_URL || getBaseUrl('restaurant-service', 3012),
    pathRewrite: { '^/api/restaurants': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  order: createServiceProxy({
    target: process.env.ORDER_SERVICE_URL || getBaseUrl('order-service', 3010),
    pathRewrite: { '^/api/orders': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  booking: createServiceProxy({
    target: process.env.BOOKING_SERVICE_URL || getBaseUrl('booking-service', 3002),
    pathRewrite: { '^/api/bookings': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  inventory: createServiceProxy({
    target: process.env.INVENTORY_SERVICE_URL || getBaseUrl('inventory-service', 3005),
    pathRewrite: { '^/api/inventory': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  notification: createServiceProxy({
    target: process.env.NOTIFICATION_SERVICE_URL || getBaseUrl('notification-service', 3009),
    pathRewrite: { '^/api/notification': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  review: createServiceProxy({
    target: process.env.REVIEW_SERVICE_URL || getBaseUrl('review-service', 3013),
    pathRewrite: { '^/api/review': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  menu: createServiceProxy({
    target: process.env.MENU_SERVICE_URL || getBaseUrl('menu-service', 3008),
    pathRewrite: { '^/api/menu': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  payment: createServiceProxy({
    target: process.env.PAYMENT_SERVICE_URL || getBaseUrl('payment-service', 3011),
    pathRewrite: { '^/api/payment': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  analytics: createServiceProxy({
    target: process.env.ANALYTICS_SERVICE_URL || getBaseUrl('analytics-service', 3016),
    pathRewrite: { '^/api/analytics': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  chat: createServiceProxy({
    target: process.env.CHAT_SERVICE_URL || getBaseUrl('chat-service', 3003),
    pathRewrite: { '^/api/chat': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  }),

  media: createServiceProxy({
    target: process.env.MEDIA_SERVICE_URL || getBaseUrl('media-service', 3007),
    pathRewrite: { '^/api/media': '' },
    changeOrigin: true,
    secure: false,
    logLevel: 'debug' as LogLevel
  })
};

// Function to log the proxy configuration as a table
export const logProxyConfigurationTable = () => {
  // Define service names, ports, and paths based on environment variables
  const serviceConfigs = [
    { name: 'auth', port: 3001, path: '/api/auth', envVar: process.env.AUTH_SERVICE_URL },
    { name: 'user', port: 3015, path: '/api/users', envVar: process.env.USER_SERVICE_URL },
    { name: 'restaurant', port: 3012, path: '/api/restaurants', envVar: process.env.RESTAURANT_SERVICE_URL },
    { name: 'order', port: 3010, path: '/api/orders', envVar: process.env.ORDER_SERVICE_URL },
    { name: 'booking', port: 3002, path: '/api/bookings', envVar: process.env.BOOKING_SERVICE_URL },
    { name: 'inventory', port: 3005, path: '/api/inventory', envVar: process.env.INVENTORY_SERVICE_URL },
    { name: 'notification', port: 3009, path: '/api/notification', envVar: process.env.NOTIFICATION_SERVICE_URL },
    { name: 'review', port: 3013, path: '/api/review', envVar: process.env.REVIEW_SERVICE_URL },
    { name: 'menu', port: 3008, path: '/api/menu', envVar: process.env.MENU_SERVICE_URL },
    { name: 'payment', port: 3011, path: '/api/payment', envVar: process.env.PAYMENT_SERVICE_URL },
    { name: 'analytics', port: 3016, path: '/api/analytics', envVar: process.env.ANALYTICS_SERVICE_URL },
    { name: 'chat', port: 3003, path: '/api/chat', envVar: process.env.CHAT_SERVICE_URL },
    { name: 'media', port: 3007, path: '/api/media', envVar: process.env.MEDIA_SERVICE_URL },
  ];
  
  // Create table rows from configuration
  const tableRows = serviceConfigs.map(config => {
    const targetUrl = config.envVar || `http://localhost:${config.port}`;
    
    return [
      config.name,
      targetUrl,
      config.path,
      `^${config.path} → ""`,
    ];
  });
  
  // Log the table with colored status
  logDataTable(
    'PROXY CONFIGURATION',
    ['Service', 'Target URL', 'Path', 'Rewrite Rule'],
    tableRows
  );
}; 