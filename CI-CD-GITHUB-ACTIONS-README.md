# 🚀 ForkLine GitHub Actions CI/CD Pipeline Documentation

This document describes the comprehensive GitHub Actions CI/CD pipeline structure for the ForkLine restaurant management system.

## 🏗️ Pipeline Architecture

### Main Orchestrator Workflow
- **Location**: `.github/workflows/github-main-orchestrator-production.yml`
- **Purpose**: Coordinates deployment of all services based on detected changes
- **Triggers**: Push to main branch, pull requests, manual dispatch

### Individual Service Pipelines

Each service has its own dedicated CI/CD pipeline located within its service directory:

#### 🚂 Railway Services (Node.js)
- **API Gateway**: `backend/api-gateway/.github-ci-cd-api-gateway-production.yml`
- **Auth Service**: `backend/auth-service/.github-ci-cd-auth-service-production.yml`
- **User Service**: `backend/user-service/.github-ci-cd-user-service-production.yml`
- **Payment Service**: `backend/payment-service/.github-ci-cd-payment-service-production.yml`
- **Chat Service**: `backend/chat-service/.github-ci-cd-chat-service-production.yml`
- **Notification Service**: `backend/notification-service/.github-ci-cd-notification-service-production.yml`
- **Review Service**: `backend/review-service/.github-ci-cd-review-service-production.yml`

#### 🎨 Render Services (Python/Go/Java)
- **Restaurant Service**: `backend/restaurant-service/.github-ci-cd-restaurant-service-production.yml`
- **Menu Service**: `backend/menu-service/.github-ci-cd-menu-service-production.yml`
- **Order Service**: `backend/order-service/.github-ci-cd-order-service-production.yml`
- **Booking Service**: `backend/booking-service/.github-ci-cd-booking-service-production.yml`
- **Geolocation Service**: `backend/geolocation-service/.github-ci-cd-geolocation-service-production.yml`
- **Analytics Service**: `backend/analytics-service/.github-ci-cd-analytics-service-production.yml`
- **Inventory Service**: `backend/inventory-service/.github-ci-cd-inventory-service-production.yml`
- **Search Service**: `backend/search-service/.github-ci-cd-search-service-production.yml`
- **Media Service**: `backend/media-service/.github-ci-cd-media-service-production.yml`

## 🔄 Pipeline Workflow

### 1. Change Detection
- Monitors file changes in `backend/**` directories
- Identifies which services need deployment
- Supports manual override for all services

### 2. Service-Specific Pipelines
Each service pipeline includes:
- **🔒 Security Scan**: Trivy vulnerability scanning
- **🧪 Build & Test**: Language-specific testing and building
- **🐳 Docker Build**: Container image creation and push
- **🚀 Deployment**: Platform-specific deployment (Railway/Render)
- **🔍 Health Check**: Post-deployment verification
- **📢 Notifications**: Slack alerts and status updates

### 3. Orchestrator Coordination
- **Change Detection**: Identifies modified services
- **Parallel Deployment**: Deploys Railway and Render services simultaneously
- **Health Monitoring**: Performs system-wide health checks
- **Integration Testing**: Runs end-to-end tests
- **Documentation Updates**: Refreshes API documentation

## 🛠️ Technology Stack Support

### Node.js Services
- **Versions**: 18.x, 20.x
- **Package Manager**: npm with caching
- **Testing**: Jest, Mocha, or custom test suites
- **Deployment**: Railway platform

### Python Services
- **Versions**: 3.9, 3.10
- **Package Manager**: pip with caching
- **Testing**: pytest with coverage
- **Deployment**: Render platform

### Java Services
- **Versions**: 17, 21
- **Build Tool**: Maven with caching
- **Testing**: JUnit and Spring Boot Test
- **Deployment**: Render platform

### Go Services
- **Versions**: 1.20, 1.21
- **Module System**: Go modules with caching
- **Testing**: Native Go testing
- **Deployment**: Render platform

## 🔧 Configuration Requirements

