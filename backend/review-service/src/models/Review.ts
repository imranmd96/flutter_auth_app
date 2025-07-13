import mongoose, { Schema, Document } from 'mongoose';
import { IReview } from '../types';

const ReviewSchema = new Schema<IReview>({
  restaurantId: { type: String, required: true, index: true },
  customerId: { type: String, required: true, index: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String, required: true },
  images: [{ type: String }],
  sentiment: { type: String, enum: ['positive', 'neutral', 'negative'] },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending'
  },
  response: {
    text: String,
    createdAt: Date
  }
}, {
  timestamps: true
});

// Indexes for better query performance
ReviewSchema.index({ restaurantId: 1, createdAt: -1 });
ReviewSchema.index({ customerId: 1, createdAt: -1 });
ReviewSchema.index({ status: 1 });

export const Review = mongoose.model<IReview>('Review', ReviewSchema); 