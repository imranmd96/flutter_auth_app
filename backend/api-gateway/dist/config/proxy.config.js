"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.logProxyConfigurationTable = exports.proxyConfig = void 0;
const http_proxy_middleware_1 = require("http-proxy-middleware");
const chalk_1 = __importDefault(require("chalk"));
const logger_utils_1 = require("../utils/logger.utils");
const createServiceProxy = (config) => {
    return (0, http_proxy_middleware_1.createProxyMiddleware)({
        target: config.target,
        pathRewrite: config.pathRewrite,
        logLevel: config.logLevel,
        secure: config.secure,
        timeout: 300000,
        proxyTimeout: 300000,
        ws: true,
        changeOrigin: true,
        followRedirects: true,
        onProxyReq: (proxyReq, req, _res) => {
            var _a, _b;
            console.log(chalk_1.default.cyan(`[PROXY] ${req.method} ${chalk_1.default.yellow(req.originalUrl)} -> ${chalk_1.default.green(config.target)}${chalk_1.default.yellow(proxyReq.path)}`));
            console.log(chalk_1.default.dim('[PROXY REQ HEADERS]'), chalk_1.default.dim(JSON.stringify(req.headers)));
            if ((req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH') &&
                req.body && Object.keys(req.body).length > 0) {
                if ((_a = req.headers['content-type']) === null || _a === void 0 ? void 0 : _a.includes('application/json')) {
                    console.log(chalk_1.default.bgGreenBright("imran++++ahmed"));
                    const bodyData = JSON.stringify(req.body);
                    proxyReq.setHeader('Content-Type', 'application/json');
                    proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
                    console.log(chalk_1.default.cyan('[PROXY]') + chalk_1.default.dim(' Setting body: '), chalk_1.default.yellow(bodyData));
                    proxyReq.write(bodyData);
                    proxyReq.end();
                }
                else if ((_b = req.headers['content-type']) === null || _b === void 0 ? void 0 : _b.includes('application/x-www-form-urlencoded')) {
                    const bodyData = new URLSearchParams(req.body).toString();
                    proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
                    console.log(chalk_1.default.cyan('[PROXY]') + chalk_1.default.dim(' Setting form body: '), chalk_1.default.yellow(bodyData));
                    proxyReq.write(bodyData);
                    proxyReq.end();
                }
            }
        },
        onError: (err, req, res) => {
            console.error(chalk_1.default.red.bold(`[PROXY ERROR] ${req.method} ${req.originalUrl}:`), chalk_1.default.red(err.message));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR DETAILS] ${err.stack}`));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR CODE] ${err.code}`));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR TARGET] ${config.target}`));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR PATH] ${req.path}`));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR HEADERS] ${JSON.stringify(req.headers)}`));
            console.error(chalk_1.default.red.dim(`[PROXY ERROR BODY] ${JSON.stringify(req.body || {})}`));
            if (err.code === 'ECONNREFUSED') {
                res.status(503).json({
                    status: 'error',
                    message: 'Service is currently unavailable, please try again later',
                    code: 'SERVICE_UNAVAILABLE'
                });
            }
            else if (err.code === 'ECONNRESET') {
                res.status(504).json({
                    status: 'error',
                    message: 'Connection was reset, please try again',
                    code: 'CONNECTION_RESET'
                });
            }
            else if (err.code === 'ETIMEDOUT') {
                res.status(504).json({
                    status: 'error',
                    message: 'Request timed out, please try again',
                    code: 'REQUEST_TIMEOUT'
                });
            }
            else {
                res.status(500).json({
                    status: 'error',
                    message: 'Service temporarily unavailable',
                    code: err.code || 'UNKNOWN_ERROR'
                });
            }
        },
        onProxyRes: (proxyRes, req, _res) => {
            const statusCode = proxyRes.statusCode || 0;
            const statusColor = statusCode < 400 ? chalk_1.default.green : chalk_1.default.red;
            console.log(chalk_1.default.cyan(`[PROXY RESPONSE] ${req.method} ${chalk_1.default.yellow(req.originalUrl)} - `) + statusColor(`${statusCode}`));
            console.log(chalk_1.default.dim('[PROXY RES HEADERS]'), chalk_1.default.dim(JSON.stringify(proxyRes.headers)));
        }
    });
};
const getBaseUrl = (serviceName, port) => {
    const isDevelopment = process.env.NODE_ENV === 'development';
    const isDocker = process.env.DOCKER_ENV === 'true';
    if (isDocker) {
        return `http://${serviceName}:${port}`;
    }
    if (isDevelopment) {
        return `http://localhost:${port}`;
    }
    return `http://${serviceName}:${port}`;
};
exports.proxyConfig = {
    auth: createServiceProxy({
        target: process.env.AUTH_SERVICE_URL || getBaseUrl('auth-service', 3001),
        pathRewrite: { '^/api/auth': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug',
        agent: false
    }),
    user: createServiceProxy({
        target: process.env.USER_SERVICE_URL || getBaseUrl('user-service', 3015),
        pathRewrite: { '^/api/users': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    restaurant: createServiceProxy({
        target: process.env.RESTAURANT_SERVICE_URL || getBaseUrl('restaurant-service', 3012),
        pathRewrite: { '^/api/restaurants': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    order: createServiceProxy({
        target: process.env.ORDER_SERVICE_URL || getBaseUrl('order-service', 3010),
        pathRewrite: { '^/api/orders': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    booking: createServiceProxy({
        target: process.env.BOOKING_SERVICE_URL || getBaseUrl('booking-service', 3002),
        pathRewrite: { '^/api/bookings': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    inventory: createServiceProxy({
        target: process.env.INVENTORY_SERVICE_URL || getBaseUrl('inventory-service', 3005),
        pathRewrite: { '^/api/inventory': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    notification: createServiceProxy({
        target: process.env.NOTIFICATION_SERVICE_URL || getBaseUrl('notification-service', 3009),
        pathRewrite: { '^/api/notification': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    review: createServiceProxy({
        target: process.env.REVIEW_SERVICE_URL || getBaseUrl('review-service', 3013),
        pathRewrite: { '^/api/review': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    menu: createServiceProxy({
        target: process.env.MENU_SERVICE_URL || getBaseUrl('menu-service', 3008),
        pathRewrite: { '^/api/menu': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    payment: createServiceProxy({
        target: process.env.PAYMENT_SERVICE_URL || getBaseUrl('payment-service', 3011),
        pathRewrite: { '^/api/payment': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    analytics: createServiceProxy({
        target: process.env.ANALYTICS_SERVICE_URL || getBaseUrl('analytics-service', 3016),
        pathRewrite: { '^/api/analytics': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    chat: createServiceProxy({
        target: process.env.CHAT_SERVICE_URL || getBaseUrl('chat-service', 3003),
        pathRewrite: { '^/api/chat': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    }),
    media: createServiceProxy({
        target: process.env.MEDIA_SERVICE_URL || getBaseUrl('media-service', 3007),
        pathRewrite: { '^/api/media': '' },
        changeOrigin: true,
        secure: false,
        logLevel: 'debug'
    })
};
const logProxyConfigurationTable = () => {
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
    const tableRows = serviceConfigs.map(config => {
        const targetUrl = config.envVar || `http://localhost:${config.port}`;
        return [
            config.name,
            targetUrl,
            config.path,
            `^${config.path} → ""`,
        ];
    });
    (0, logger_utils_1.logDataTable)('PROXY CONFIGURATION', ['Service', 'Target URL', 'Path', 'Rewrite Rule'], tableRows);
};
exports.logProxyConfigurationTable = logProxyConfigurationTable;
//# sourceMappingURL=proxy.config.js.map