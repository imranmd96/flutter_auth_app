import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller';

const router = Router();
const notificationController = new NotificationController();

// Notification routes
router.post('/notifications', notificationController.sendNotification.bind(notificationController));
router.get('/notifications/:userId', notificationController.getNotifications.bind(notificationController));
router.put('/notifications/:id', notificationController.updateNotification.bind(notificationController));
router.patch('/notifications/:id/read', notificationController.markAsRead.bind(notificationController));
router.delete('/notifications/:id', notificationController.deleteNotification.bind(notificationController));

export default router; 