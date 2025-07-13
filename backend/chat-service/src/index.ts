import express from 'express';
import http from 'http';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import { config } from 'dotenv';
import { MongoDBChatRepository } from './infrastructure/persistence/mongodb/chat.repository';
import { ChatService } from './application/services/chat.service';
import { ChatController } from './interfaces/http/controllers/chat.controller';
import { createChatRoutes } from './interfaces/http/routes/chat.routes';
import { WebSocketService } from './infrastructure/websocket/websocket.service';

// Load environment variables
config();

// Create Express app
const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/chat-service')
    .then(() => console.log('Connected to MongoDB'))
    .catch((error) => console.error('MongoDB connection error:', error));

// Initialize components
const chatRepository = new MongoDBChatRepository();
const chatService = new ChatService(chatRepository);
const chatController = new ChatController(chatService);
const webSocketService = new WebSocketService(server, chatService);

// Routes
app.use('/api/chat', createChatRoutes(chatController));

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
const PORT = process.env.PORT || 3003;
server.listen(PORT, () => {
    console.log(`Chat service is running on port ${PORT}`);
}); 