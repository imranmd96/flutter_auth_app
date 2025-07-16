# Auth Service

This is the authentication service for the ForkLine application.

## Features
- User registration and login
- JWT token management
- Password hashing and validation
- Session management

## Environment Variables
- `NODE_ENV`: Environment (development/production)
- `PRODUCTION_DOMAIN`: Production domain for the service
- `JWT_SECRET`: Secret key for JWT tokens
- `MONGODB_URI`: MongoDB connection string

## API Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/verify` - Token verification
- `GET /health` - Health check endpoint

## Deployment
This service is deployed using the GitHub Actions CI/CD pipeline to Railway.

## Testing GitHub Actions workflow trigger

# Deployment Test - 2025-07-16 02:13:15
Testing Railway deployment workflow without Slack notifications.
