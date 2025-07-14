"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const proxy_config_1 = require("../config/proxy.config");
const auth_middleware_1 = require("../middleware/auth.middleware");
const rate_limit_middleware_1 = require("../middleware/rate-limit.middleware");
const router = (0, express_1.Router)();
router.get('/health', (_req, res) => {
    res.status(200).json({
        status: 'success',
        message: 'API Gateway is running'
    });
});
router.post('/test-health', (_req, res) => {
    console.log(_req.body);
    res.status(200).json({
        status: 'success',
        message: 'API Gateway is running'
    });
});
router.use('/api/auth', proxy_config_1.proxyConfig.auth);
router.use('/api/users', rate_limit_middleware_1.authLimiter, proxy_config_1.proxyConfig.user);
router.use('/api/restaurants', rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.restaurant);
router.use('/api/orders', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.order);
router.use('/api/bookings', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.booking);
router.use('/api/inventory', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.inventory);
router.use('/api/notification', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.notification);
router.use('/api/review', rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.review);
router.use('/api/menu', rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.menu);
router.use('/api/payment', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.payment);
router.use('/api/analytics', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.analytics);
router.use('/api/chat', auth_middleware_1.protect, rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.chat);
router.use('/api/media', rate_limit_middleware_1.apiLimiter, proxy_config_1.proxyConfig.media);
exports.default = router;
//# sourceMappingURL=index.js.map