"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.protect = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const error_middleware_1 = require("./error.middleware");
const authUser_model_1 = require("../models/authUser.model");
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const protect = async (req, _res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!(authHeader === null || authHeader === void 0 ? void 0 : authHeader.startsWith('Bearer '))) {
            return next(new error_middleware_1.AppError('Not authorized to access this route', 401));
        }
        const token = authHeader.split(' ')[1];
        const decoded = jsonwebtoken_1.default.verify(token, JWT_SECRET);
        const user = await authUser_model_1.AuthUser.findById(decoded.id);
        if (!user) {
            return next(new error_middleware_1.AppError('User not found', 404));
        }
        req.user = user;
        req.user.role = decoded.role;
        next();
    }
    catch (error) {
        next(new error_middleware_1.AppError('Not authorized to access this route', 401));
    }
};
exports.protect = protect;
//# sourceMappingURL=auth.middleware.js.map