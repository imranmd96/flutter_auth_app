import logger from '../utils/logger.js';
import chalk from 'chalk';
import winston from 'winston';
export class AppError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
        this.isOperational = true;
        Error.captureStackTrace(this, this.constructor);
    }
}
export const errorHandler = (err, req, res, next) => {
    const hasConsole = logger.transports.some(t => t instanceof winston.transports.Console);
    const errorMsg = err instanceof AppError
        ? `[${err.statusCode}] ${err.message}`
        : `[500] ${err.message}`;
    if (hasConsole) {
        const coloredMsg = err instanceof AppError
            ? chalk.redBright(`[${err.statusCode}] `) + chalk.yellowBright(err.message)
            : chalk.bgRed.whiteBright('[500] ') + chalk.yellowBright(err.message);
        console.error(coloredMsg);
    }
    logger.error(errorMsg);
    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            status: err.status,
            message: err.message,
        });
    }
    return res.status(500).json({
        status: 'error',
        message: 'Something went wrong',
    });
};
//# sourceMappingURL=error.middleware.js.map