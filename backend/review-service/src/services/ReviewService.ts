import { Review } from '../models/Review';
import { IReview, ReviewAnalytics } from '../types';
import natural from 'natural';
import { redis } from '../config/database';

const tokenizer = new natural.WordTokenizer();
const analyzer = new natural.SentimentAnalyzer('English', natural.PorterStemmer, 'afinn');

type SentimentType = 'positive' | 'neutral' | 'negative';

export class ReviewService {
  private static CACHE_TTL = 3600; // 1 hour

  static async createReview(review: Omit<IReview, '_id' | 'createdAt' | 'updatedAt'>): Promise<IReview> {
    const sentiment = this.analyzeSentiment(review.comment);
    const newReview = new Review({ ...review, sentiment });
    return newReview.save();
  }

  static async getRestaurantReviews(restaurantId: string, page = 1, limit = 10): Promise<IReview[]> {
    const cacheKey = `reviews:restaurant:${restaurantId}:${page}:${limit}`;
    const cachedReviews = await redis.get(cacheKey);

    if (cachedReviews) {
      return JSON.parse(cachedReviews);
    }

    const reviews = await Review.find({ restaurantId, status: 'approved' })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);

    await redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(reviews));
    return reviews;
  }

  static async getUserReviews(customerId: string, page = 1, limit = 10): Promise<IReview[]> {
    const cacheKey = `reviews:user:${customerId}:${page}:${limit}`;
    const cachedReviews = await redis.get(cacheKey);

    if (cachedReviews) {
      return JSON.parse(cachedReviews);
    }

    const reviews = await Review.find({ customerId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);

    await redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(reviews));
    return reviews;
  }

  static async updateReview(id: string, update: Partial<IReview>): Promise<IReview | null> {
    if (update.comment) {
      update.sentiment = this.analyzeSentiment(update.comment);
    }
    return Review.findByIdAndUpdate(id, update, { new: true });
  }

  static async deleteReview(id: string): Promise<boolean> {
    const result = await Review.findByIdAndDelete(id);
    return !!result;
  }

  static async getReviewAnalytics(restaurantId: string): Promise<ReviewAnalytics> {
    const cacheKey = `analytics:restaurant:${restaurantId}`;
    const cachedAnalytics = await redis.get(cacheKey);

    if (cachedAnalytics) {
      return JSON.parse(cachedAnalytics);
    }

    const reviews = await Review.find({ restaurantId, status: 'approved' });
    
    const analytics: ReviewAnalytics = {
      averageRating: 0,
      totalReviews: reviews.length,
      ratingDistribution: {},
      sentimentDistribution: {
        positive: 0,
        neutral: 0,
        negative: 0
      }
    };

    reviews.forEach(review => {
      // Calculate average rating
      analytics.averageRating += review.rating;
      
      // Update rating distribution
      analytics.ratingDistribution[review.rating] = (analytics.ratingDistribution[review.rating] || 0) + 1;
      
      // Update sentiment distribution
      if (review.sentiment) {
        const sentiment = review.sentiment as SentimentType;
        analytics.sentimentDistribution[sentiment]++;
      }
    });

    if (reviews.length > 0) {
      analytics.averageRating /= reviews.length;
    }

    await redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(analytics));
    return analytics;
  }

  static analyzeSentiment(text: string): SentimentType {
    const tokens = tokenizer.tokenize(text) || [];
    const score = analyzer.getSentiment(tokens);

    if (score > 0.2) return 'positive';
    if (score < -0.2) return 'negative';
    return 'neutral';
  }
} 