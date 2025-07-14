"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.redis = exports.connectMongoDB = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const ioredis_1 = __importDefault(require("ioredis"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/review-service';
const REDIS_URI = process.env.REDIS_URI || 'redis://localhost:6379';
// MongoDB connection
const connectMongoDB = async () => {
    try {
        await mongoose_1.default.connect(MONGODB_URI);
        console.log('Connected to MongoDB');
    }
    catch (error) {
        console.error('MongoDB connection error:', error);
        process.exit(1);
    }
};
exports.connectMongoDB = connectMongoDB;
// Redis connection
exports.redis = new ioredis_1.default(REDIS_URI);
exports.redis.on('connect', () => {
    console.log('Connected to Redis');
});
exports.redis.on('error', (error) => {
    console.error('Redis connection error:', error);
});
