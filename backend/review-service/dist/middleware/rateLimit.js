"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyticsLimiter = exports.reviewLimiter = void 0;
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const database_1 = require("../config/database");
// Redis store for rate limiting
const RedisStore = {
    incr: async (key) => {
        const count = await database_1.redis.incr(key);
        if (count === 1) {
            await database_1.redis.expire(key, 60); // 1 minute window
        }
        return count;
    },
    decrement: async (key) => {
        await database_1.redis.decr(key);
    },
    resetKey: async (key) => {
        await database_1.redis.del(key);
    }
};
// Rate limit configuration
exports.reviewLimiter = (0, express_rate_limit_1.default)({
    store: RedisStore,
    windowMs: 60 * 1000, // 1 minute
    max: 5, // 5 requests per minute
    message: 'Too many review submissions, please try again later'
});
exports.analyticsLimiter = (0, express_rate_limit_1.default)({
    store: RedisStore,
    windowMs: 60 * 1000, // 1 minute
    max: 30, // 30 requests per minute
    message: 'Too many analytics requests, please try again later'
});
