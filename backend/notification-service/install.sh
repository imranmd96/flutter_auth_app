#!/bin/bash

# Create necessary directories
mkdir -p logs
mkdir -p src/tests

# Install production dependencies
npm install express \
  @types/express \
  mongoose \
  @types/mongoose \
  ioredis \
  @types/ioredis \
  @sendgrid/mail \
  twilio \
  firebase-admin \
  ws \
  @types/ws \
  jsonwebtoken \
  @types/jsonwebtoken \
  winston \
  @types/winston \
  dotenv \
  cors \
  @types/cors \
  helmet \
  @types/helmet \
  rate-limiter-flexible \
  morgan \
  @types/morgan

# Install development dependencies
npm install --save-dev typescript \
  @types/node \
  ts-node \
  nodemon \
  jest \
  @types/jest \
  ts-jest \
  supertest \
  @types/supertest \
  eslint \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  prettier \
  eslint-config-prettier \
  eslint-plugin-prettier

# Create TypeScript configuration
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "es2018",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "sourceMap": true,
    "declaration": true,
    "lib": ["es2018", "dom"],
    "types": ["node", "jest"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOL

# Create ESLint configuration
cat > .eslintrc.json << EOL
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "parserOptions": {
    "ecmaVersion": 2018,
    "sourceType": "module"
  },
  "rules": {
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }]
  }
}
EOL

# Create Prettier configuration
cat > .prettierrc << EOL
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOL

# Create Jest configuration
cat > jest.config.js << EOL
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.test.ts'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest'
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
EOL

# Create .gitignore
cat > .gitignore << EOL
# Dependencies
node_modules/

# Build output
dist/

# Logs
logs/
*.log
npm-debug.log*

# Environment variables
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# Testing
coverage/

# OS
.DS_Store
Thumbs.db
EOL

# Create .env.example
cat > .env.example << EOL
# Server Configuration
PORT=3006
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/notification-service?retryWrites=true&w=majority
MONGODB_USER=
MONGODB_PASSWORD=

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# SendGrid Configuration
SENDGRID_API_KEY=
SENDGRID_FROM_EMAIL=noreply@forkline.com
SENDGRID_FROM_NAME=ForkLine

# Twilio Configuration
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# Firebase Configuration
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# JWT Configuration
JWT_SECRET=
JWT_EXPIRATION=1h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
LOG_FORMAT=combined

# CORS
CORS_ORIGIN=http://localhost:3000

# WebSocket
WS_PATH=/ws
WS_HEARTBEAT_INTERVAL=30000
EOL

# Make the script executable
chmod +x install.sh

echo "Installation completed successfully!" 