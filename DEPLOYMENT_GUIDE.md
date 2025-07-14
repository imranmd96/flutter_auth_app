# 🚀 ForkLine Backend Cloud Deployment Guide

This guide will help you deploy the complete ForkLine restaurant management system backend to the cloud with automated CI/CD.

## 📋 Prerequisites

### Required Accounts
- [x] **GitHub Account** - For code repository and GitHub Actions
- [x] **Railway Account** - For Node.js services (Core services)
- [x] **Render Account** - For Python/Go services (Additional services)
- [x] **MongoDB Atlas** - For database hosting (Free tier available)
- [x] **Redis Cloud** - For caching and sessions (Free tier available)

### Required Tools
```bash
# Install required CLI tools
curl -fsSL https://railway.app/install.sh | sh  # Railway CLI
npm install -g @render/cli                      # Render CLI
```

## 🏗️ Architecture Overview

### Service Distribution
- **Railway (Node.js Services)**:
  - API Gateway (Port 3000) - Main entry point
  - Auth Service (Port 3001) - Authentication & JWT
  - User Service (Port 3015) - User management
  - Chat Service (Port 3016) - Real-time messaging
  - Notification Service (Port 3018) - Push notifications
  - Review Service (Port 3019) - Ratings & feedback

- **Render (Python/Go/Java Services)**:
  - Restaurant Service (Python/FastAPI) - Restaurant CRUD
  - Menu Service (Python/FastAPI) - Menu management
  - Booking Service (Go) - Reservations
  - Order Service (Java/Spring Boot) - Order processing
  - Payment Service (Node.js) - Payment processing
  - Analytics Service (Python/FastAPI) - Reporting
  - Inventory Service (Python/FastAPI) - Stock management
  - Search Service (Python/FastAPI) - Search functionality
  - Geolocation Service (Go) - Location services
  - Media Service (Python/FastAPI) - File uploads

## 🚀 Quick Start Deployment

### 1. One-Command Deployment
```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh production
```

### 2. Manual Step-by-Step Deployment

#### Step 1: Database Setup

