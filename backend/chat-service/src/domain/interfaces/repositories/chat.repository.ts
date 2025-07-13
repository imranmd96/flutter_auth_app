import { Message, ChatRoom, ChatParticipant } from '../../entities/message';

export interface ChatRepository {
    // Message operations
    createMessage(message: Omit<Message, 'id'>): Promise<Message>;
    getMessageById(id: string): Promise<Message | null>;
    getMessagesByRoomId(roomId: string, limit: number, before?: Date): Promise<Message[]>;
    updateMessageStatus(id: string, status: Message['status']): Promise<Message>;
    deleteMessage(id: string): Promise<boolean>;

    // Chat room operations
    createChatRoom(room: Omit<ChatRoom, 'id'>): Promise<ChatRoom>;
    getChatRoomById(id: string): Promise<ChatRoom | null>;
    getChatRoomsByUserId(userId: string): Promise<ChatRoom[]>;
    updateChatRoom(id: string, updates: Partial<ChatRoom>): Promise<ChatRoom>;
    deleteChatRoom(id: string): Promise<boolean>;

    // Participant operations
    addParticipant(roomId: string, participant: ChatParticipant): Promise<ChatParticipant>;
    removeParticipant(roomId: string, userId: string): Promise<boolean>;
    updateParticipantRole(roomId: string, userId: string, role: ChatParticipant['role']): Promise<ChatParticipant>;
    getParticipantsByRoomId(roomId: string): Promise<ChatParticipant[]>;
    updateLastSeen(roomId: string, userId: string): Promise<ChatParticipant>;

    // Search operations
    searchMessages(query: string, roomId: string): Promise<Message[]>;
    searchChatRooms(query: string, userId: string): Promise<ChatRoom[]>;
} 