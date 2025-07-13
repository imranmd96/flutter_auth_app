import { NotificationService } from '../services/notification.service';
import { Notification, NotificationType, NotificationChannel, NotificationStatus } from '../models/notification';
import { Template } from '../models/template';
import { Preference } from '../models/preference';
import { config } from '../config';

// Mock external dependencies
jest.mock('@sendgrid/mail');
jest.mock('twilio');
jest.mock('firebase-admin');
jest.mock('ioredis');

describe('NotificationService', () => {
  let notificationService: NotificationService;
  let mockNotification: Partial<Notification>;
  let mockTemplate: Partial<Template>;
  let mockPreference: Partial<Preference>;

  beforeEach(() => {
    notificationService = new NotificationService();
    
    // Setup mock data
    mockNotification = {
      type: NotificationType.ORDER_STATUS,
      channel: NotificationChannel.EMAIL,
      recipient: {
        id: 'user123',
        type: 'user',
        email: 'test@example.com',
      },
      content: {
        title: 'Order Status Update',
        body: 'Your order has been confirmed',
      },
      status: NotificationStatus.PENDING,
    };

    mockTemplate = {
      name: 'Order Status Template',
      type: NotificationType.ORDER_STATUS,
      content: {
        title: 'Order Status: {{status}}',
        body: 'Your order #{{orderId}} has been {{status}}',
      },
      variables: ['status', 'orderId'],
      channels: [NotificationChannel.EMAIL],
      language: 'en',
      isActive: true,
    };

    mockPreference = {
      userId: 'user123',
      channels: [NotificationChannel.EMAIL, NotificationChannel.PUSH],
      types: [NotificationType.ORDER_STATUS, NotificationType.PAYMENT],
      quietHours: {
        start: '22:00',
        end: '08:00',
      },
      language: 'en',
    };
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('sendNotification', () => {
    it('should send notification successfully', async () => {
      const result = await notificationService.sendNotification(mockNotification as Notification);
      expect(result).toBeDefined();
      expect(result.status).toBe(NotificationStatus.SENT);
    });

    it('should respect user preferences', async () => {
      const preference = await Preference.findOne({ userId: mockNotification.recipient?.id });
      if (preference) {
        expect(preference.channels).toContain(mockNotification.channel);
      }
    });

    it('should handle quiet hours', async () => {
      const currentTime = new Date();
      currentTime.setHours(23); // Set to 11 PM
      
      const preference = await Preference.findOne({ userId: mockNotification.recipient?.id });
      if (preference?.quietHours) {
        const { start, end } = preference.quietHours;
        const isQuiet = currentTime.getHours() >= parseInt(start.split(':')[0]) ||
                       currentTime.getHours() < parseInt(end.split(':')[0]);
        
        if (isQuiet) {
          expect(mockNotification.status).toBe(NotificationStatus.SCHEDULED);
        }
      }
    });
  });

  describe('processTemplate', () => {
    it('should process template with variables', async () => {
      const variables = {
        status: 'confirmed',
        orderId: '12345',
      };

      const processedContent = await notificationService['processTemplate'](
        mockTemplate as Template,
        variables
      );

      expect(processedContent.title).toBe('Order Status: confirmed');
      expect(processedContent.body).toBe('Your order #12345 has been confirmed');
    });

    it('should handle missing variables', async () => {
      const variables = {
        status: 'confirmed',
      };

      const processedContent = await notificationService['processTemplate'](
        mockTemplate as Template,
        variables
      );

      expect(processedContent.title).toBe('Order Status: confirmed');
      expect(processedContent.body).toBe('Your order #{{orderId}} has been confirmed');
    });
  });

  describe('channel-specific methods', () => {
    it('should send email notification', async () => {
      const result = await notificationService['sendEmail'](
        mockNotification.recipient?.email || '',
        mockNotification.content?.title || '',
        mockNotification.content?.body || ''
      );
      expect(result).toBe(true);
    });

    it('should send SMS notification', async () => {
      const result = await notificationService['sendSMS'](
        mockNotification.recipient?.phone || '',
        mockNotification.content?.body || ''
      );
      expect(result).toBe(true);
    });

    it('should send push notification', async () => {
      const result = await notificationService['sendPushNotification'](
        mockNotification.recipient?.id || '',
        mockNotification.content?.title || '',
        mockNotification.content?.body || ''
      );
      expect(result).toBe(true);
    });
  });

  describe('error handling', () => {
    it('should handle email sending failure', async () => {
      jest.spyOn(notificationService['sendgrid'], 'send').mockRejectedValueOnce(new Error('Email sending failed'));
      
      const result = await notificationService['sendEmail'](
        mockNotification.recipient?.email || '',
        mockNotification.content?.title || '',
        mockNotification.content?.body || ''
      );
      
      expect(result).toBe(false);
    });

    it('should handle SMS sending failure', async () => {
      jest.spyOn(notificationService['twilio'], 'messages.create').mockRejectedValueOnce(new Error('SMS sending failed'));
      
      const result = await notificationService['sendSMS'](
        mockNotification.recipient?.phone || '',
        mockNotification.content?.body || ''
      );
      
      expect(result).toBe(false);
    });

    it('should handle push notification failure', async () => {
      jest.spyOn(notificationService['firebase'], 'messaging').mockRejectedValueOnce(new Error('Push notification failed'));
      
      const result = await notificationService['sendPushNotification'](
        mockNotification.recipient?.id || '',
        mockNotification.content?.title || '',
        mockNotification.content?.body || ''
      );
      
      expect(result).toBe(false);
    });
  });
}); 