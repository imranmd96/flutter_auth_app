import mongoose, { Schema, Document } from 'mongoose';

export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';
export type PaymentMethod = 'credit_card' | 'debit_card' | 'paypal' | 'bank_transfer';

export interface Payment {
  id: string;
  orderId: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  paymentMethod: PaymentMethod;
  userId: string;
  restaurantId: string;
  metadata?: Record<string, unknown>;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePaymentDTO {
  orderId: string;
  amount: number;
  currency: string;
  paymentMethod: PaymentMethod;
  userId: string;
  restaurantId: string;
  metadata?: Record<string, unknown>;
}

export interface UpdatePaymentDTO {
  status?: PaymentStatus;
  metadata?: Record<string, unknown>;
}

export interface RefundPaymentDTO {
  amount: number;
  reason: string;
}

const PaymentSchema = new Schema({
  orderId: { type: String, required: true, unique: true, index: true },
  amount: { type: Number, required: true },
  currency: { type: String, required: true },
  status: { 
    type: String, 
    required: true, 
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'pending'
  },
  paymentMethod: { 
    type: String, 
    required: true, 
    enum: ['credit_card', 'debit_card', 'paypal', 'bank_transfer']
  },
  userId: { type: String, required: true, index: true },
  restaurantId: { type: String, required: true, index: true },
  metadata: { type: Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Add indexes for better query performance
PaymentSchema.index({ createdAt: -1 });
PaymentSchema.index({ status: 1 });
PaymentSchema.index({ restaurantId: 1, createdAt: -1 });
PaymentSchema.index({ userId: 1, createdAt: -1 });

export const PaymentModel = mongoose.model<Payment & Document>('Payment', PaymentSchema); 