### GitHub Secrets
```bash
# Database
MONGODB_URI=mongodb+srv://...
REDIS_URL=redis://...

# Railway Webhooks
RAILWAY_WEBHOOK_API_GATEWAY=https://...
RAILWAY_WEBHOOK_AUTH_SERVICE=https://...
RAILWAY_WEBHOOK_USER_SERVICE=https://...
RAILWAY_WEBHOOK_PAYMENT_SERVICE=https://...
RAILWAY_WEBHOOK_CHAT_SERVICE=https://...
RAILWAY_WEBHOOK_NOTIFICATION_SERVICE=https://...
RAILWAY_WEBHOOK_REVIEW_SERVICE=https://...

# Render Webhooks
RENDER_WEBHOOK_RESTAURANT_SERVICE=https://...
RENDER_WEBHOOK_MENU_SERVICE=https://...
RENDER_WEBHOOK_ORDER_SERVICE=https://...
RENDER_WEBHOOK_BOOKING_SERVICE=https://...
RENDER_WEBHOOK_GEOLOCATION_SERVICE=https://...
RENDER_WEBHOOK_ANALYTICS_SERVICE=https://...
RENDER_WEBHOOK_INVENTORY_SERVICE=https://...
RENDER_WEBHOOK_SEARCH_SERVICE=https://...
RENDER_WEBHOOK_MEDIA_SERVICE=https://...

# Notifications
SLACK_WEBHOOK=https://hooks.slack.com/...

# Container Registry
GITHUB_TOKEN=ghp_... (automatic)
```

## 🚀 Deployment Process

### Automatic Deployment via Git Push

#### Step 1: Make Your Changes
```bash
# Navigate to your project directory
cd /path/to/your/forkLine

# Create a new branch for your changes (optional but recommended)
git checkout -b feature/your-feature-name

# Make your changes to any service
# For example, modify files in:
# - backend/auth-service/
# - backend/payment-service/
# - backend/restaurant-service/
# etc.
```

#### Step 2: Stage and Commit Changes
```bash
# Check what files have changed
git status

# Add specific files or add all changes
git add backend/auth-service/src/controllers/auth.controller.ts
# OR add all changes
git add .

# Commit your changes with a descriptive message
git commit -m "feat: add new authentication endpoint"
```

#### Step 3: Push to Main Branch (Triggers CI/CD)
```bash
# Push to main branch - THIS AUTOMATICALLY TRIGGERS THE CI/CD PIPELINE
git push origin main

# OR if you're working on a feature branch, create a pull request:
git push origin feature/your-feature-name
# Then create a PR to main branch on GitHub
```

#### Step 4: Monitor Deployment
1. **Go to GitHub Actions**: https://github.com/imranmd96/forkLine/actions
2. **Watch the pipeline**: You'll see "ForkLine Main Orchestrator" workflow running
3. **Check individual services**: Each changed service will have its own pipeline running
4. **Monitor logs**: Click on any running workflow to see detailed logs

#### What Happens Automatically:
1. **Change detection** → Identifies modified services
2. **Parallel deployment** → Deploys only changed services
3. **Health verification** → Ensures all services are operational
4. **Slack notifications** → Sends deployment status to your team

### Manual Deployment via GitHub UI

#### Option 1: Manual Trigger (Deploy All Services)
1. **Go to Actions tab**: https://github.com/imranmd96/forkLine/actions
2. **Select "ForkLine Main Orchestrator"**
3. **Click "Run workflow"**
4. **Choose deployment options**:
   - `deploy_services`: Select "all" or specific services
   - `force_deploy`: Check if you want to force deployment
5. **Click "Run workflow"** button
6. **Monitor progress** through workflow logs

#### Option 2: Deploy Specific Services
1. **Go to Actions tab**: https://github.com/imranmd96/forkLine/actions
2. **Find individual service workflow** (e.g., "Auth Service - Production CI/CD")
3. **Click "Run workflow"**
4. **Enable "Force production deployment"**
5. **Click "Run workflow"** button

### Git Workflow Best Practices

#### For Team Development:
```bash
# 1. Always start with latest main branch
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/payment-integration

# 3. Make your changes and commit
git add .
git commit -m "feat: integrate Stripe payment gateway"

# 4. Push feature branch
git push origin feature/payment-integration

# 5. Create Pull Request to main branch
# This triggers PR validation pipelines

# 6. After PR approval, merge to main
# This automatically triggers production deployment
```

