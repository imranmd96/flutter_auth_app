"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateLogin = exports.validateRegister = void 0;
const error_middleware_1 = require("./error.middleware");
const chalk_wrapper_1 = __importDefault(require("../utils/chalk-wrapper"));
const validateRegister = (req, _res, next) => {
    console.log(chalk_wrapper_1.default.yellow('==== VALIDATION MIDDLEWARE ===='));
    console.log(chalk_wrapper_1.default.cyan('Request Body:'), req.body);
    console.log(chalk_wrapper_1.default.cyan('Content-Type:'), req.headers['content-type']);
    if (!req.body || Object.keys(req.body).length === 0) {
        console.log(chalk_wrapper_1.default.red('Empty request body detected!'));
        return next(new error_middleware_1.AppError('Request body is empty or invalid format', 400));
    }
    const { email, password, name, phone } = req.body;
    console.log(chalk_wrapper_1.default.cyan('Email:'), email);
    console.log(chalk_wrapper_1.default.cyan('Name:'), name);
    console.log(chalk_wrapper_1.default.cyan('Phone:'), phone);
    console.log(chalk_wrapper_1.default.cyan('Password length:'), password ? password.length : 'undefined');
    console.log(chalk_wrapper_1.default.yellow('============================'));
    if (!email || !password || !name || !phone) {
        console.log(chalk_wrapper_1.default.red('Missing required fields'));
        return next(new error_middleware_1.AppError('Please provide email, password, name and phone number', 400));
    }
    if (password.length < 6) {
        console.log(chalk_wrapper_1.default.red('Password too short'));
        return next(new error_middleware_1.AppError('Password must be at least 6 characters long', 400));
    }
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
        console.log(chalk_wrapper_1.default.red('Invalid email format'));
        return next(new error_middleware_1.AppError('Please provide a valid email address', 400));
    }
    if (!phone.match(/^\+?[\d\s-]{10,}$/)) {
        console.log(chalk_wrapper_1.default.red('Invalid phone format'));
        return next(new error_middleware_1.AppError('Please provide a valid phone number', 400));
    }
    console.log(chalk_wrapper_1.default.green('Validation passed successfully'));
    next();
};
exports.validateRegister = validateRegister;
const validateLogin = (req, _res, next) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return next(new error_middleware_1.AppError('Please provide email and password', 400));
    }
    next();
};
exports.validateLogin = validateLogin;
//# sourceMappingURL=validation.middleware.js.map