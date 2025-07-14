"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.strictLimiter = exports.apiLimiter = exports.authLimiter = exports.createRateLimiter = void 0;
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const error_middleware_1 = require("./error.middleware");
const createRateLimiter = (windowMs, max) => {
    return (0, express_rate_limit_1.default)({
        windowMs,
        max,
        message: new error_middleware_1.AppError('Too many requests from this IP, please try again later', 429),
        standardHeaders: true,
        legacyHeaders: false
    });
};
exports.createRateLimiter = createRateLimiter;
exports.authLimiter = (0, exports.createRateLimiter)(15 * 60 * 1000, 100);
exports.apiLimiter = (0, exports.createRateLimiter)(60 * 60 * 1000, 1000);
exports.strictLimiter = (0, exports.createRateLimiter)(60 * 1000, 10);
//# sourceMappingURL=rate-limit.middleware.js.map