#### For Individual Development:
```bash
# 1. Make changes directly on main (if you're the only developer)
git checkout main
git pull origin main

# 2. Make your changes
# Edit files in backend/auth-service/, backend/payment-service/, etc.

# 3. Stage and commit
git add .
git commit -m "fix: resolve authentication token expiration issue"

# 4. Push to main (triggers automatic deployment)
git push origin main
```

### Deployment Triggers

#### Automatic Triggers:
- **Push to main branch** → Full CI/CD pipeline
- **Pull Request to main** → Validation pipeline (no deployment)
- **File changes in `backend/**`** → Only affected services deploy

#### Manual Triggers:
- **GitHub Actions UI** → Manual workflow dispatch
- **API calls** → Using GitHub REST API
- **GitHub CLI** → Command-line triggering

### Example: Deploying Auth Service Changes

```bash
# 1. Navigate to project
cd /path/to/forkLine

# 2. Make changes to auth service
echo "console.log('New feature');" >> backend/auth-service/src/controllers/auth.controller.ts

# 3. Commit and push
git add backend/auth-service/
git commit -m "feat: add new auth feature"
git push origin main

# 4. Watch deployment
# Go to: https://github.com/imranmd96/forkLine/actions
# You'll see:
# - "ForkLine Main Orchestrator" workflow running
# - "Auth Service - Production CI/CD" workflow running
# - Only auth-service gets deployed (not all services)
```

## 📊 Monitoring & Observability

### Health Checks
- **Service-level**: Individual service health endpoints
- **System-level**: Cross-service communication verification
- **Load balancer**: Platform-specific health monitoring

### Notifications
- **Slack Integration**: Real-time deployment status
- **GitHub Status**: Deployment status badges
- **Email Alerts**: Critical failure notifications

### Metrics
- **Deployment Success Rate**: Track deployment reliability
- **Build Times**: Monitor CI/CD performance
- **Test Coverage**: Maintain code quality standards

## 🔐 Security Features

### Vulnerability Scanning
- **Trivy**: Container and dependency scanning
- **SARIF Upload**: GitHub Security tab integration
- **Dependency Checks**: Automated vulnerability detection

### Secure Deployment
- **Environment Protection**: Production environment rules
- **Secret Management**: GitHub Secrets for sensitive data
- **Container Registry**: GitHub Container Registry (GHCR)

## 🎯 Production URLs

After successful deployment, services are available at:
- **API Gateway**: https://api.forkline.com
- **Auth Service**: https://auth.forkline.com
- **Restaurant Service**: https://restaurant.forkline.com
- **Payment Service**: https://payment.forkline.com
- **Order Service**: https://order.forkline.com
- **Menu Service**: https://menu.forkline.com
- **Booking Service**: https://booking.forkline.com
- **Geolocation Service**: https://geolocation.forkline.com
- **User Service**: https://user.forkline.com
- **Chat Service**: https://chat.forkline.com
- **Notification Service**: https://notification.forkline.com
- **Review Service**: https://review.forkline.com
- **Analytics Service**: https://analytics.forkline.com
- **Inventory Service**: https://inventory.forkline.com
- **Search Service**: https://search.forkline.com
- **Media Service**: https://media.forkline.com

## 🛡️ Best Practices

### File Naming Convention
- **Pattern**: `.github-ci-cd-{service-name}-production.yml`
- **Example**: `.github-ci-cd-auth-service-production.yml`
- **Benefits**: Clear identification and consistent structure

### Service Organization
- **Individual Pipelines**: Each service has its own pipeline
- **Centralized Orchestration**: Main workflow coordinates all services
- **Technology-Specific**: Tailored build processes for each tech stack

### Deployment Strategy
- **Blue-Green Deployment**: Zero-downtime deployments
- **Health Checks**: Automated service verification
- **Rollback Capability**: Quick reversion if issues arise

## 📈 Scaling Considerations

### Performance Optimization
- **Parallel Execution**: Services deploy simultaneously
- **Caching**: Dependency and build caching
- **Resource Limits**: Appropriate resource allocation

### Monitoring & Alerting
- **Real-time Monitoring**: Continuous health monitoring
- **Automated Alerts**: Immediate failure notifications
- **Performance Metrics**: Deployment and runtime metrics

---

## 🎉 Getting Started

### Step 1: Clone the Repository
```bash
# Clone your ForkLine repository
git clone https://github.com/imranmd96/forkLine.git
cd forkLine

# Check current branch
git branch -a

# Ensure you're on main branch
git checkout main
```

