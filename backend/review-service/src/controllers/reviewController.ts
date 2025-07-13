import { Request, Response } from 'express';
import { ReviewService } from '../services/ReviewService';
import { AuthenticatedRequest } from '../types';
import { Logger } from '../utils/logger';

export class ReviewController {
  static async createReview(req: AuthenticatedRequest, res: Response) {
    try {
      const review = await ReviewService.createReview({
        ...req.body,
        customerId: req.user!.id
      });
      Logger.success(`Review created for restaurant ${req.body.restaurantId}`);
      res.status(201).json(review);
    } catch (error) {
      Logger.error('Error creating review:', error);
      res.status(500).json({ message: 'Error creating review' });
    }
  }

  static async getRestaurantReviews(req: Request, res: Response) {
    try {
      const { page, limit } = req.query;
      const reviews = await ReviewService.getRestaurantReviews(
        req.params.restaurantId,
        Number(page) || 1,
        Number(limit) || 10
      );
      Logger.info(`Fetched ${reviews.length} reviews for restaurant ${req.params.restaurantId}`);
      res.json(reviews);
    } catch (error) {
      Logger.error('Error fetching reviews:', error);
      res.status(500).json({ message: 'Error fetching reviews' });
    }
  }

  static async getUserReviews(req: AuthenticatedRequest, res: Response) {
    try {
      const { page, limit } = req.query;
      const reviews = await ReviewService.getUserReviews(
        req.user!.id,
        Number(page) || 1,
        Number(limit) || 10
      );
      Logger.info(`Fetched ${reviews.length} reviews for user ${req.user!.id}`);
      res.json(reviews);
    } catch (error) {
      Logger.error('Error fetching user reviews:', error);
      res.status(500).json({ message: 'Error fetching reviews' });
    }
  }

  static async updateReview(req: AuthenticatedRequest, res: Response) {
    try {
      const review = await ReviewService.updateReview(req.params.id, req.body);
      if (!review) {
        Logger.warn(`Review ${req.params.id} not found for update`);
        return res.status(404).json({ message: 'Review not found' });
      }
      Logger.success(`Review ${req.params.id} updated successfully`);
      res.json(review);
    } catch (error) {
      Logger.error('Error updating review:', error);
      res.status(500).json({ message: 'Error updating review' });
    }
  }

  static async deleteReview(req: AuthenticatedRequest, res: Response) {
    try {
      const success = await ReviewService.deleteReview(req.params.id);
      if (!success) {
        Logger.warn(`Review ${req.params.id} not found for deletion`);
        return res.status(404).json({ message: 'Review not found' });
      }
      Logger.success(`Review ${req.params.id} deleted successfully`);
      res.status(204).send();
    } catch (error) {
      Logger.error('Error deleting review:', error);
      res.status(500).json({ message: 'Error deleting review' });
    }
  }

  static async getReviewAnalytics(req: Request, res: Response) {
    try {
      const analytics = await ReviewService.getReviewAnalytics(req.params.restaurantId);
      res.json(analytics);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching analytics' });
    }
  }
} 