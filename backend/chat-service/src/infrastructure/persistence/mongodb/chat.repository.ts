import { ChatRepository } from '../../../domain/interfaces/repositories/chat.repository';
import { Message, ChatRoom, ChatParticipant, MessageStatus, ParticipantRole } from '../../../domain/entities/message';
import mongoose, { Model, Schema } from 'mongoose';

// Message Schema
const MessageSchema = new Schema<Message>({
    senderId: { type: String, required: true },
    receiverId: { type: String, required: true },
    content: { type: String, required: true },
    type: { type: String, required: true },
    status: { type: String, required: true },
    metadata: { type: Schema.Types.Mixed },
    createdAt: { type: Date, required: true },
    updatedAt: { type: Date, required: true }
});

// ChatRoom Schema
const ChatRoomSchema = new Schema<ChatRoom>({
    participants: [{ type: String, required: true }],
    type: { type: String, required: true },
    name: { type: String },
    avatar: { type: String },
    lastMessage: { type: MessageSchema },
    createdAt: { type: Date, required: true },
    updatedAt: { type: Date, required: true }
});

// ChatParticipant Schema
const ChatParticipantSchema = new Schema<ChatParticipant>({
    userId: { type: String, required: true },
    role: { type: String, required: true },
    joinedAt: { type: Date, required: true },
    lastSeen: { type: Date }
});

export class MongoDBChatRepository implements ChatRepository {
    private messageModel: Model<Message>;
    private chatRoomModel: Model<ChatRoom>;
    private participantModel: Model<ChatParticipant>;

    constructor() {
        this.messageModel = mongoose.model<Message>('Message', MessageSchema);
        this.chatRoomModel = mongoose.model<ChatRoom>('ChatRoom', ChatRoomSchema);
        this.participantModel = mongoose.model<ChatParticipant>('ChatParticipant', ChatParticipantSchema);
    }

    // Message operations
    async createMessage(message: Omit<Message, 'id'>): Promise<Message> {
        const newMessage = new this.messageModel(message);
        return newMessage.save();
    }

    async getMessageById(id: string): Promise<Message | null> {
        return this.messageModel.findById(id).exec();
    }

    async getMessagesByRoomId(roomId: string, limit: number, before?: Date): Promise<Message[]> {
        const query = before
            ? { receiverId: roomId, createdAt: { $lt: before } }
            : { receiverId: roomId };
        
        return this.messageModel
            .find(query)
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    async updateMessageStatus(id: string, status: MessageStatus): Promise<Message> {
        const updatedMessage = await this.messageModel
            .findByIdAndUpdate(id, { status, updatedAt: new Date() }, { new: true })
            .exec();
        
        if (!updatedMessage) {
            throw new Error(`Message with id ${id} not found`);
        }
        
        return updatedMessage;
    }

    async deleteMessage(id: string): Promise<boolean> {
        const result = await this.messageModel.deleteOne({ _id: id }).exec();
        return result.deletedCount > 0;
    }

    // Chat room operations
    async createChatRoom(room: Omit<ChatRoom, 'id'>): Promise<ChatRoom> {
        const newRoom = new this.chatRoomModel(room);
        return newRoom.save();
    }

    async getChatRoomById(id: string): Promise<ChatRoom | null> {
        return this.chatRoomModel.findById(id).exec();
    }

    async getChatRoomsByUserId(userId: string): Promise<ChatRoom[]> {
        return this.chatRoomModel
            .find({ participants: userId })
            .sort({ updatedAt: -1 })
            .exec();
    }

    async updateChatRoom(id: string, updates: Partial<ChatRoom>): Promise<ChatRoom> {
        const updatedRoom = await this.chatRoomModel
            .findByIdAndUpdate(id, { ...updates, updatedAt: new Date() }, { new: true })
            .exec();
        
        if (!updatedRoom) {
            throw new Error(`Chat room with id ${id} not found`);
        }
        
        return updatedRoom;
    }

    async deleteChatRoom(id: string): Promise<boolean> {
        const result = await this.chatRoomModel.deleteOne({ _id: id }).exec();
        return result.deletedCount > 0;
    }

    // Participant operations
    async addParticipant(roomId: string, participant: ChatParticipant): Promise<ChatParticipant> {
        const newParticipant = new this.participantModel({
            ...participant,
            roomId
        });
        return newParticipant.save();
    }

    async removeParticipant(roomId: string, userId: string): Promise<boolean> {
        const result = await this.participantModel
            .deleteOne({ roomId, userId })
            .exec();
        return result.deletedCount > 0;
    }

    async updateParticipantRole(roomId: string, userId: string, role: ParticipantRole): Promise<ChatParticipant> {
        const updatedParticipant = await this.participantModel
            .findOneAndUpdate(
                { roomId, userId },
                { role },
                { new: true }
            )
            .exec();
        
        if (!updatedParticipant) {
            throw new Error(`Participant not found in room ${roomId}`);
        }
        
        return updatedParticipant;
    }

    async getParticipantsByRoomId(roomId: string): Promise<ChatParticipant[]> {
        return this.participantModel
            .find({ roomId })
            .sort({ joinedAt: 1 })
            .exec();
    }

    async updateLastSeen(roomId: string, userId: string): Promise<ChatParticipant> {
        const updatedParticipant = await this.participantModel
            .findOneAndUpdate(
                { roomId, userId },
                { lastSeen: new Date() },
                { new: true }
            )
            .exec();
        
        if (!updatedParticipant) {
            throw new Error(`Participant not found in room ${roomId}`);
        }
        
        return updatedParticipant;
    }

    // Search operations
    async searchMessages(query: string, roomId: string): Promise<Message[]> {
        return this.messageModel
            .find({
                receiverId: roomId,
                content: { $regex: query, $options: 'i' }
            })
            .sort({ createdAt: -1 })
            .exec();
    }

    async searchChatRooms(query: string, userId: string): Promise<ChatRoom[]> {
        return this.chatRoomModel
            .find({
                participants: userId,
                $or: [
                    { name: { $regex: query, $options: 'i' } },
                    { 'lastMessage.content': { $regex: query, $options: 'i' } }
                ]
            })
            .sort({ updatedAt: -1 })
            .exec();
    }
} 