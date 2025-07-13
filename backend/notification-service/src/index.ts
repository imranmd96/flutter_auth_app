import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import mongoose from 'mongoose';
import Redis from 'redis';
import chalk from 'chalk';

// Load environment variables
dotenv.config();

console.log(chalk.yellow.bold("notification service"));

// Create Express app
const app = express();
const port = process.env.PORT || 3009;

// Create HTTP server
const server = createServer(app);

// Create WebSocket server
const wss = new WebSocketServer({ server });

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose
  .connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/forkline-notification-service')
  .then(() => {
    console.log(chalk.green('✓ Connected to MongoDB'));
  })
  .catch((error) => {
    console.error(chalk.red.bold('✗ MongoDB connection error:'), chalk.red(error.message));
    process.exit(1);
  });

// Create Redis client
const redisClient = Redis.createClient({
  url: process.env.REDIS_URI || 'redis://localhost:6379'
});

redisClient.on('error', (error) => {
  console.error(chalk.red.bold('✗ Redis connection error:'), chalk.red(error.message));
  process.exit(1);
});

redisClient.on('connect', () => {
  console.log(chalk.green('✓ Connected to Redis'));
});

// WebSocket connection handling
wss.on('connection', (ws) => {
  console.log(chalk.blue('➕ New WebSocket connection'));

  ws.on('message', (message) => {
    console.log(chalk.blue('📨 Received message:'), chalk.cyan(message.toString()));
  });

  ws.on('close', () => {
    console.log(chalk.blue('➖ Client disconnected'));
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
server.listen(port, () => {
  console.log(chalk.yellow.bold(`
==== NOTIFICATION SERVICE STARTED ====`));
  console.log(chalk.green.bold(`🚀 Service is running!`));
  console.log(chalk.blue.bold(`📡 Port: `) + chalk.cyan.bold(`${port}`));
  console.log(chalk.magenta.bold(`🌍 Environment: `) + chalk.cyan.bold(`${process.env.NODE_ENV || 'development'}`));
  console.log(chalk.red.bold(`📚 API Documentation: `) + chalk.cyan.bold(`http://localhost:${port}/api-docs`));
  console.log(chalk.yellow.bold(`============================`));

  // Log the URL in a different color
  console.log(chalk.bgCyan.black.bold(` API: http://localhost:${port} `));
});

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log(chalk.yellow.bold('⚠️ SIGTERM received. Shutting down gracefully...'));
  
  // Close MongoDB connection
  await mongoose.connection.close();
  console.log(chalk.green('✓ MongoDB connection closed'));
  
  // Close Redis connection
  await redisClient.quit();
  console.log(chalk.green('✓ Redis connection closed'));
  
  // Close WebSocket server
  wss.close(() => {
    console.log(chalk.green('✓ WebSocket server closed'));
    process.exit(0);
  });
}); 