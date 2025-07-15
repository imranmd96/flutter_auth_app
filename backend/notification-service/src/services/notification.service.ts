import sgMail from '@sendgrid/mail';
import twilio from 'twilio';
import * as admin from 'firebase-admin';
import { Notification } from '../models/notification';
import { Preference } from '../models/preference';
import { Template } from '../models/template';
import { createClient } from 'redis';

export class NotificationService {
  private twilioClient: any;
  private redisClient: any;

  constructor() {
    this.initializeServices();
  }

  private async initializeServices(): Promise<void> {
    try {
    // Initialize SendGrid
    sgMail.setApiKey(process.env.SENDGRID_API_KEY || '');

    // Initialize Twilio
    this.twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );

    // Initialize Firebase Admin
      if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
      });
    }

      // Initialize Redis
      this.redisClient = createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379'
    });
      await this.redisClient.connect();

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to initialize notification services:', errorMessage);
    }
  }

  async sendNotification(notification: any): Promise<void> {
    try {
      // Check user preferences
      const preference = await this.getUserPreferences(notification.userId);

      if (!preference.types[notification.type]) {
        return;
      }

      if (!preference.channels[notification.channel]) {
        return;
      }

      // Send notification based on channel
      switch (notification.channel) {
        case 'email':
          await this.sendEmailNotification(notification);
          break;
        case 'sms':
          await this.sendSmsNotification(notification);
          break;
        case 'push':
          await this.sendPushNotification(notification);
          break;
        case 'in_app':
          await this.sendInAppNotification(notification);
          break;
        case 'web':
          await this.sendWebNotification(notification);
          break;
        default:
          console.warn(`Unsupported notification channel: ${notification.channel}`);
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send notification:', errorMessage);
    }
  }

  private async getUserPreferences(userId: string): Promise<any> {
    try {
      const preference = await Preference.findOne({ userId });
      return preference || this.getDefaultPreferences();
    } catch (error) {
      console.error('Failed to get user preferences:', error);
      return this.getDefaultPreferences();
    }
  }

  private getDefaultPreferences(): any {
    return {
      types: {
        order_status: true,
        booking_confirmation: true,
        payment_confirmation: true,
        reservation_change: true,
        special_offer: true,
        system_alert: true,
        review: true,
        chat: true,
        loyalty: true
      },
      channels: {
        email: true,
        push: true,
        sms: false,
        in_app: true,
        web: true
      }
    };
  }

  private async sendEmailNotification(notification: any): Promise<void> {
    try {
    const msg = {
        to: notification.recipient.email,
        from: process.env.FROM_EMAIL || 'noreply@forkline.com',
        subject: notification.title,
        text: notification.content,
        html: notification.content,
    };

    await sgMail.send(msg);
      console.log(`Email notification sent to ${notification.recipient.email}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send email notification:', errorMessage);
    }
  }

  private async sendSmsNotification(notification: any): Promise<void> {
    try {
    await this.twilioClient.messages.create({
        body: notification.content,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: notification.recipient.phone,
    });
      console.log(`SMS notification sent to ${notification.recipient.phone}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send SMS notification:', errorMessage);
    }
  }

  private async sendPushNotification(notification: any): Promise<void> {
    try {
    const message = {
      notification: {
          title: notification.title,
          body: notification.content,
      },
        token: notification.recipient.fcmToken,
    };

    await admin.messaging().send(message);
      console.log(`Push notification sent to ${notification.recipient.fcmToken}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send push notification:', errorMessage);
    }
  }

  private async sendInAppNotification(notification: any): Promise<void> {
    try {
    // Store in Redis for real-time delivery
      await this.redisClient.publish('notifications', JSON.stringify(notification));
      console.log(`In-app notification stored for user ${notification.userId}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send in-app notification:', errorMessage);
    }
  }

  private async sendWebNotification(notification: any): Promise<void> {
    try {
      // Use WebSocket to send real-time web notifications
      await this.redisClient.publish('web_notifications', JSON.stringify(notification));
      console.log(`Web notification sent for user ${notification.userId}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Failed to send web notification:', errorMessage);
    }
  }
} 