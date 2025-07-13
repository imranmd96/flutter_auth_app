import { NotificationType, NotificationChannel, NotificationPriority } from '../models/notification';

export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const isValidPhoneNumber = (phone: string): boolean => {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(phone);
};

export const formatNotificationContent = (
  template: string,
  variables: Record<string, string>
): string => {
  return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
    return variables[key] || match;
  });
};

export const getNotificationPriority = (
  type: NotificationType,
  channel: NotificationChannel
): NotificationPriority => {
  // Define priority based on notification type and channel
  const priorityMap: Record<NotificationType, Record<NotificationChannel, NotificationPriority>> = {
    [NotificationType.ORDER_STATUS]: {
      [NotificationChannel.EMAIL]: NotificationPriority.MEDIUM,
      [NotificationChannel.SMS]: NotificationPriority.HIGH,
      [NotificationChannel.PUSH]: NotificationPriority.HIGH,
      [NotificationChannel.IN_APP]: NotificationPriority.MEDIUM,
      [NotificationChannel.WEB]: NotificationPriority.MEDIUM,
    },
    [NotificationType.PAYMENT]: {
      [NotificationChannel.EMAIL]: NotificationPriority.HIGH,
      [NotificationChannel.SMS]: NotificationPriority.HIGH,
      [NotificationChannel.PUSH]: NotificationPriority.HIGH,
      [NotificationChannel.IN_APP]: NotificationPriority.HIGH,
      [NotificationChannel.WEB]: NotificationPriority.HIGH,
    },
    [NotificationType.BOOKING]: {
      [NotificationChannel.EMAIL]: NotificationPriority.MEDIUM,
      [NotificationChannel.SMS]: NotificationPriority.MEDIUM,
      [NotificationChannel.PUSH]: NotificationPriority.MEDIUM,
      [NotificationChannel.IN_APP]: NotificationPriority.MEDIUM,
      [NotificationChannel.WEB]: NotificationPriority.MEDIUM,
    },
    [NotificationType.PROMOTION]: {
      [NotificationChannel.EMAIL]: NotificationPriority.LOW,
      [NotificationChannel.SMS]: NotificationPriority.LOW,
      [NotificationChannel.PUSH]: NotificationPriority.LOW,
      [NotificationChannel.IN_APP]: NotificationPriority.LOW,
      [NotificationChannel.WEB]: NotificationPriority.LOW,
    },
    [NotificationType.SYSTEM]: {
      [NotificationChannel.EMAIL]: NotificationPriority.HIGH,
      [NotificationChannel.SMS]: NotificationPriority.HIGH,
      [NotificationChannel.PUSH]: NotificationPriority.HIGH,
      [NotificationChannel.IN_APP]: NotificationPriority.HIGH,
      [NotificationChannel.WEB]: NotificationPriority.HIGH,
    },
  };

  return priorityMap[type]?.[channel] || NotificationPriority.MEDIUM;
};

export const isInQuietHours = (
  currentTime: Date,
  quietHoursStart: string,
  quietHoursEnd: string
): boolean => {
  const [startHour, startMinute] = quietHoursStart.split(':').map(Number);
  const [endHour, endMinute] = quietHoursEnd.split(':').map(Number);

  const currentHour = currentTime.getHours();
  const currentMinute = currentTime.getMinutes();

  const currentTimeInMinutes = currentHour * 60 + currentMinute;
  const startTimeInMinutes = startHour * 60 + startMinute;
  const endTimeInMinutes = endHour * 60 + endMinute;

  if (startTimeInMinutes <= endTimeInMinutes) {
    return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes;
  } else {
    // Handle case where quiet hours span midnight
    return currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes <= endTimeInMinutes;
  }
};

export const generateTrackingId = (): string => {
  return `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

export const sanitizePhoneNumber = (phone: string): string => {
  return phone.replace(/[^0-9+]/g, '');
};

export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return text.substr(0, maxLength - 3) + '...';
};

export const getRetryDelay = (attempt: number): number => {
  // Exponential backoff with jitter
  const baseDelay = 1000; // 1 second
  const maxDelay = 30000; // 30 seconds
  const jitter = Math.random() * 1000; // Random jitter up to 1 second
  return Math.min(baseDelay * Math.pow(2, attempt) + jitter, maxDelay);
}; 