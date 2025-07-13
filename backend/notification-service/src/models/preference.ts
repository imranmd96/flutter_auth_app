import mongoose, { Document, Schema } from 'mongoose';
import { NotificationType, NotificationChannel } from './notification';

export interface IPreference extends Document {
  userId: string;
  channels: {
    [key in NotificationChannel]: boolean;
  };
  types: {
    [key in NotificationType]: boolean;
  };
  quietHours: {
    enabled: boolean;
    start: string;
    end: string;
    timezone: string;
  };
  language: string;
  updatedAt: Date;
}

const preferenceSchema = new Schema<IPreference>(
  {
    userId: {
      type: String,
      required: true,
      unique: true
    },
    channels: {
      email: { type: Boolean, default: true },
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: true },
      in_app: { type: Boolean, default: true },
      web: { type: Boolean, default: true }
    },
    types: {
      order_status: { type: Boolean, default: true },
      booking_confirmation: { type: Boolean, default: true },
      payment_confirmation: { type: Boolean, default: true },
      reservation_change: { type: Boolean, default: true },
      special_offer: { type: Boolean, default: true },
      system_alert: { type: Boolean, default: true },
      review: { type: Boolean, default: true },
      chat: { type: Boolean, default: true },
      loyalty: { type: Boolean, default: true }
    },
    quietHours: {
      enabled: { type: Boolean, default: false },
      start: { type: String, default: '22:00' },
      end: { type: String, default: '08:00' },
      timezone: { type: String, default: 'UTC' }
    },
    language: {
      type: String,
      default: 'en'
    }
  },
  {
    timestamps: true
  }
);

// Indexes
preferenceSchema.index({ userId: 1 }, { unique: true });

export const Preference = mongoose.model<IPreference>('Preference', preferenceSchema); 