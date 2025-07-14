"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.restrictTo = exports.protect = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const error_middleware_1 = require("./error.middleware");
const logger_1 = require("../utils/logger");
const protect = async (req, _res, next) => {
    try {
        let token;
        if (req.headers.authorization &&
            req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }
        if (!token) {
            return next(new error_middleware_1.AppError('You are not logged in', 401));
        }
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        req.user = {
            id: decoded.id
        };
        next();
    }
    catch (error) {
        logger_1.logger.error(`Authentication error: ${error}`);
        next(new error_middleware_1.AppError('Authentication failed', 401));
    }
};
exports.protect = protect;
const restrictTo = (..._roles) => {
    return (_req, _res, next) => {
        next();
    };
};
exports.restrictTo = restrictTo;
//# sourceMappingURL=auth.middleware.js.map