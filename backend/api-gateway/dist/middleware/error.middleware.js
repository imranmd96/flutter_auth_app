"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = exports.AppError = void 0;
const logger_1 = require("../utils/logger");
class AppError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
        this.isOperational = true;
        Error.captureStackTrace(this, this.constructor);
    }
}
exports.AppError = AppError;
const errorHandler = (err, _req, res, _next) => {
    if (err instanceof AppError) {
        logger_1.logger.error(`[${err.statusCode}] ${err.message}`);
        return res.status(err.statusCode).json({
            status: err.status,
            message: err.message
        });
    }
    if (err.name === 'MongoError' && err.code === 11000) {
        logger_1.logger.error(`[409] Duplicate key error`);
        return res.status(409).json({
            status: 'fail',
            message: 'Duplicate field value entered'
        });
    }
    if (err.name === 'ValidationError') {
        logger_1.logger.error(`[400] Validation error`);
        return res.status(400).json({
            status: 'fail',
            message: err.message
        });
    }
    if (err.name === 'JsonWebTokenError') {
        logger_1.logger.error(`[401] Invalid token`);
        return res.status(401).json({
            status: 'fail',
            message: 'Invalid token. Please log in again'
        });
    }
    if (err.name === 'TokenExpiredError') {
        logger_1.logger.error(`[401] Token expired`);
        return res.status(401).json({
            status: 'fail',
            message: 'Your token has expired. Please log in again'
        });
    }
    logger_1.logger.error(`[500] ${err.message}`);
    return res.status(500).json({
        status: 'error',
        message: 'Something went wrong'
    });
};
exports.errorHandler = errorHandler;
//# sourceMappingURL=error.middleware.js.map