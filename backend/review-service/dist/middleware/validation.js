"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateReviewUpdate = exports.validateReview = void 0;
const joi_1 = __importDefault(require("joi"));
const validateReview = (req, res, next) => {
    const schema = joi_1.default.object({
        restaurantId: joi_1.default.string().required(),
        rating: joi_1.default.number().min(1).max(5).required(),
        comment: joi_1.default.string().min(10).max(500).required(),
        images: joi_1.default.array().items(joi_1.default.string()).max(5)
    });
    const { error } = schema.validate(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }
    next();
};
exports.validateReview = validateReview;
const validateReviewUpdate = (req, res, next) => {
    const schema = joi_1.default.object({
        rating: joi_1.default.number().min(1).max(5),
        comment: joi_1.default.string().min(10).max(500),
        images: joi_1.default.array().items(joi_1.default.string()).max(5),
        status: joi_1.default.string().valid('pending', 'approved', 'rejected')
    });
    const { error } = schema.validate(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }
    next();
};
exports.validateReviewUpdate = validateReviewUpdate;
