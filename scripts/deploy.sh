#!/bin/bash

# 🚀 ForkLine Backend Deployment Script
# This script automates the deployment of all microservices to cloud platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-staging}
PROJECT_NAME="forkline-backend"

echo -e "${BLUE}🚀 Starting ForkLine Backend Deployment${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}================================================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Railway CLI if not exists
install_railway_cli() {
    if ! command_exists railway; then
        echo -e "${YELLOW}📦 Installing Railway CLI...${NC}"
        curl -fsSL https://railway.app/install.sh | sh
        export PATH="$HOME/.railway/bin:$PATH"
    fi
}

# Function to install Render CLI if not exists
install_render_cli() {
    if ! command_exists render; then
        echo -e "${YELLOW}📦 Installing Render CLI...${NC}"
        npm install -g @render/cli
    fi
}

# Function to setup external databases
setup_databases() {
    echo -e "${BLUE}🗄️ Setting up databases...${NC}"
    
    # MongoDB Atlas setup
    echo -e "${YELLOW}Setting up MongoDB Atlas...${NC}"
    echo "1. Go to https://cloud.mongodb.com/"
    echo "2. Create a new cluster (M0 Sandbox for free tier)"
    echo "3. Create database user and get connection string"
    echo "4. Add the connection string to your secrets"
    
    # Redis Cloud setup
    echo -e "${YELLOW}Setting up Redis Cloud...${NC}"
    echo "1. Go to https://redis.com/try-free/"
    echo "2. Create a free Redis database"
    echo "3. Get the connection string"
    echo "4. Add the connection string to your secrets"
}

# Function to deploy to Railway
deploy_to_railway() {
    echo -e "${BLUE}🚂 Deploying core services to Railway...${NC}"
    
    install_railway_cli
    
    # Login check
    if ! railway whoami >/dev/null 2>&1; then
        echo -e "${YELLOW}Please login to Railway first:${NC}"
        railway login
    fi
    
    # Create or connect to project
    if [ ! -f ".railway/project.json" ]; then
        echo -e "${YELLOW}Creating new Railway project...${NC}"
        railway create "$PROJECT_NAME"
    fi
    
    # Deploy services
    local services=("api-gateway" "auth-service" "user-service" "chat-service" "notification-service" "review-service")
    
    for service in "${services[@]}"; do
        echo -e "${YELLOW}Deploying $service to Railway...${NC}"
        
        # Create service
        railway service create "$service" --project "$PROJECT_NAME" || true
        
        # Deploy from specific directory
        cd "backend/$service"
        railway deploy --service "$service"
        cd ../..
        
        echo -e "${GREEN}✅ $service deployed successfully${NC}"
    done
}

# Function to deploy to Render
deploy_to_render() {
    echo -e "${BLUE}🎨 Deploying additional services to Render...${NC}"
    
    install_render_cli
    
    # Check if logged in
    if ! render whoami >/dev/null 2>&1; then
        echo -e "${YELLOW}Please login to Render first:${NC}"
        render auth login
    fi
    
    # Deploy using render.yaml
    echo -e "${YELLOW}Deploying services using render.yaml...${NC}"
    render deploy
    
    echo -e "${GREEN}✅ Render services deployed successfully${NC}"
}

# Function to update API documentation
update_api_docs() {
    echo -e "${BLUE}📚 Updating API documentation...${NC}"
    
    # Update swagger.yaml with production URLs
    local swagger_file="backend/api-gateway/swagger.yaml"
    local github_pages_swagger="api-docs-github-pages/swagger.yaml"
    
    if [ "$ENVIRONMENT" = "production" ]; then
        # Production URLs
        cat > temp_servers.yml << EOF
servers:
  - url: https://api.forkline.com
    description: Production API Gateway
  - url: https://staging-api.forkline.com
    description: Staging API Gateway
  - url: http://localhost:3000
    description: Local development server
EOF
    else
        # Staging URLs
        cat > temp_servers.yml << EOF
servers:
  - url: https://staging-api.forkline.com
    description: Staging API Gateway
  - url: http://localhost:3000
    description: Local development server
  - url: https://api.forkline.com
    description: Production API Gateway
EOF
    fi
    
    # Replace servers section in swagger files
    sed -i.bak '/^servers:/,/^[a-zA-Z]/ { /^servers:/r temp_servers.yml
        /^servers:/,/^[a-zA-Z]/ { /^[a-zA-Z]/!d; }; }' "$swagger_file"
    
    if [ -f "$github_pages_swagger" ]; then
        cp "$swagger_file" "$github_pages_swagger"
    fi
    
    rm temp_servers.yml
    rm "$swagger_file.bak" 2>/dev/null || true
    
    echo -e "${GREEN}✅ API documentation updated${NC}"
}

