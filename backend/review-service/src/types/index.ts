import { Request } from 'express';
import { JwtPayload } from 'jsonwebtoken';

export interface AuthenticatedRequest extends Request {
  user?: JwtPayload & {
    id: string;
    role: string;
  };
}

export interface IReview {
  _id?: string;
  restaurantId: string;
  customerId: string;
  rating: number;
  comment: string;
  images?: string[];
  sentiment?: string;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: Date;
  updatedAt: Date;
  response?: {
    text: string;
    createdAt: Date;
  };
}

export interface ReviewAnalytics {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: {
    [key: number]: number;
  };
  sentimentDistribution: {
    positive: number;
    neutral: number;
    negative: number;
  };
} 