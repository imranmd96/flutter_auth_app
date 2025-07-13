import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger.js';
import chalk from 'chalk';
import winston from 'winston';

export class AppError extends Error {
  statusCode: number;
  status: string;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Colorize error for console, plain for file logs
  const hasConsole = logger.transports.some(t => t instanceof winston.transports.Console);
  const errorMsg = err instanceof AppError
    ? `[${err.statusCode}] ${err.message}`
    : `[500] ${err.message}`;

  if (hasConsole) {
    // Colorize for console
    const coloredMsg = err instanceof AppError
      ? chalk.redBright(`[${err.statusCode}] `) + chalk.yellowBright(err.message)
      : chalk.bgRed.whiteBright('[500] ') + chalk.yellowBright(err.message);
    // Log to console
    console.error(coloredMsg);
  }
  // Always log to winston (file and console)
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