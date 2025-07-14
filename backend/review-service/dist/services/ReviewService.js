"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReviewService = void 0;
const Review_1 = require("../models/Review");
const natural_1 = __importDefault(require("natural"));
const database_1 = require("../config/database");
const tokenizer = new natural_1.default.WordTokenizer();
const analyzer = new natural_1.default.SentimentAnalyzer('English', natural_1.default.PorterStemmer, 'afinn');
class ReviewService {
    static async createReview(review) {
        const sentiment = this.analyzeSentiment(review.comment);
        const newReview = new Review_1.Review({ ...review, sentiment });
        return newReview.save();
    }
    static async getRestaurantReviews(restaurantId, page = 1, limit = 10) {
        const cacheKey = `reviews:restaurant:${restaurantId}:${page}:${limit}`;
        const cachedReviews = await database_1.redis.get(cacheKey);
        if (cachedReviews) {
            return JSON.parse(cachedReviews);
        }
        const reviews = await Review_1.Review.find({ restaurantId, status: 'approved' })
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit);
        await database_1.redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(reviews));
        return reviews;
    }
    static async getUserReviews(customerId, page = 1, limit = 10) {
        const cacheKey = `reviews:user:${customerId}:${page}:${limit}`;
        const cachedReviews = await database_1.redis.get(cacheKey);
        if (cachedReviews) {
            return JSON.parse(cachedReviews);
        }
        const reviews = await Review_1.Review.find({ customerId })
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit);
        await database_1.redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(reviews));
        return reviews;
    }
    static async updateReview(id, update) {
        if (update.comment) {
            update.sentiment = this.analyzeSentiment(update.comment);
        }
        return Review_1.Review.findByIdAndUpdate(id, update, { new: true });
    }
    static async deleteReview(id) {
        const result = await Review_1.Review.findByIdAndDelete(id);
        return !!result;
    }
    static async getReviewAnalytics(restaurantId) {
        const cacheKey = `analytics:restaurant:${restaurantId}`;
        const cachedAnalytics = await database_1.redis.get(cacheKey);
        if (cachedAnalytics) {
            return JSON.parse(cachedAnalytics);
        }
        const reviews = await Review_1.Review.find({ restaurantId, status: 'approved' });
        const analytics = {
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
                const sentiment = review.sentiment;
                analytics.sentimentDistribution[sentiment]++;
            }
        });
        if (reviews.length > 0) {
            analytics.averageRating /= reviews.length;
        }
        await database_1.redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(analytics));
        return analytics;
    }
    static analyzeSentiment(text) {
        const tokens = tokenizer.tokenize(text) || [];
        const score = analyzer.getSentiment(tokens);
        if (score > 0.2)
            return 'positive';
        if (score < -0.2)
            return 'negative';
        return 'neutral';
    }
}
exports.ReviewService = ReviewService;
ReviewService.CACHE_TTL = 3600; // 1 hour
