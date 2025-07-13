import { Request, Response, NextFunction } from 'express';
import { User, IUser } from '../models/user.model.js';
import { AppError } from '../middleware/error.middleware.js';
import logger from '../utils/logger.js';
import Redis from 'ioredis';

let redis: Redis | null = null;
if (process.env.REDIS_URL) {
  redis = new Redis(process.env.REDIS_URL);
}

export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return next(new AppError('User not found', 404));
    }

    res.status(200).json({
      status: 'success',
      data: {
        user,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, phone, address, preferences } = req.body;
    const updateData: any = { name, phone, address, preferences };
    // Only update profilePicture if it is an object with data and contentType
    if (
      req.body.profilePicture &&
      typeof req.body.profilePicture === 'object' &&
      req.body.profilePicture.data &&
      req.body.profilePicture.contentType
    ) {
      updateData.profilePicture = req.body.profilePicture;
    }
    const user = await User.findByIdAndUpdate(
      req.user.id,
      updateData,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Publish UserProfileUpdated event
    if (redis) {
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
    }

    res.status(200).json({
      status: 'success',
      data: {
        user,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const uploadAvatar = async (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log('uploadAvatar');
    const file = (req as any).file;
    if (!file) {
      return res.status(400).json({ status: 'error', message: 'No file uploaded' });
    }
    const userId = req.user.id;
    if (!userId) {
      return res.status(401).json({ status: 'fail', message: 'Not authorized' });
    }
    // Store image buffer and contentType in MongoDB
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { profilePicture: { data: file.buffer, contentType: file.mimetype } },
      { new: true, runValidators: true }
    );
    res.status(200).json({ status: 'success', user: updatedUser });
  } catch (error) {
    return next(error);
  }
};

export const getAvatar = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user || !user.profilePicture || !user.profilePicture.data) {
      return res.status(404).send('No image found');
    }
    res.contentType(user.profilePicture.contentType);
    return res.send(user.profilePicture.data);
  } catch (error) {
    return next(error);
  }
}; 