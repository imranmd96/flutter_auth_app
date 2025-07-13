import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import compression from 'compression';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/error.middleware';
import router from './routes';
import { logBoxTable } from './utils/logger.utils';
import { logProxyConfigurationTable } from './config/proxy.config';
// Extend the Express Request interface
declare global {
  namespace Express {
    interface Request {
      rawBody?: string;
    }
  }
}

console.log('Starting API Gateway...');

//Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Load Swagger document
const swaggerDocument = YAML.load('./swagger.yaml');

// Middleware
app.use(cors({
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

// Remove helmet's default CORS policy
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginOpenerPolicy: false
}));

// Simplified middleware stack - remove raw body parsing that's causing issues
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Log all request bodies for debugging
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

app.use(compression());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Trust proxy - important for forwarded headers from nginx
app.set('trust proxy', 1);

// Swagger documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Main router (MVC: all routes and proxy logic are handled in src/routes/index.ts)
app.use(router);

// Error handling middleware
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  // Use our new utility function for logging
  logBoxTable(
    'API GATEWAY',
    'ONLINE',
    [
      { label: 'Status', value: 'Running' },
      { label: 'Port', value: PORT.toString() },
      { label: 'Environment', value: process.env.NODE_ENV || 'development' }
    ],
    {
      urlMessage: 'API URL',
      urlValue: `http://localhost:${PORT}`
    }
  );
  
  // Display the proxy configuration table
  logProxyConfigurationTable();
  
  logger.info(`API Gateway is running on port ${PORT}`);
});

// Note: All proxy and route logic is now in src/routes/index.ts (MVC separation)




