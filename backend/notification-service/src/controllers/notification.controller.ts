import { Request, Response } from 'express';
import { NotificationService } from '../services/notification.service';
import { Notification } from '../models/notification';

export class NotificationController {
  private notificationService: NotificationService;

  constructor() {
    this.notificationService = new NotificationService();
  }

  async sendNotification(req: Request, res: Response): Promise<void> {
    try {
      const notification = new Notification(req.body);
      await notification.save();

      this.notificationService.sendNotification(notification).catch(error => {
        console.error('Error sending notification:', error);
      });

      res.status(201).json(notification);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      res.status(400).json({ error: errorMessage });
    }
  }

  async getNotifications(req: Request, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const notifications = await Notification.find({ userId });
      res.json(notifications);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      res.status(500).json({ error: errorMessage });
    }
  }

  async updateNotification(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const notification = await Notification.findByIdAndUpdate(id, req.body, { new: true });
      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }
      res.json(notification);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      res.status(500).json({ error: errorMessage });
    }
  }

  async deleteNotification(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const notification = await Notification.findByIdAndDelete(id);
      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }
      res.json({ message: 'Notification deleted successfully' });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      res.status(500).json({ error: errorMessage });
    }
  }

  async markAsRead(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const notification = await Notification.findByIdAndUpdate(
        id,
        { isRead: true },
        { new: true }
      );
      if (!notification) {
        res.status(404).json({ error: 'Notification not found' });
        return;
      }
      res.json(notification);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      res.status(500).json({ error: errorMessage });
    }
  }
} 