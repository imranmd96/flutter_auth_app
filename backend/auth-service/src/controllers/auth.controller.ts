import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from '../middleware/error.middleware';
import { AuthUser } from '../models/authUser.model';
import { generateTokens, JWT_REFRESH_SECRET } from '../utils/token.utils';
import logger from '../utils/logger';
import Redis from 'ioredis';
import bcrypt from 'bcryptjs';
import { AuthRequest } from '../middleware/auth.middleware';

const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379');

export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    logger.request('POST', '/register', req.body);
    
    const { email, password, name, phone, role = 'user' } = req.body;
    
    // Check if user already exists
    const existingUser = await AuthUser.findOne({ email });
    if (existingUser) {
      logger.warn('User already exists', { email });
      res.status(400).json({
        status: 'error',
        message: 'User with this email already exists'
      });
      return;
    }
    
    // Create new user
    const user = await AuthUser.create({
      name,
      email,
      phone,
      password,
      role
    });

    logger.success('User created successfully', { email: user.email });

    // Publish UserRegistered event to Redis
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
    } catch (err) {
      console.error('Failed to publish UserRegistered event:', err);
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Save refresh token to user
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

    logger.response(201, response);
    res.status(201).json(response);
  } catch (error) {
    logger.error('Registration error', error);
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
  console.log('imran. login');
  console.log('login ifdmfj' + req.body);

  try {
    logger.request('POST', '/login', req.body);
    const { email, password } = req.body;

    // Find user and include password
    const user = await AuthUser.findOne({ email }).select('+password');
    if (!user) {
      logger.warn('Login failed: User not found', { email });
      return next(new AppError('Invalid credentials', 401));
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      logger.warn('Login failed: Invalid password', { email });
      return next(new AppError('Invalid credentials', 401));
    }

    logger.success('Login successful', { email: user.email });

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Save new refresh token to user (add to array, limit to 5)
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

    logger.response(200, response);
    res.status(200).json(response);
  } catch (error) {
    logger.error('Login error', error);
    next(error);
  }
};

export const refreshToken = async (req: Request, res: Response, next: NextFunction) => {
  logger.warn('imran. refreshToken');

  try {
    logger.request('POST', '/refresh-token', req.body);

    const { refreshToken } = req.body;

    if (!refreshToken) {
      logger.warn('Refresh token missing');
      return next(new AppError('Refresh token is required', 400));
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET) as { id: string };

    // Find user and check if refresh token exists in array
    const user = await AuthUser.findOne({ _id: decoded.id }).select('+refreshTokens');
    if (!user || !user.refreshTokens || !user.refreshTokens.some(rt => rt.token === refreshToken)) {
      logger.warn('Invalid refresh token', { userId: decoded.id });
      // Optionally: Invalidate all tokens for this user
      user && (user.refreshTokens = []);
      user && await user.save();
      return next(new AppError('Invalid refresh token', 401));
    }

    // Generate tokens
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);

    // Remove used token (rotation)
    user.refreshTokens = (user.refreshTokens || []).filter(rt => rt.token !== refreshToken);
    user.refreshTokens.push({ token: newRefreshToken, createdAt: new Date() });
    if (user.refreshTokens.length > 5) {
      user.refreshTokens = user.refreshTokens.slice(-5);
    }
    await user.save();

    logger.success('Token refresh successful', { userId: decoded.id });

    const response = {
      status: 'success',
      data: {
        tokens: {
          accessToken,
          refreshToken: newRefreshToken
        }
      },
    };

    logger.response(200, response);
    res.status(200).json(response);
  } catch (error) {
    logger.error('Token refresh error', error);
    next(new AppError('Invalid refresh token', 401));
  }
};

export const logout = async (req: Request, res: Response, next: NextFunction) => {
  try {
    logger.request('POST', '/logout', req.body);

    const { refreshToken } = req.body;

    if (!refreshToken) {
      logger.warn('Logout failed: Refresh token missing');
      return next(new AppError('Refresh token is required', 400));
    }

    // Remove only the refresh token for this session
    const user = await AuthUser.findOne({ 'refreshTokens.token': refreshToken }).select('+refreshTokens');
    if (user && user.refreshTokens) {
      user.refreshTokens = user.refreshTokens.filter(rt => rt.token !== refreshToken);
      await user.save();
      logger.success('Logout successful', { email: user.email });
    } else {
      logger.info('No user found with provided refresh token');
    }

    const response = {
      status: 'success',
      message: 'Logged out successfully',
    };

    logger.response(200, response);
    res.status(200).json(response);
  } catch (error) {
    logger.error('Logout error', error);
    next(error);
  }
};

export const updatePassword = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id; // assuming protect middleware sets req.user
    const { currentPassword, newPassword } = req.body;

    // Find user and include password
    const user = await AuthUser.findById(userId).select('+password');
    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Check current password
    const isPasswordCorrect = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordCorrect) {
      return next(new AppError('Current password is incorrect', 401));
    }

    // Set new password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Password updated successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const deleteAccount = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const user = await AuthUser.findByIdAndDelete(userId);
    if (!user) {
      return next(new AppError('User not found', 404));
    }
    // Publish UserDeleted event
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
    } catch (err) {
      console.error('Failed to publish UserDeleted event:', err);
    }
    res.status(200).json({
      status: 'success',
      message: 'Account deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { name, email, phone } = req.body;
    const updateData: any = {};
    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (phone !== undefined) updateData.phone = phone;
    const user = await AuthUser.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true });
    if (!user) {
      return next(new AppError('User not found', 404));
    }
    // Publish UserProfileUpdated event
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
  } catch (error) {
    next(error);
  }
}; 