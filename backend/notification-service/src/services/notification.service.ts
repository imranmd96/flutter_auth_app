import sgMail from '@sendgrid/mail';
import twilio from 'twilio';
import admin from 'firebase-admin';
import { Notification, NotificationChannel, NotificationStatus } from '../models/notification';
import { Template } from '../models/template';
import { Preference } from '../models/preference';
import { Redis } from 'redis';

export class NotificationService {
  private twilioClient: twilio.Twilio;
  private redisClient: Redis;

  constructor() {
    // Initialize SendGrid
    sgMail.setApiKey(process.env.SENDGRID_API_KEY || '');

    // Initialize Twilio
    this.twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );

    // Initialize Firebase Admin
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(require(process.env.FIREBASE_CREDENTIALS || ''))
      });
    }

    // Initialize Redis client
    this.redisClient = Redis.createClient({
      url: process.env.REDIS_URI || 'redis://localhost:6379'
    });
  }

  async sendNotification(notification: any): Promise<void> {
    try {
      // Check user preferences
      const preference = await Preference.findOne({ userId: notification.recipient.id });
      if (!preference) {
        throw new Error('User preferences not found');
      }

      // Check if notification type is enabled
      if (!preference.types[notification.type]) {
        console.log(`Notification type ${notification.type} is disabled for user ${notification.recipient.id}`);
        return;
      }

      // Check if channel is enabled
      if (!preference.channels[notification.channel]) {
        console.log(`Channel ${notification.channel} is disabled for user ${notification.recipient.id}`);
        return;
      }

      // Check quiet hours
      if (preference.quietHours.enabled && this.isInQuietHours(preference.quietHours)) {
        console.log(`In quiet hours for user ${notification.recipient.id}`);
        return;
      }

      // Get template
      const template = await Template.findOne({
        type: notification.type,
        language: preference.language,
        isActive: true
      });

      if (!template) {
        throw new Error(`Template not found for type ${notification.type}`);
      }

      // Process template variables
      const content = this.processTemplate(template.content, notification.content.data);

      // Send notification based on channel
      switch (notification.channel) {
        case NotificationChannel.EMAIL:
          await this.sendEmail(notification.recipient.email, content);
          break;
        case NotificationChannel.SMS:
          await this.sendSMS(notification.recipient.phone, content);
          break;
        case NotificationChannel.PUSH:
          await this.sendPushNotification(notification.recipient.deviceToken, content);
          break;
        case NotificationChannel.IN_APP:
          await this.sendInAppNotification(notification.recipient.id, content);
          break;
        case NotificationChannel.WEB:
          await this.sendWebNotification(notification.recipient.id, content);
          break;
        default:
          throw new Error(`Unsupported channel: ${notification.channel}`);
      }

      // Update notification status
      await Notification.findByIdAndUpdate(notification._id, {
        status: NotificationStatus.SENT,
        sentAt: new Date()
      });

    } catch (error) {
      console.error('Error sending notification:', error);
      await Notification.findByIdAndUpdate(notification._id, {
        status: NotificationStatus.FAILED,
        error: error.message
      });
      throw error;
    }
  }

  private async sendEmail(email: string, content: any): Promise<void> {
    const msg = {
      to: email,
      from: process.env.SENDGRID_FROM_EMAIL || 'noreply@forkline.com',
      subject: content.subject,
      text: content.body,
      html: content.html
    };

    await sgMail.send(msg);
  }

  private async sendSMS(phone: string, content: any): Promise<void> {
    await this.twilioClient.messages.create({
      body: content.body,
      to: phone,
      from: process.env.TWILIO_PHONE_NUMBER
    });
  }

  private async sendPushNotification(deviceToken: string, content: any): Promise<void> {
    const message = {
      notification: {
        title: content.title,
        body: content.body
      },
      data: content.data,
      token: deviceToken
    };

    await admin.messaging().send(message);
  }

  private async sendInAppNotification(userId: string, content: any): Promise<void> {
    // Store in Redis for real-time delivery
    await this.redisClient.publish('in-app-notifications', JSON.stringify({
      userId,
      content
    }));
  }

  private async sendWebNotification(userId: string, content: any): Promise<void> {
    // Store in Redis for real-time delivery
    await this.redisClient.publish('web-notifications', JSON.stringify({
      userId,
      content
    }));
  }

  private processTemplate(template: any, data: any): any {
    let processed = { ...template };
    
    // Replace variables in content
    Object.keys(data).forEach(key => {
      const regex = new RegExp(`{{${key}}}`, 'g');
      processed.body = processed.body.replace(regex, data[key]);
      if (processed.html) {
        processed.html = processed.html.replace(regex, data[key]);
      }
    });

    return processed;
  }

  private isInQuietHours(quietHours: any): boolean {
    const now = new Date();
    const [startHour, startMinute] = quietHours.start.split(':').map(Number);
    const [endHour, endMinute] = quietHours.end.split(':').map(Number);

    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();

    const startTime = startHour * 60 + startMinute;
    const endTime = endHour * 60 + endMinute;
    const currentTime = currentHour * 60 + currentMinute;

    return currentTime >= startTime && currentTime <= endTime;
  }
} 