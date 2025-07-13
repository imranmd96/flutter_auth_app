import { Server } from 'socket.io';
import { Server as HttpServer } from 'http';
import { ChatService } from '../../application/services/chat.service';
import { Message, MessageStatus } from '../../domain/entities/message';

export class WebSocketService {
    private io: Server;
    private userSockets: Map<string, string> = new Map(); // userId -> socketId

    constructor(
        private readonly httpServer: HttpServer,
        private readonly chatService: ChatService
    ) {
        this.io = new Server(httpServer, {
            cors: {
                origin: process.env.CORS_ORIGIN || '*',
                methods: ['GET', 'POST']
            }
        });

        this.setupSocketHandlers();
    }

    private setupSocketHandlers() {
        this.io.on('connection', (socket) => {
            console.log(`Client connected: ${socket.id}`);

            // Handle user authentication
            socket.on('authenticate', (userId: string) => {
                this.userSockets.set(userId, socket.id);
                socket.join(`user:${userId}`);
                console.log(`User ${userId} authenticated`);
            });

            // Handle joining chat room
            socket.on('join_room', (roomId: string) => {
                socket.join(`room:${roomId}`);
                console.log(`Socket ${socket.id} joined room ${roomId}`);
            });

            // Handle leaving chat room
            socket.on('leave_room', (roomId: string) => {
                socket.leave(`room:${roomId}`);
                console.log(`Socket ${socket.id} left room ${roomId}`);
            });

            // Handle new message
            socket.on('send_message', async (data: {
                senderId: string;
                receiverId: string;
                content: string;
                type: Message['type'];
                metadata?: Message['metadata'];
            }) => {
                try {
                    const message = await this.chatService.sendMessage(
                        data.senderId,
                        data.receiverId,
                        data.content,
                        data.type,
                        data.metadata
                    );

                    // Emit to sender
                    this.io.to(`user:${data.senderId}`).emit('message_sent', message);

                    // Emit to receiver
                    this.io.to(`user:${data.receiverId}`).emit('new_message', message);

                    // Update message status to delivered
                    const deliveredMessage = await this.chatService.markMessageAsRead(message.id);
                    this.io.to(`user:${data.senderId}`).emit('message_delivered', deliveredMessage);
                } catch (error) {
                    console.error('Error sending message:', error);
                    socket.emit('error', { message: 'Failed to send message' });
                }
            });

            // Handle message read status
            socket.on('mark_as_read', async (messageId: string) => {
                try {
                    const message = await this.chatService.markMessageAsRead(messageId);
                    this.io.to(`user:${message.senderId}`).emit('message_read', message);
                } catch (error) {
                    console.error('Error marking message as read:', error);
                    socket.emit('error', { message: 'Failed to mark message as read' });
                }
            });

            // Handle typing status
            socket.on('typing', (data: { roomId: string; userId: string; isTyping: boolean }) => {
                socket.to(`room:${data.roomId}`).emit('user_typing', {
                    userId: data.userId,
                    isTyping: data.isTyping
                });
            });

            // Handle online status
            socket.on('online_status', (data: { userId: string; isOnline: boolean }) => {
                this.io.emit('user_status', {
                    userId: data.userId,
                    isOnline: data.isOnline
                });
            });

            // Handle disconnection
            socket.on('disconnect', () => {
                const userId = Array.from(this.userSockets.entries())
                    .find(([_, socketId]) => socketId === socket.id)?.[0];

                if (userId) {
                    this.userSockets.delete(userId);
                    this.io.emit('user_status', {
                        userId,
                        isOnline: false
                    });
                }

                console.log(`Client disconnected: ${socket.id}`);
            });
        });
    }

    // Utility methods
    public getConnectedUsers(): string[] {
        return Array.from(this.userSockets.keys());
    }

    public isUserOnline(userId: string): boolean {
        return this.userSockets.has(userId);
    }

    public getUserSocketId(userId: string): string | undefined {
        return this.userSockets.get(userId);
    }
} 