export interface Message {
    id: string;
    senderId: string;
    receiverId: string;
    content: string;
    type: MessageType;
    status: MessageStatus;
    metadata?: MessageMetadata;
    createdAt: Date;
    updatedAt: Date;
}

export enum MessageType {
    TEXT = 'text',
    IMAGE = 'image',
    FILE = 'file',
    VOICE = 'voice',
    VIDEO = 'video'
}

export enum MessageStatus {
    SENT = 'sent',
    DELIVERED = 'delivered',
    READ = 'read',
    FAILED = 'failed'
}

export interface MessageMetadata {
    fileName?: string;
    fileSize?: number;
    fileType?: string;
    fileUrl?: string;
    thumbnailUrl?: string;
    duration?: number;
    width?: number;
    height?: number;
}

export interface ChatRoom {
    id: string;
    participants: string[];
    type: ChatRoomType;
    name?: string;
    avatar?: string;
    lastMessage?: Message;
    createdAt: Date;
    updatedAt: Date;
}

export enum ChatRoomType {
    DIRECT = 'direct',
    GROUP = 'group'
}

export interface ChatParticipant {
    userId: string;
    role: ParticipantRole;
    joinedAt: Date;
    lastSeen?: Date;
}

export enum ParticipantRole {
    ADMIN = 'admin',
    MEMBER = 'member'
} 