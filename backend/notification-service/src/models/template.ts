import mongoose, { Document, Schema } from 'mongoose';
import { NotificationType, NotificationChannel } from './notification';

export interface ITemplate extends Document {
  name: string;
  type: NotificationType;
  content: {
    subject?: string;
    title?: string;
    body: string;
    html?: string;
  };
  variables: string[];
  channels: NotificationChannel[];
  language: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const templateSchema = new Schema<ITemplate>(
  {
    name: {
      type: String,
      required: true,
      unique: true
    },
    type: {
      type: String,
      enum: Object.values(NotificationType),
      required: true
    },
    content: {
      subject: String,
      title: String,
      body: {
        type: String,
        required: true
      },
      html: String
    },
    variables: [{
      type: String,
      required: true
    }],
    channels: [{
      type: String,
      enum: Object.values(NotificationChannel),
      required: true
    }],
    language: {
      type: String,
      default: 'en'
    },
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

// Indexes
templateSchema.index({ name: 1 }, { unique: true });
templateSchema.index({ type: 1, language: 1 });
templateSchema.index({ isActive: 1 });

export const Template = mongoose.model<ITemplate>('Template', templateSchema); 