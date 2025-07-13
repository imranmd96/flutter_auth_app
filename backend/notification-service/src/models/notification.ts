import mongoose, { Document, Schema } from 'mongoose';

export enum NotificationChannel {
  EMAIL = 'email',
  PUSH = 'push',
  SMS = 'sms',
  IN_APP = 'in_app',
  WEB = 'web'
}

export enum NotificationType {
  ORDER_STATUS = 'order_status',
  BOOKING_CONFIRMATION = 'booking_confirmation',
  PAYMENT_CONFIRMATION = 'payment_confirmation',
  RESERVATION_CHANGE = 'reservation_change',
  SPECIAL_OFFER = 'special_offer',
  SYSTEM_ALERT = 'system_alert',
  REVIEW = 'review',
  CHAT = 'chat',
  LOYALTY = 'loyalty'
}

export enum NotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  DELIVERED = 'delivered',
  FAILED = 'failed',
  READ = 'read'
}

export enum NotificationPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}

export interface INotification extends Document {
  type: NotificationType;
  channel: NotificationChannel;
  recipient: {
    id: string;
    type: 'user' | 'restaurant' | 'staff';
    email?: string;
    phone?: string;
    deviceToken?: string;
  };
  content: {
    title: string;
    body: string;
    data?: Record<string, any>;
  };
  status: NotificationStatus;
  priority: NotificationPriority;
  scheduledTime?: Date;
  sentAt?: Date;
  deliveredAt?: Date;
  readAt?: Date;
  error?: string;
  metadata?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

const notificationSchema = new Schema<INotification>(
  {
    type: {
      type: String,
      enum: Object.values(NotificationType),
      required: true
    },
    channel: {
      type: String,
      enum: Object.values(NotificationChannel),
      required: true
    },
    recipient: {
      id: { type: String, required: true },
      type: { type: String, enum: ['user', 'restaurant', 'staff'], required: true },
      email: String,
      phone: String,
      deviceToken: String
    },
    content: {
      title: { type: String, required: true },
      body: { type: String, required: true },
      data: Schema.Types.Mixed
    },
    status: {
      type: String,
      enum: Object.values(NotificationStatus),
      default: NotificationStatus.PENDING
    },
    priority: {
      type: String,
      enum: Object.values(NotificationPriority),
      default: NotificationPriority.MEDIUM
    },
    scheduledTime: Date,
    sentAt: Date,
    deliveredAt: Date,
    readAt: Date,
    error: String,
    metadata: Schema.Types.Mixed
  },
  {
    timestamps: true
  }
);

// Indexes
notificationSchema.index({ 'recipient.id': 1, createdAt: -1 });
notificationSchema.index({ type: 1, status: 1 });
notificationSchema.index({ scheduledTime: 1 }, { sparse: true });
notificationSchema.index({ status: 1, priority: 1 });

export const Notification = mongoose.model<INotification>('Notification', notificationSchema); 