**MongoDB Atlas Setup:**
1. Go to [MongoDB Atlas](https://cloud.mongodb.com/)
2. Create a new project: "ForkLine"
3. Create a free M0 cluster
4. Create database user:
   - Username: `forkline_user`
   - Password: (generate strong password)
5. Add IP whitelist: `0.0.0.0/0` (for production, restrict to your servers)
6. Get connection string: `mongodb+srv://forkline_user:<password>@cluster0.xxxxx.mongodb.net/forkline`

**Redis Cloud Setup:**
1. Go to [Redis Cloud](https://redis.com/try-free/)
2. Create a free database
3. Get connection string: `redis://username:password@host:port`

#### Step 2: GitHub Repository Setup

**Environment Secrets:**
Add these secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

```bash
# Database
MONGODB_URI=mongodb+srv://forkline_user:<password>@cluster0.xxxxx.mongodb.net/forkline
REDIS_URL=redis://username:password@host:port

# Authentication
JWT_SECRET=your-super-secret-jwt-key-at-least-32-characters

# Railway
RAILWAY_TOKEN=your-railway-api-token

# Render  
RENDER_API_KEY=your-render-api-key

# Payment (Stripe)
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Email/SMS Services
EMAIL_SERVICE=your-email-service-config
SMS_SERVICE=your-sms-service-config

# External APIs
GOOGLE_MAPS_API_KEY=your-google-maps-key
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_S3_BUCKET=your-s3-bucket-name

# Monitoring
NEW_RELIC_LICENSE_KEY=your-newrelic-key
SENTRY_DSN=your-sentry-dsn
SLACK_WEBHOOK=your-slack-webhook-url
```

#### Step 3: Railway Deployment

**Login and Setup:**
```bash
# Login to Railway
railway login

# Link to existing project or create new
railway link  # or railway create forkline-backend
```

**Deploy Core Services:**
```bash
# API Gateway
cd backend/api-gateway
railway up

# Auth Service  
cd ../auth-service
railway up

# User Service
cd ../user-service
railway up

# Continue for other Node.js services...
```

**Custom Domains (Optional):**
```bash
# Add custom domain to API Gateway
railway domain add api.forkline.com
```

#### Step 4: Render Deployment

**Login and Deploy:**
```bash
# Login to Render
render auth login

# Deploy all services using render.yaml
render deploy
```

**Manual Service Creation (Alternative):**
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Connect your GitHub repository
3. Create web services for each Python/Go service
4. Set environment variables for each service

#### Step 5: DNS Configuration

**For Custom Domains:**
```bash
# Point your domain to the services
api.forkline.com        → Railway API Gateway
staging-api.forkline.com → Railway API Gateway (staging)
```

## 🔧 Environment Variables Reference

### Core Environment Variables
```bash
# Application
NODE_ENV=production
ENVIRONMENT=production
PORT=3000

# Database
MONGODB_URI=mongodb+srv://...
REDIS_URL=redis://...

# Authentication
JWT_SECRET=your-jwt-secret
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=12

# File Uploads
UPLOAD_PATH=/tmp/uploads
MAX_FILE_SIZE=5MB
```

### Service-Specific Variables

**Payment Service:**
```bash
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
```

**Geolocation Service:**
```bash
GOOGLE_MAPS_API_KEY=your-api-key
```

**Media Service:**
```bash
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_S3_BUCKET=your-bucket
AWS_REGION=us-east-1
```

**Notification Service:**
```bash
EMAIL_SERVICE=sendgrid
EMAIL_API_KEY=your-sendgrid-key
SMS_SERVICE=twilio
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
PUSH_NOTIFICATION_KEY=your-fcm-key
```

## 🧪 Testing the Deployment

### Health Checks
```bash
# Test API Gateway
curl https://api.forkline.com/health

# Test individual services
curl https://api.forkline.com/api/auth/health
curl https://api.forkline.com/api/user/health
curl https://api.forkline.com/api/restaurant/health
```

### API Testing
```bash
# Register a test user
curl -X POST https://api.forkline.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'

# Login
curl -X POST https://api.forkline.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## 📊 Monitoring & Logging

### Application Monitoring
- **New Relic**: Application performance monitoring
- **Sentry**: Error tracking and alerting
- **Railway Metrics**: Built-in monitoring for Railway services
- **Render Metrics**: Built-in monitoring for Render services

### Log Management
```bash
# Railway logs
railway logs --service api-gateway

# Render logs  
render logs --service forkline-restaurant-service
```

## 🔒 Security Considerations

### Production Checklist
- [x] **Environment Variables**: All secrets in environment variables, not code
- [x] **HTTPS**: All services use HTTPS in production
- [x] **JWT Security**: Strong JWT secrets, reasonable expiration times
- [x] **Database Security**: MongoDB with authentication, IP restrictions
- [x] **Rate Limiting**: Implemented in API Gateway
- [x] **Input Validation**: All endpoints validate input
- [x] **CORS**: Properly configured for your frontend domains

### Security Headers
```bash
# Ensure these headers are set (handled by services)
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
```

## 🚨 Troubleshooting

### Common Issues

**1. Service Won't Start**
```bash
# Check logs
railway logs --service service-name
render logs --service service-name

# Check environment variables
railway variables
```

**2. Database Connection Failed**
```bash
# Verify MongoDB connection string
# Check IP whitelist in MongoDB Atlas
# Verify Redis connection string
```

**3. 502 Bad Gateway**
```bash
# Service might be starting up (wait 2-3 minutes)
# Check if service is listening on correct PORT
# Verify health check endpoint
```

**4. GitHub Actions Failing**
```bash
# Check GitHub secrets are set correctly
# Verify CLI tokens are valid
# Check build logs in Actions tab
```

## 📈 Scaling Considerations

### Performance Optimization
- **Database**: Use MongoDB indexes for frequently queried fields
- **Caching**: Redis for session storage and API response caching
- **CDN**: Use CloudFlare for static assets
- **Load Balancing**: Railway and Render provide automatic load balancing

### Auto-Scaling
- **Railway**: Automatic scaling based on traffic
- **Render**: Configure auto-scaling rules
- **Database**: MongoDB Atlas auto-scaling available

## 🔄 CI/CD Pipeline

### Automated Deployment Flow
1. **Push to `develop`** → Deploy to staging
2. **Push to `main`** → Deploy to production
3. **Manual trigger** → Deploy to specific environment

### Pipeline Stages
1. **Security Scan** - Vulnerability checking
2. **Test Matrix** - Multi-language testing (Node.js, Python, Go, Java)
3. **Build Images** - Docker containerization
4. **Deploy Services** - Parallel deployment to cloud platforms
5. **Health Checks** - Verify deployment success
6. **Update Documentation** - API docs with new URLs

## 📞 Support

### Getting Help
- **GitHub Issues**: For bugs and feature requests
- **Railway Discord**: For Railway-specific issues
- **Render Support**: For Render-specific issues
- **Documentation**: This guide and service-specific docs

### Monitoring Alerts
Set up alerts for:
- Service downtime
- High error rates
- Database connection issues
- Performance degradation

---

## 🎉 You're All Set!

Your ForkLine backend is now deployed to the cloud with automated CI/CD! 

**Next Steps:**
1. Update your frontend to use the production API URLs
2. Test all functionality end-to-end
3. Set up monitoring and alerting
4. Consider implementing additional security measures
5. Plan for backup and disaster recovery

**Production URLs:**
- **API Gateway**: `https://api.forkline.com`
- **API Documentation**: `https://imranmd96.github.io/forkline-api-docs/`
- **Individual Services**: Available through the API Gateway 