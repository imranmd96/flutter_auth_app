import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { config } from 'dotenv';
import logger from './utils/logger.js';
import userRoutes from './routes/user.routes.js';
import { errorHandler } from './middleware/error.middleware.js';
import chalk from 'chalk';
import { logBoxTable } from './utils/logger.utils.js';
import Redis from 'ioredis';
import { User } from './models/user.model.js';
import mongoose, { Schema } from 'mongoose';

console.log('=== USER SERVICE INDEX.TS STARTED ===');

// Load environment variables
config();

console.log(chalk.blue.bold("user service"));

const app = express();
const port = process.env.PORT || 3015;

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

app.use((req, _res, next) => {
  console.log(chalk.cyan(`[${req.method}]`) + chalk.yellow(` ${req.originalUrl}`) + chalk.dim(' - body:'), 
    chalk.dim(JSON.stringify(req.body)));
  next();
});

// Routes
app.use(userRoutes);

// Health check
console.log(chalk.bgGreenBright.bold('User Service is running'));

app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'success',
    message: 'User Service is running'
  });
});

// Connect to MongoDB, then subscribe to Redis events
// const mongoUri = process.env.MONGODB_URI || 'mongodb://mongodb:27017/forkline';

const mongoUri = process.env.MONGODB_URI || 'mongodb://mongodb:27017/user-service';

const userSchema = new Schema({
  _id: { type: Schema.Types.ObjectId, required: true }, // Accepts external IDs
  // ...other fields
});

mongoose.connect(mongoUri)
  .then(() => {
    console.log(chalk.green('MongoDB connected'));
    // Redis subscription logic
    const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379');
    redis.subscribe('user-events', (err, count) => {
      if (err) {
        console.error('Failed to subscribe to user-events:', err.message);
      } else {
        console.log(`Subscribed to user-events. Channel count: ${count}`);
      }
    });
    redis.on('message', async (channel, message) => {
      if (channel === 'user-events') {
          const event = JSON.parse(message);
          if (event.type === 'UserRegistered') {
            const { id, name, email, phone } = event.payload;
          // Only create if not exists
            const existing = await User.findOne({ email });
            if (!existing) {
              await User.create({
              _id: id, // Use the ID from auth-service!
                name,
                email,
                phone,
              password: 'changeme', // Placeholder, not used for auth here
              });
            }
        } else if (event.type === 'UserProfileUpdated') {
          const { id, name, email, phone } = event.payload;
          await User.findByIdAndUpdate(id, { name, email, phone });
          } else {
            console.log(`[EVENT] Ignored event type: ${event.type}`);
        }
      }
    });
    // Start server only after DB and Redis are ready
    // Serve static files for uploaded images
    app.use('/uploads', express.static('uploads'));
    console.log(chalk.green('Static file serving enabled for /uploads'));
    app.use(errorHandler);
    app.listen(port, () => {
      logBoxTable(
        'USER SERVICE',
        'RUNNING',
        [
          { label: 'Port', value: port.toString() },
          { label: 'Environment', value: process.env.NODE_ENV || 'development' }
        ],
        {
          urlMessage: 'API URL',
          urlValue: `http://localhost:${port}`
        }
      );
    });
  })
  .catch((err) => {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1);
  }); 