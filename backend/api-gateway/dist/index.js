"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
const compression_1 = __importDefault(require("compression"));
const morgan_1 = __importDefault(require("morgan"));
const swagger_ui_express_1 = __importDefault(require("swagger-ui-express"));
const yamljs_1 = __importDefault(require("yamljs"));
const logger_1 = require("./utils/logger");
const error_middleware_1 = require("./middleware/error.middleware");
const routes_1 = __importDefault(require("./routes"));
const logger_utils_1 = require("./utils/logger.utils");
const proxy_config_1 = require("./config/proxy.config");
console.log('Starting API Gateway...');
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
const swaggerDocument = yamljs_1.default.load('./swagger.yaml');
app.use((0, cors_1.default)({
    origin: [
        '*',
        'http://localhost:8081',
        'http://localhost:5000',
        'http://localhost:8000',
        'http://localhost:3000',
        'https://imranmd96.github.io',
        'https://imranmd96.github.io/'
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-API-Source'],
    credentials: true,
    maxAge: 86400,
    preflightContinue: false,
    optionsSuccessStatus: 204
}));
app.use((0, helmet_1.default)({
    crossOriginResourcePolicy: false,
    crossOriginOpenerPolicy: false
}));
app.use(express_1.default.json({ limit: '50mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '50mb' }));
app.use((req, _res, next) => {
    console.log('\n==== REQUEST BODY DEBUG ====');
    console.log('URL:', req.url);
    console.log('Method:', req.method);
    console.log('Content-Type:', req.headers['content-type']);
    console.log('Body (typeof):', typeof req.body);
    console.log('Body (keys):', req.body ? Object.keys(req.body) : 'undefined or null');
    console.log('Body (stringified):', JSON.stringify(req.body));
    console.log('Body (raw):', req.body);
    console.log('==== END REQUEST BODY DEBUG ====\n');
    next();
});
app.use((0, compression_1.default)());
app.use((0, morgan_1.default)('combined', { stream: { write: message => logger_1.logger.info(message.trim()) } }));
app.set('trust proxy', 1);
app.use('/api-docs', swagger_ui_express_1.default.serve, swagger_ui_express_1.default.setup(swaggerDocument));
app.use(routes_1.default);
app.use(error_middleware_1.errorHandler);
app.listen(PORT, () => {
    (0, logger_utils_1.logBoxTable)('API GATEWAY', 'ONLINE', [
        { label: 'Status', value: 'Running' },
        { label: 'Port', value: PORT.toString() },
        { label: 'Environment', value: process.env.NODE_ENV || 'development' }
    ], {
        urlMessage: 'API URL',
        urlValue: `http://localhost:${PORT}`
    });
    (0, proxy_config_1.logProxyConfigurationTable)();
    logger_1.logger.info(`API Gateway is running on port ${PORT}`);
});
//# sourceMappingURL=index.js.map