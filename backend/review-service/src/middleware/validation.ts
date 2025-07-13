import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

export const validateReview = (req: Request, res: Response, next: NextFunction) => {
  const schema = Joi.object({
    restaurantId: Joi.string().required(),
    rating: Joi.number().min(1).max(5).required(),
    comment: Joi.string().min(10).max(500).required(),
    images: Joi.array().items(Joi.string()).max(5)
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  next();
};

export const validateReviewUpdate = (req: Request, res: Response, next: NextFunction) => {
  const schema = Joi.object({
    rating: Joi.number().min(1).max(5),
    comment: Joi.string().min(10).max(500),
    images: Joi.array().items(Joi.string()).max(5),
    status: Joi.string().valid('pending', 'approved', 'rejected')
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  next();
}; 