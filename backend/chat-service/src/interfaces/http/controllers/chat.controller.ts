import { Request, Response } from 'express';
import { ChatService } from '../../../application/services/chat.service';
import { Message, ChatRoom, ChatParticipant, MessageType, ParticipantRole } from '../../../domain/entities/message';

export class ChatController {
    constructor(private readonly chatService: ChatService) {}

    // Message endpoints
    async sendMessage(req: Request, res: Response) {
        try {
            const { senderId, receiverId, content, type, metadata } = req.body;
            const message = await this.chatService.sendMessage(
                senderId,
                receiverId,
                content,
                type as MessageType,
                metadata
            );
            res.status(201).json(message);
        } catch (error) {
            res.status(500).json({ error: 'Failed to send message' });
        }
    }

    async getMessageHistory(req: Request, res: Response) {
        try {
            const { roomId } = req.params;
            const { limit, before } = req.query;
            const messages = await this.chatService.getMessageHistory(
                roomId,
                Number(limit) || 50,
                before ? new Date(before as string) : undefined
            );
            res.json(messages);
        } catch (error) {
            res.status(500).json({ error: 'Failed to get message history' });
        }
    }

    async markMessageAsRead(req: Request, res: Response) {
        try {
            const { messageId } = req.params;
            const message = await this.chatService.markMessageAsRead(messageId);
            res.json(message);
        } catch (error) {
            res.status(500).json({ error: 'Failed to mark message as read' });
        }
    }

    async deleteMessage(req: Request, res: Response) {
        try {
            const { messageId } = req.params;
            const success = await this.chatService.deleteMessage(messageId);
            if (success) {
                res.status(204).send();
            } else {
                res.status(404).json({ error: 'Message not found' });
            }
        } catch (error) {
            res.status(500).json({ error: 'Failed to delete message' });
        }
    }

    // Chat room endpoints
    async createDirectChat(req: Request, res: Response) {
        try {
            const { userId1, userId2 } = req.body;
            const room = await this.chatService.createDirectChat(userId1, userId2);
            res.status(201).json(room);
        } catch (error) {
            res.status(500).json({ error: 'Failed to create direct chat' });
        }
    }

    async createGroupChat(req: Request, res: Response) {
        try {
            const { name, participants, creatorId } = req.body;
            const room = await this.chatService.createGroupChat(name, participants, creatorId);
            res.status(201).json(room);
        } catch (error) {
            res.status(500).json({ error: 'Failed to create group chat' });
        }
    }

    async getChatRooms(req: Request, res: Response) {
        try {
            const { userId } = req.params;
            const rooms = await this.chatService.getChatRooms(userId);
            res.json(rooms);
        } catch (error) {
            res.status(500).json({ error: 'Failed to get chat rooms' });
        }
    }

    async updateChatRoom(req: Request, res: Response) {
        try {
            const { roomId } = req.params;
            const updates = req.body;
            const room = await this.chatService.updateChatRoom(roomId, updates);
            res.json(room);
        } catch (error) {
            res.status(500).json({ error: 'Failed to update chat room' });
        }
    }

    // Participant endpoints
    async addParticipantToGroup(req: Request, res: Response) {
        try {
            const { roomId } = req.params;
            const { userId } = req.body;
            const participant = await this.chatService.addParticipantToGroup(roomId, userId);
            res.status(201).json(participant);
        } catch (error) {
            res.status(500).json({ error: 'Failed to add participant' });
        }
    }

    async removeParticipantFromGroup(req: Request, res: Response) {
        try {
            const { roomId, userId } = req.params;
            const success = await this.chatService.removeParticipantFromGroup(roomId, userId);
            if (success) {
                res.status(204).send();
            } else {
                res.status(404).json({ error: 'Participant not found' });
            }
        } catch (error) {
            res.status(500).json({ error: 'Failed to remove participant' });
        }
    }

    async updateParticipantRole(req: Request, res: Response) {
        try {
            const { roomId, userId } = req.params;
            const { role } = req.body;
            const participant = await this.chatService.updateParticipantRole(
                roomId,
                userId,
                role as ParticipantRole
            );
            res.json(participant);
        } catch (error) {
            res.status(500).json({ error: 'Failed to update participant role' });
        }
    }

    // Search endpoints
    async searchMessages(req: Request, res: Response) {
        try {
            const { roomId } = req.params;
            const { query } = req.query;
            const messages = await this.chatService.searchMessages(query as string, roomId);
            res.json(messages);
        } catch (error) {
            res.status(500).json({ error: 'Failed to search messages' });
        }
    }

    async searchChatRooms(req: Request, res: Response) {
        try {
            const { userId } = req.params;
            const { query } = req.query;
            const rooms = await this.chatService.searchChatRooms(query as string, userId);
            res.json(rooms);
        } catch (error) {
            res.status(500).json({ error: 'Failed to search chat rooms' });
        }
    }
} 