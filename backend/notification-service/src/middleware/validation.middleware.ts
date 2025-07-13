import { Request, Response, NextFunction } from 'express';
import { NotificationType, NotificationChannel, NotificationPriority } from '../models/notification';

export const validateNotification = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { type, channel, recipient, content, priority } = req.body;

  const errors: string[] = [];

  if (!type || !Object.values(NotificationType).includes(type)) {
    errors.push('Invalid notification type');
  }

  if (!channel || !Object.values(NotificationChannel).includes(channel)) {
    errors.push('Invalid notification channel');
  }

  if (!recipient || !recipient.id || !recipient.type) {
    errors.push('Invalid recipient information');
  }

  if (!content || !content.title || !content.body) {
    errors.push('Invalid notification content');
  }

  if (priority && !Object.values(NotificationPriority).includes(priority)) {
    errors.push('Invalid notification priority');
  }

  if (errors.length > 0) {
    res.status(400).json({ errors });
    return;
  }

  next();
};

export const validateTemplate = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { name, type, content, variables, channels, language } = req.body;

  const errors: string[] = [];

  if (!name || typeof name !== 'string') {
    errors.push('Invalid template name');
  }

  if (!type || !Object.values(NotificationType).includes(type)) {
    errors.push('Invalid template type');
  }

  if (!content || !content.title || !content.body) {
    errors.push('Invalid template content');
  }

  if (!Array.isArray(variables)) {
    errors.push('Variables must be an array');
  }

  if (!Array.isArray(channels) || channels.some(channel => !Object.values(NotificationChannel).includes(channel))) {
    errors.push('Invalid notification channels');
  }

  if (!language || typeof language !== 'string') {
    errors.push('Invalid language');
  }

  if (errors.length > 0) {
    res.status(400).json({ errors });
    return;
  }

  next();
};

export const validatePreference = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { channels, types, quietHours, language } = req.body;

  const errors: string[] = [];

  if (!Array.isArray(channels) || channels.some(channel => !Object.values(NotificationChannel).includes(channel))) {
    errors.push('Invalid notification channels');
  }

  if (!Array.isArray(types) || types.some(type => !Object.values(NotificationType).includes(type))) {
    errors.push('Invalid notification types');
  }

  if (quietHours) {
    const { start, end } = quietHours;
    if (!start || !end || !isValidTime(start) || !isValidTime(end)) {
      errors.push('Invalid quiet hours');
    }
  }

  if (!language || typeof language !== 'string') {
    errors.push('Invalid language');
  }

  if (errors.length > 0) {
    res.status(400).json({ errors });
    return;
  }

  next();
};

const isValidTime = (time: string): boolean => {
  const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
  return timeRegex.test(time);
}; 