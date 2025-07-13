import { Request, Response, NextFunction } from 'express';
import { AppError } from './error.middleware';
import chalk from '../utils/chalk-wrapper';

export const validateRegister = (req: Request, _res: Response, next: NextFunction) => {
  console.log(chalk.yellow('==== VALIDATION MIDDLEWARE ===='));
  console.log(chalk.cyan('Request Body:'), req.body);
  console.log(chalk.cyan('Content-Type:'), req.headers['content-type']);
  
  // Check if req.body is empty or undefined
  if (!req.body || Object.keys(req.body).length === 0) {
    console.log(chalk.red('Empty request body detected!'));
    return next(new AppError('Request body is empty or invalid format', 400));
  }

  const { email, password, name, phone } = req.body;

  console.log(chalk.cyan('Email:'), email);
  console.log(chalk.cyan('Name:'), name);
  console.log(chalk.cyan('Phone:'), phone);
  console.log(chalk.cyan('Password length:'), password ? password.length : 'undefined');
  console.log(chalk.yellow('============================'));

  if (!email || !password || !name || !phone) {
    console.log(chalk.red('Missing required fields'));
    return next(new AppError('Please provide email, password, name and phone number', 400));
  }

  if (password.length < 6) {
    console.log(chalk.red('Password too short'));
    return next(new AppError('Password must be at least 6 characters long', 400));
  }

  if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
    console.log(chalk.red('Invalid email format'));
    return next(new AppError('Please provide a valid email address', 400));
  }

  if (!phone.match(/^\+?[\d\s-]{10,}$/)) {
    console.log(chalk.red('Invalid phone format'));
    return next(new AppError('Please provide a valid phone number', 400));
  }

  console.log(chalk.green('Validation passed successfully'));
  next();
};

export const validateLogin = (req: Request, _res: Response, next: NextFunction) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return next(new AppError('Please provide email and password', 400));
  }

  next();
}; 