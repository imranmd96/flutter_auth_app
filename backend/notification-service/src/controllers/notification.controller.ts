import { Request, Response } from 'express';
import { Notification, NotificationStatus } from '../models/notification';
import { Template } from '../models/template';
import { Preference } from '../models/preference';
import { NotificationService } from '../services/notification.service';

export class NotificationController {
  private notificationService: NotificationService;

  constructor() {
    this.notificationService = new NotificationService();
  }

  async createNotification(req: Request, res: Response): Promise<void> {
    try {
      const notification = new Notification(req.body);
      await notification.save();

      // Send notification asynchronously
      this.notificationService.sendNotification(notification).catch(error => {
        console.error('Error sending notification:', error);
      });

      res.status(201).json(notification);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getNotifications(req: Request, res: Response): Promise<void> {
    try {
      const { userId, type, status, page = 1, limit = 10 } = req.query;
      const query: any = {};

      if (userId) query['recipient.id'] = userId;
      if (type) query.type = type;
      if (status) query.status = status;

      const notifications = await Notification.find(query)
        .sort({ createdAt: -1 })
        .skip((Number(page) - 1) * Number(limit))
        .limit(Number(limit));

      const total = await Notification.countDocuments(query);

      res.json({
        notifications,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          pages: Math.ceil(total / Number(limit))
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getNotification(req: Request, res: Response): Promise<void> {
    try {
      const notification = await Notification.findById(req.params.id);
      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }
      res.json(notification);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async updateNotificationStatus(req: Request, res: Response): Promise<void> {
    try {
      const { status } = req.body;
      const notification = await Notification.findByIdAndUpdate(
        req.params.id,
        { status, updatedAt: new Date() },
        { new: true }
      );

      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }

      res.json(notification);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async deleteNotification(req: Request, res: Response): Promise<void> {
    try {
      const notification = await Notification.findByIdAndDelete(req.params.id);
      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async createTemplate(req: Request, res: Response): Promise<void> {
    try {
      const template = new Template(req.body);
      await template.save();
      res.status(201).json(template);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getTemplates(req: Request, res: Response): Promise<void> {
    try {
      const { type, language, isActive } = req.query;
      const query: any = {};

      if (type) query.type = type;
      if (language) query.language = language;
      if (isActive !== undefined) query.isActive = isActive;

      const templates = await Template.find(query);
      res.json(templates);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getTemplate(req: Request, res: Response): Promise<void> {
    try {
      const template = await Template.findById(req.params.id);
      if (!template) {
        res.status(404).json({ error: 'Template not found' });
        return;
      }
      res.json(template);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async updateTemplate(req: Request, res: Response): Promise<void> {
    try {
      const template = await Template.findByIdAndUpdate(
        req.params.id,
        { ...req.body, updatedAt: new Date() },
        { new: true }
      );

      if (!template) {
        res.status(404).json({ error: 'Template not found' });
        return;
      }

      res.json(template);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async deleteTemplate(req: Request, res: Response): Promise<void> {
    try {
      const template = await Template.findByIdAndDelete(req.params.id);
      if (!template) {
        res.status(404).json({ error: 'Template not found' });
        return;
      }
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getPreferences(req: Request, res: Response): Promise<void> {
    try {
      const preference = await Preference.findOne({ userId: req.params.userId });
      if (!preference) {
        res.status(404).json({ error: 'Preferences not found' });
        return;
      }
      res.json(preference);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async updatePreferences(req: Request, res: Response): Promise<void> {
    try {
      const preference = await Preference.findOneAndUpdate(
        { userId: req.params.userId },
        { ...req.body, updatedAt: new Date() },
        { new: true, upsert: true }
      );
      res.json(preference);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
} 