### Step 2: Configure GitHub Secrets
Navigate to your GitHub repository settings and add these secrets:

1. **Go to**: `https://github.com/imranmd96/forkLine/settings/secrets/actions`
2. **Click**: "New repository secret"
3. **Add these secrets**:

```bash
# Database Secrets
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/forkline
REDIS_URL=redis://username:password@host:port

# Railway Deployment Webhooks
RAILWAY_WEBHOOK_API_GATEWAY=https://railway.app/webhook/...
RAILWAY_WEBHOOK_AUTH_SERVICE=https://railway.app/webhook/...
RAILWAY_WEBHOOK_USER_SERVICE=https://railway.app/webhook/...
RAILWAY_WEBHOOK_PAYMENT_SERVICE=https://railway.app/webhook/...
RAILWAY_WEBHOOK_CHAT_SERVICE=https://railway.app/webhook/...
RAILWAY_WEBHOOK_NOTIFICATION_SERVICE=https://railway.app/webhook/...
RAILWAY_WEBHOOK_REVIEW_SERVICE=https://railway.app/webhook/...

# Render Deployment Webhooks
RENDER_WEBHOOK_RESTAURANT_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_MENU_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_ORDER_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_BOOKING_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_GEOLOCATION_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_ANALYTICS_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_INVENTORY_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_SEARCH_SERVICE=https://api.render.com/deploy/...
RENDER_WEBHOOK_MEDIA_SERVICE=https://api.render.com/deploy/...

# Notification Services
SLACK_WEBHOOK=https://hooks.slack.com/services/...
```

### Step 3: Make Your First Deployment
```bash
# 1. Make a small change to test the pipeline
echo "// Test deployment" >> backend/auth-service/src/index.ts

# 2. Stage and commit the change
git add .
git commit -m "test: trigger initial CI/CD pipeline"

# 3. Push to main branch (THIS TRIGGERS THE CI/CD PIPELINE)
git push origin main
```

### Step 4: Monitor Deployment Progress
1. **Go to GitHub Actions**: https://github.com/imranmd96/forkLine/actions
2. **Watch the pipeline**: You'll see "ForkLine Main Orchestrator" workflow running
3. **Check individual services**: Each changed service will have its own pipeline
4. **Monitor logs**: Click on workflows to see detailed progress

### Step 5: Verify Service Health
Once deployment completes, check your services:

```bash
# API Gateway (Main entry point)
curl -s https://api.forkline.com/health

# Auth Service
curl -s https://auth.forkline.com/health

# Restaurant Service
curl -s https://restaurant.forkline.com/health

# Payment Service
curl -s https://payment.forkline.com/health
```

### Step 6: Development Workflow
```bash
# For regular development:
# 1. Pull latest changes
git pull origin main

# 2. Make your changes to any service
# Edit files in backend/auth-service/, backend/payment-service/, etc.

# 3. Test locally (optional)
cd backend/auth-service
npm install
npm test

# 4. Commit and push (triggers automatic deployment)
git add .
git commit -m "feat: add new feature"
git push origin main

# 5. Monitor deployment at:
# https://github.com/imranmd96/forkLine/actions
```

### Troubleshooting Common Issues

#### Issue 1: Pipeline Fails Due to Missing Secrets
**Solution**: Ensure all GitHub Secrets are configured properly

#### Issue 2: Service Deployment Fails
**Solution**: Check individual service logs in GitHub Actions

#### Issue 3: Health Check Fails
**Solution**: Wait 2-3 minutes for services to fully start, then check again

### Quick Commands Reference

```bash
# Check what will be deployed
git status
git diff

# Deploy specific service changes
git add backend/auth-service/
git commit -m "feat: auth service updates"
git push origin main

# Deploy all services (force deployment)
# Go to GitHub Actions → ForkLine Main Orchestrator → Run workflow → Select "all"

# Check deployment status
# Visit: https://github.com/imranmd96/forkLine/actions
```

The CI/CD pipeline will automatically handle building, testing, and deploying your services! 🚀

### 🎯 Next Steps After Setup
1. **Customize services** for your specific needs
2. **Add more tests** to individual service pipelines
3. **Set up monitoring** and alerting
4. **Configure domain names** for production URLs
5. **Add API documentation** generation 