# Function to run health checks
run_health_checks() {
    echo -e "${BLUE}🏥 Running health checks...${NC}"
    
    local base_url
    if [ "$ENVIRONMENT" = "production" ]; then
        base_url="https://api.forkline.com"
    else
        base_url="https://staging-api.forkline.com"
    fi
    
    echo -e "${YELLOW}Checking API Gateway health...${NC}"
    if curl -f "$base_url/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ API Gateway is healthy${NC}"
    else
        echo -e "${RED}❌ API Gateway health check failed${NC}"
    fi
    
    # Add more health checks for other services
    local services=("auth" "user" "restaurant")
    for service in "${services[@]}"; do
        echo -e "${YELLOW}Checking $service service...${NC}"
        if curl -f "$base_url/api/$service/health" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $service service is healthy${NC}"
        else
            echo -e "${RED}❌ $service service health check failed${NC}"
        fi
    done
}

# Function to setup monitoring
setup_monitoring() {
    echo -e "${BLUE}📊 Setting up monitoring...${NC}"
    
    echo "Setting up application monitoring:"
    echo "1. New Relic: https://newrelic.com/"
    echo "2. DataDog: https://www.datadoghq.com/"
    echo "3. Sentry for error tracking: https://sentry.io/"
    
    echo -e "${YELLOW}Consider adding these environment variables:${NC}"
    echo "- NEW_RELIC_LICENSE_KEY"
    echo "- SENTRY_DSN"
    echo "- DATADOG_API_KEY"
}

# Function to display deployment summary
deployment_summary() {
    echo -e "${BLUE}📋 Deployment Summary${NC}"
    echo -e "${BLUE}================================================${NC}"
    
    if [ "$ENVIRONMENT" = "production" ]; then
        echo -e "${GREEN}🌟 Production Deployment Complete!${NC}"
        echo ""
        echo "🔗 Service URLs:"
        echo "   • API Gateway: https://api.forkline.com"
        echo "   • Auth Service: https://forkline-auth-service.up.railway.app"
        echo "   • User Service: https://forkline-user-service.up.railway.app"
        echo "   • Restaurant Service: https://forkline-restaurant-service.onrender.com"
        echo "   • API Documentation: https://imranmd96.github.io/forkline-api-docs/"
    else
        echo -e "${YELLOW}🚀 Staging Deployment Complete!${NC}"
        echo ""
        echo "🔗 Service URLs:"
        echo "   • API Gateway: https://staging-api.forkline.com"
        echo "   • All services deployed to staging environments"
    fi
    
    echo ""
    echo "📚 Next Steps:"
    echo "1. Test all API endpoints"
    echo "2. Run integration tests"
    echo "3. Update your frontend to use production URLs"
    echo "4. Setup monitoring and alerting"
    echo "5. Configure custom domains (if needed)"
}

# Main execution
main() {
    echo -e "${BLUE}Starting deployment process...${NC}"
    
    # Check prerequisites
    if ! command_exists curl; then
        echo -e "${RED}Error: curl is required but not installed.${NC}"
        exit 1
    fi
    
    if ! command_exists git; then
        echo -e "${RED}Error: git is required but not installed.${NC}"
        exit 1
    fi
    
    # Setup databases (manual step with instructions)
    setup_databases
    echo -e "${YELLOW}Press Enter after setting up databases to continue...${NC}"
    read -r
    
    # Deploy services
    deploy_to_railway
    deploy_to_render
    
    # Update documentation
    update_api_docs
    
    # Wait for deployments to be ready
    echo -e "${YELLOW}Waiting 2 minutes for services to start...${NC}"
    sleep 120
    
    # Run health checks
    run_health_checks
    
    # Setup monitoring guidance
    setup_monitoring
    
    # Show summary
    deployment_summary
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 