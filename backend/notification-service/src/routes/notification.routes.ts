import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller';

const router = Router();
const notificationController = new NotificationController();

// Notification routes
router.post('/notifications', notificationController.createNotification.bind(notificationController));
router.get('/notifications', notificationController.getNotifications.bind(notificationController));
router.get('/notifications/:id', notificationController.getNotification.bind(notificationController));
router.patch('/notifications/:id/status', notificationController.updateNotificationStatus.bind(notificationController));
router.delete('/notifications/:id', notificationController.deleteNotification.bind(notificationController));

// Template routes
router.post('/templates', notificationController.createTemplate.bind(notificationController));
router.get('/templates', notificationController.getTemplates.bind(notificationController));
router.get('/templates/:id', notificationController.getTemplate.bind(notificationController));
router.put('/templates/:id', notificationController.updateTemplate.bind(notificationController));
router.delete('/templates/:id', notificationController.deleteTemplate.bind(notificationController));

// Preference routes
router.get('/preferences/:userId', notificationController.getPreferences.bind(notificationController));
router.put('/preferences/:userId', notificationController.updatePreferences.bind(notificationController));

export default router; 