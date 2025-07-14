"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateTokens = exports.JWT_REFRESH_SECRET = exports.JWT_SECRET = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
exports.JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
exports.JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret-key';
const ACCESS_TOKEN_EXPIRES_IN = (process.env.JWT_EXPIRES_IN || '25m');
const REFRESH_TOKEN_EXPIRES_IN = (process.env.JWT_REFRESH_EXPIRES_IN || '30m');
const generateTokens = (user) => {
    const accessToken = jsonwebtoken_1.default.sign({ id: user._id, role: user.role }, exports.JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRES_IN });
    const refreshToken = jsonwebtoken_1.default.sign({ id: user._id, role: user.role }, exports.JWT_REFRESH_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRES_IN });
    return { accessToken, refreshToken };
};
exports.generateTokens = generateTokens;
//# sourceMappingURL=token.utils.js.map