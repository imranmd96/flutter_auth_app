import { Router } from 'express';
import { ChatController } from '../controllers/chat.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

export function createChatRoutes(chatController: ChatController): Router {
    const router = Router();

    // Apply authentication middleware to all routes
    router.use(authMiddleware);

    // Message routes
    router.post('/messages', chatController.sendMessage.bind(chatController));
    router.get('/rooms/:roomId/messages', chatController.getMessageHistory.bind(chatController));
    router.patch('/messages/:messageId/read', chatController.markMessageAsRead.bind(chatController));
    router.delete('/messages/:messageId', chatController.deleteMessage.bind(chatController));

    // Chat room routes
    router.post('/rooms/direct', chatController.createDirectChat.bind(chatController));
    router.post('/rooms/group', chatController.createGroupChat.bind(chatController));
    router.get('/users/:userId/rooms', chatController.getChatRooms.bind(chatController));
    router.patch('/rooms/:roomId', chatController.updateChatRoom.bind(chatController));

    // Participant routes
    router.post('/rooms/:roomId/participants', chatController.addParticipantToGroup.bind(chatController));
    router.delete('/rooms/:roomId/participants/:userId', chatController.removeParticipantFromGroup.bind(chatController));
    router.patch('/rooms/:roomId/participants/:userId/role', chatController.updateParticipantRole.bind(chatController));

    // Search routes
    router.get('/rooms/:roomId/messages/search', chatController.searchMessages.bind(chatController));
    router.get('/users/:userId/rooms/search', chatController.searchChatRooms.bind(chatController));

    return router;
} 