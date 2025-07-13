import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { config } from 'dotenv';
import { errorHandler } from './middleware/error.middleware';
import logger from './utils/logger';
import authRoutes from './routes/auth.routes';
import connectDB from './config/database';
import Redis from 'ioredis';
import { AuthUser } from './models/authUser.model';
console.log('imran. index');
// Load environment variables
config();

// Connect to MongoDB
connectDB();

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(helmet());
app.use(compression());
app.use(express.json({ limit: '50mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true, limit: '50mb' })); // Parse URL-encoded bodies
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Request logging middleware
app.use((req, _res, next) => {
  logger.info(`[${req.method}] ${req.originalUrl} - body:`, req.body);
  next();
});

// Routes
// app.use('/', authRoutes);
app.use(authRoutes);

// Add health endpoint at root level for API Gateway
app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Auth service is running'
  });
});

// Error handling
app.use(errorHandler);

// Start server
app.listen(port, () => {
  logger.success(`
==== AUTH SERVICE STARTED ====
🚀 Service is running!
📡 Port: ${port}
🌍 Environment: ${process.env.NODE_ENV }
📚 API Documentation: http://localhost:${port}/api-docs
============================
API: http://localhost:${port}
`);
});

const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379');

redis.on('message', async (channel: string, message: string) => {
  if (channel === 'user-events') {
    const event = JSON.parse(message);
    if (event.type === 'UserProfileUpdated') {
      const { id, name, email, phone } = event.payload;
      await AuthUser.findByIdAndUpdate(id, { name, email, phone });
    }
    // ... handle other event types
  }
});

