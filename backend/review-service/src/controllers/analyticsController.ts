import { Request, Response } from 'express';
import { ReviewService } from '../services/ReviewService';
import { Logger } from '../utils/logger';

export class AnalyticsController {
  static async getRestaurantAnalytics(req: Request, res: Response) {
    try {
      const analytics = await ReviewService.getReviewAnalytics(req.params.restaurantId);
      Logger.analyticsInfo(req.params.restaurantId, {
        averageRating: analytics.averageRating,
        totalReviews: analytics.totalReviews,
        positiveSentiment: analytics.sentimentDistribution.positive,
        neutralSentiment: analytics.sentimentDistribution.neutral,
        negativeSentiment: analytics.sentimentDistribution.negative
      });
      res.json(analytics);
    } catch (error) {
      Logger.error('Error fetching analytics:', error);
      res.status(500).json({ message: 'Error fetching analytics' });
    }
  }

  static async getSentimentAnalysis(req: Request, res: Response) {
    try {
      const { text } = req.body;
      if (!text) {
        Logger.warn('Sentiment analysis requested without text');
        return res.status(400).json({ message: 'Text is required' });
      }

      const sentiment = ReviewService.analyzeSentiment(text);
      Logger.info(`Analyzed sentiment: ${sentiment}`);
      res.json({ sentiment });
    } catch (error) {
      Logger.error('Error analyzing sentiment:', error);
      res.status(500).json({ message: 'Error analyzing sentiment' });
    }
  }
} 