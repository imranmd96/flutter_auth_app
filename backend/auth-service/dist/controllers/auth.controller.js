"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateProfile = exports.deleteAccount = exports.updatePassword = exports.logout = exports.refreshToken = exports.login = exports.register = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const error_middleware_1 = require("../middleware/error.middleware");
const authUser_model_1 = require("../models/authUser.model");
const token_utils_1 = require("../utils/token.utils");
const logger_1 = __importDefault(require("../utils/logger"));
const ioredis_1 = __importDefault(require("ioredis"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const redis = new ioredis_1.default(process.env.REDIS_URL || 'redis://redis:6379');
const register = async (req, res, next) => {
    try {
        logger_1.default.request('POST', '/register', req.body);
        const { email, password, name, phone, role = 'user' } = req.body;
        const existingUser = await authUser_model_1.AuthUser.findOne({ email });
        if (existingUser) {
            logger_1.default.warn('User already exists', { email });
            res.status(400).json({
                status: 'error',
                message: 'User with this email already exists'
            });
            return;
        }
        const user = await authUser_model_1.AuthUser.create({
            name,
            email,
            phone,
            password,
            role
        });
        logger_1.default.success('User created successfully', { email: user.email });
        const eventPayload = {
            type: 'UserRegistered',
            payload: {
                id: user._id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                role: user.role
            }
        };
        try {
            await redis.publish('user-events', JSON.stringify(eventPayload));
            console.log('UserRegistered event published successfully:', eventPayload);
        }
        catch (err) {
            console.error('Failed to publish UserRegistered event:', err);
        }
        const { accessToken, refreshToken } = (0, token_utils_1.generateTokens)(user);
        user.refreshTokens = user.refreshTokens || [];
        user.refreshTokens.push({ token: refreshToken, createdAt: new Date() });
        if (user.refreshTokens.length > 5) {
            user.refreshTokens = user.refreshTokens.slice(-5);
        }
        await user.save();
        const response = {
            status: 'success',
            message: 'User registered successfully',
            userId: user._id,
            email: user.email,
            role: user.role,
            tokens: {
                accessToken,
                refreshToken
            }
        };
        logger_1.default.response(201, response);
        res.status(201).json(response);
    }
    catch (error) {
        logger_1.default.error('Registration error', error);
        next(error);
    }
};
exports.register = register;
const login = async (req, res, next) => {
    console.log('imran. login');
    console.log('login ifdmfj' + req.body);
    try {
        logger_1.default.request('POST', '/login', req.body);
        const { email, password } = req.body;
        const user = await authUser_model_1.AuthUser.findOne({ email }).select('+password');
        if (!user) {
            logger_1.default.warn('Login failed: User not found', { email });
            return next(new error_middleware_1.AppError('Invalid credentials', 401));
        }
        const isPasswordValid = await user.comparePassword(password);
        if (!isPasswordValid) {
            logger_1.default.warn('Login failed: Invalid password', { email });
            return next(new error_middleware_1.AppError('Invalid credentials', 401));
        }
        logger_1.default.success('Login successful', { email: user.email });
        const { accessToken, refreshToken } = (0, token_utils_1.generateTokens)(user);
        user.refreshTokens = user.refreshTokens || [];
        user.refreshTokens.push({ token: refreshToken, createdAt: new Date() });
        if (user.refreshTokens.length > 5) {
            user.refreshTokens = user.refreshTokens.slice(-5);
        }
        await user.save();
        const response = {
            status: 'success',
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    name: user.name,
                    role: user.role
                },
                tokens: {
                    accessToken,
                    refreshToken,
                },
            },
        };
        logger_1.default.response(200, response);
        res.status(200).json(response);
    }
    catch (error) {
        logger_1.default.error('Login error', error);
        next(error);
    }
};
exports.login = login;
const refreshToken = async (req, res, next) => {
    logger_1.default.warn('imran. refreshToken');
    try {
        logger_1.default.request('POST', '/refresh-token', req.body);
        const { refreshToken } = req.body;
        if (!refreshToken) {
            logger_1.default.warn('Refresh token missing');
            return next(new error_middleware_1.AppError('Refresh token is required', 400));
        }
        const decoded = jsonwebtoken_1.default.verify(refreshToken, token_utils_1.JWT_REFRESH_SECRET);
        const user = await authUser_model_1.AuthUser.findOne({ _id: decoded.id }).select('+refreshTokens');
        if (!user || !user.refreshTokens || !user.refreshTokens.some(rt => rt.token === refreshToken)) {
            logger_1.default.warn('Invalid refresh token', { userId: decoded.id });
            user && (user.refreshTokens = []);
            user && await user.save();
            return next(new error_middleware_1.AppError('Invalid refresh token', 401));
        }
        const { accessToken, refreshToken: newRefreshToken } = (0, token_utils_1.generateTokens)(user);
        user.refreshTokens = (user.refreshTokens || []).filter(rt => rt.token !== refreshToken);
        user.refreshTokens.push({ token: newRefreshToken, createdAt: new Date() });
        if (user.refreshTokens.length > 5) {
            user.refreshTokens = user.refreshTokens.slice(-5);
        }
        await user.save();
        logger_1.default.success('Token refresh successful', { userId: decoded.id });
        const response = {
            status: 'success',
            data: {
                tokens: {
                    accessToken,
                    refreshToken: newRefreshToken
                }
            },
        };
        logger_1.default.response(200, response);
        res.status(200).json(response);
    }
    catch (error) {
        logger_1.default.error('Token refresh error', error);
        next(new error_middleware_1.AppError('Invalid refresh token', 401));
    }
};
exports.refreshToken = refreshToken;
const logout = async (req, res, next) => {
    try {
        logger_1.default.request('POST', '/logout', req.body);
        const { refreshToken } = req.body;
        if (!refreshToken) {
            logger_1.default.warn('Logout failed: Refresh token missing');
            return next(new error_middleware_1.AppError('Refresh token is required', 400));
        }
        const user = await authUser_model_1.AuthUser.findOne({ 'refreshTokens.token': refreshToken }).select('+refreshTokens');
        if (user && user.refreshTokens) {
            user.refreshTokens = user.refreshTokens.filter(rt => rt.token !== refreshToken);
            await user.save();
            logger_1.default.success('Logout successful', { email: user.email });
        }
        else {
            logger_1.default.info('No user found with provided refresh token');
        }
        const response = {
            status: 'success',
            message: 'Logged out successfully',
        };
        logger_1.default.response(200, response);
        res.status(200).json(response);
    }
    catch (error) {
        logger_1.default.error('Logout error', error);
        next(error);
    }
};
exports.logout = logout;
const updatePassword = async (req, res, next) => {
    try {
        const userId = req.user._id;
        const { currentPassword, newPassword } = req.body;
        const user = await authUser_model_1.AuthUser.findById(userId).select('+password');
        if (!user) {
            return next(new error_middleware_1.AppError('User not found', 404));
        }
        const isPasswordCorrect = await bcryptjs_1.default.compare(currentPassword, user.password);
        if (!isPasswordCorrect) {
            return next(new error_middleware_1.AppError('Current password is incorrect', 401));
        }
        user.password = newPassword;
        await user.save();
        res.status(200).json({
            status: 'success',
            message: 'Password updated successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updatePassword = updatePassword;
const deleteAccount = async (req, res, next) => {
    try {
        const userId = req.user._id;
        const user = await authUser_model_1.AuthUser.findByIdAndDelete(userId);
        if (!user) {
            return next(new error_middleware_1.AppError('User not found', 404));
        }
        const eventPayload = {
            type: 'UserDeleted',
            payload: {
                id: user._id,
                email: user.email
            }
        };
        try {
            await redis.publish('user-events', JSON.stringify(eventPayload));
            console.log('UserDeleted event published successfully:', eventPayload);
        }
        catch (err) {
            console.error('Failed to publish UserDeleted event:', err);
        }
        res.status(200).json({
            status: 'success',
            message: 'Account deleted successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteAccount = deleteAccount;
const updateProfile = async (req, res, next) => {
    try {
        const userId = req.user._id;
        const { name, email, phone } = req.body;
        const updateData = {};
        if (name !== undefined)
            updateData.name = name;
        if (email !== undefined)
            updateData.email = email;
        if (phone !== undefined)
            updateData.phone = phone;
        const user = await authUser_model_1.AuthUser.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true });
        if (!user) {
            return next(new error_middleware_1.AppError('User not found', 404));
        }
        const eventPayload = {
            type: 'UserProfileUpdated',
            payload: {
                id: user._id,
                name: user.name,
                email: user.email,
                phone: user.phone
            }
        };
        await redis.publish('user-events', JSON.stringify(eventPayload));
        res.status(200).json({
            status: 'success',
            data: { user }
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updateProfile = updateProfile;
//# sourceMappingURL=auth.controller.js.map