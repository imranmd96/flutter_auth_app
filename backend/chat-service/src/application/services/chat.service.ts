import { ChatRepository } from '../../domain/interfaces/repositories/chat.repository';
import { Message, ChatRoom, ChatParticipant, MessageStatus, ParticipantRole, ChatRoomType } from '../../domain/entities/message';
import { v4 as uuidv4 } from 'uuid';

export class ChatService {
    constructor(private readonly chatRepository: ChatRepository) {}

    // Message operations
    async sendMessage(senderId: string, receiverId: string, content: string, type: Message['type'], metadata?: Message['metadata']): Promise<Message> {
        const message: Omit<Message, 'id'> = {
            senderId,
            receiverId,
            content,
            type,
            status: MessageStatus.SENT,
            metadata,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        return this.chatRepository.createMessage(message);
    }

    async getMessageHistory(roomId: string, limit: number = 50, before?: Date): Promise<Message[]> {
        return this.chatRepository.getMessagesByRoomId(roomId, limit, before);
    }

    async markMessageAsRead(messageId: string): Promise<Message> {
        return this.chatRepository.updateMessageStatus(messageId, MessageStatus.READ);
    }

    async deleteMessage(messageId: string): Promise<boolean> {
        return this.chatRepository.deleteMessage(messageId);
    }

    // Chat room operations
    async createDirectChat(userId1: string, userId2: string): Promise<ChatRoom> {
        const room: Omit<ChatRoom, 'id'> = {
            participants: [userId1, userId2],
            type: ChatRoomType.DIRECT,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        return this.chatRepository.createChatRoom(room);
    }

    async createGroupChat(name: string, participants: string[], creatorId: string): Promise<ChatRoom> {
        const room: Omit<ChatRoom, 'id'> = {
            name,
            participants,
            type: ChatRoomType.GROUP,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const createdRoom = await this.chatRepository.createChatRoom(room);
        
        // Add creator as admin
        await this.chatRepository.addParticipant(createdRoom.id, {
            userId: creatorId,
            role: ParticipantRole.ADMIN,
            joinedAt: new Date()
        });

        return createdRoom;
    }

    async getChatRooms(userId: string): Promise<ChatRoom[]> {
        return this.chatRepository.getChatRoomsByUserId(userId);
    }

    async updateChatRoom(roomId: string, updates: Partial<ChatRoom>): Promise<ChatRoom> {
        return this.chatRepository.updateChatRoom(roomId, {
            ...updates,
            updatedAt: new Date()
        });
    }

    // Participant operations
    async addParticipantToGroup(roomId: string, userId: string): Promise<ChatParticipant> {
        const participant: ChatParticipant = {
            userId,
            role: ParticipantRole.MEMBER,
            joinedAt: new Date()
        };

        return this.chatRepository.addParticipant(roomId, participant);
    }

    async removeParticipantFromGroup(roomId: string, userId: string): Promise<boolean> {
        return this.chatRepository.removeParticipant(roomId, userId);
    }

    async updateParticipantRole(roomId: string, userId: string, role: ParticipantRole): Promise<ChatParticipant> {
        return this.chatRepository.updateParticipantRole(roomId, userId, role);
    }

    async updateLastSeen(roomId: string, userId: string): Promise<ChatParticipant> {
        return this.chatRepository.updateLastSeen(roomId, userId);
    }

    // Search operations
    async searchMessages(query: string, roomId: string): Promise<Message[]> {
        return this.chatRepository.searchMessages(query, roomId);
    }

    async searchChatRooms(query: string, userId: string): Promise<ChatRoom[]> {
        return this.chatRepository.searchChatRooms(query, userId);
    }
} 