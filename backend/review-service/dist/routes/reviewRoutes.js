"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const ReviewService_1 = require("../services/ReviewService");
const auth_1 = require("../middleware/auth");
const validation_1 = require("../middleware/validation");
const rateLimit_1 = require("../middleware/rateLimit");
const router = (0, express_1.Router)();
// Create a new review
router.post('/', auth_1.authenticate, (0, auth_1.authorize)(['customer']), rateLimit_1.reviewLimiter, validation_1.validateReview, async (req, res) => {
    try {
        const review = await ReviewService_1.ReviewService.createReview({
            ...req.body,
            customerId: req.user.id
        });
        res.status(201).json(review);
    }
    catch (error) {
        res.status(500).json({ message: 'Error creating review' });
    }
});
// Get restaurant reviews
router.get('/restaurant/:restaurantId', rateLimit_1.analyticsLimiter, async (req, res) => {
    try {
        const { page, limit } = req.query;
        const reviews = await ReviewService_1.ReviewService.getRestaurantReviews(req.params.restaurantId, Number(page) || 1, Number(limit) || 10);
        res.json(reviews);
    }
    catch (error) {
        res.status(500).json({ message: 'Error fetching reviews' });
    }
});
// Get user reviews
router.get('/user', auth_1.authenticate, rateLimit_1.analyticsLimiter, async (req, res) => {
    try {
        const { page, limit } = req.query;
        const reviews = await ReviewService_1.ReviewService.getUserReviews(req.user.id, Number(page) || 1, Number(limit) || 10);
        res.json(reviews);
    }
    catch (error) {
        res.status(500).json({ message: 'Error fetching reviews' });
    }
});
// Update a review
router.put('/:id', auth_1.authenticate, validation_1.validateReviewUpdate, async (req, res) => {
    try {
        const review = await ReviewService_1.ReviewService.updateReview(req.params.id, req.body);
        if (!review) {
            return res.status(404).json({ message: 'Review not found' });
        }
        res.json(review);
    }
    catch (error) {
        res.status(500).json({ message: 'Error updating review' });
    }
});
// Delete a review
router.delete('/:id', auth_1.authenticate, async (req, res) => {
    try {
        const success = await ReviewService_1.ReviewService.deleteReview(req.params.id);
        if (!success) {
            return res.status(404).json({ message: 'Review not found' });
        }
        res.status(204).send();
    }
    catch (error) {
        res.status(500).json({ message: 'Error deleting review' });
    }
});
// Get review analytics
router.get('/analytics/:restaurantId', auth_1.authenticate, (0, auth_1.authorize)(['admin', 'restaurant']), rateLimit_1.analyticsLimiter, async (req, res) => {
    try {
        const analytics = await ReviewService_1.ReviewService.getReviewAnalytics(req.params.restaurantId);
        res.json(analytics);
    }
    catch (error) {
        res.status(500).json({ message: 'Error fetching analytics' });
    }
});
exports.default = router;
