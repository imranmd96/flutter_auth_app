"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const compression_1 = __importDefault(require("compression"));
const dotenv_1 = require("dotenv");
const error_middleware_1 = require("./middleware/error.middleware");
const logger_1 = __importDefault(require("./utils/logger"));
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const database_1 = __importDefault(require("./config/database"));
const ioredis_1 = __importDefault(require("ioredis"));
const authUser_model_1 = require("./models/authUser.model");
console.log('imran. index');
(0, dotenv_1.config)();
(0, database_1.default)();
const app = (0, express_1.default)();
const port = process.env.PORT || 3001;
app.use((0, cors_1.default)());
app.use((0, helmet_1.default)());
app.use((0, compression_1.default)());
app.use(express_1.default.json({ limit: '50mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '50mb' }));
app.use((0, morgan_1.default)('combined', { stream: { write: message => logger_1.default.info(message.trim()) } }));
app.use((req, _res, next) => {
    logger_1.default.info(`[${req.method}] ${req.originalUrl} - body:`, req.body);
    next();
});
app.use(auth_routes_1.default);
app.get('/health', (_req, res) => {
    res.status(200).json({
        status: 'ok',
        message: 'Auth service is running'
    });
});
app.use(error_middleware_1.errorHandler);
app.listen(port, () => {
    logger_1.default.success(`
==== AUTH SERVICE STARTED ====
🚀 Service is running!
📡 Port: ${port}
🌍 Environment: ${process.env.NODE_ENV}
📚 API Documentation: http://localhost:${port}/api-docs
============================
API: http://localhost:${port}
`);
});
const redis = new ioredis_1.default(process.env.REDIS_URL || 'redis://redis:6379');
redis.on('message', async (channel, message) => {
    if (channel === 'user-events') {
        const event = JSON.parse(message);
        if (event.type === 'UserProfileUpdated') {
            const { id, name, email, phone } = event.payload;
            await authUser_model_1.AuthUser.findByIdAndUpdate(id, { name, email, phone });
        }
    }
});
//# sourceMappingURL=index.js.map