# API Gateway

The API Gateway serves as the entry point for all client requests in the ForkLine application. It handles routing, authentication, rate limiting, and request forwarding to the appropriate microservices.

## Architecture

The API Gateway is built using Node.js with Express and uses `http-proxy-middleware` for routing requests to different microservices. Here's the detailed architecture:

### Core Components

1. **Express Server**
   - Built with Express.js
   - Handles HTTP requests and responses
   - Implements middleware chain for request processing

2. **Proxy Middleware**
   - Uses `http-proxy-middleware` for request routing
   - Supports path rewriting and request forwarding
   - Handles different content types (JSON, form data)
   - Implements error handling for various scenarios

3. **Authentication**
   - JWT-based authentication
   - Token verification and validation
   - Role-based access control

4. **Security**
   - CORS configuration
   - Helmet for security headers
   - Rate limiting
   - Request validation

### Microservices Integration

The API Gateway routes requests to the following microservices:

| Service | Base Path | Default Port |
|---------|-----------|--------------|
| Auth | `/api/auth` | 3001 |
| Users | `/api/users` | 3015 |
| Restaurants | `/api/restaurants` | 3012 |
| Orders | `/api/orders` | 3010 |
| Bookings | `/api/bookings` | 3002 |
| Inventory | `/api/inventory` | 3005 |
| Notifications | `/api/notification` | 3009 |
| Reviews | `/api/review` | 3013 |
| Menu | `/api/menu` | 3008 |
| Payments | `/api/payment` | 3011 |
| Analytics | `/api/analytics` | 3016 |
| Chat | `/api/chat` | 3003 |
| Media | `/api/media` | 3007 |

### Request Flow

1. Client sends request to API Gateway
2. Request passes through middleware chain:
   - CORS handling
   - Rate limiting
   - Authentication (if required)
   - Request logging
3. Request is routed to appropriate microservice
4. Response is returned to client

## Features

- **Request Routing**
  - Dynamic routing to microservices
  - Path rewriting
  - Load balancing support
  - Service discovery integration

- **Authentication & Authorization**
  - JWT token validation
  - Role-based access control
  - Token refresh mechanism
  - Session management

- **Rate Limiting**
  - Configurable rate limits per endpoint
  - Different limits for authenticated/unauthenticated requests
  - IP-based rate limiting
  - Custom rate limit handlers

- **Request/Response Handling**
  - Request body parsing
  - Response compression
  - Error handling
- Request/response logging
  - Custom error responses

- **Security**
- CORS configuration
  - Security headers (Helmet)
  - Request validation
  - Input sanitization
  - XSS protection

- **Monitoring & Logging**
  - Request/response logging
  - Error logging
  - Performance monitoring
  - Health checks
  - Service status monitoring

## Advanced Features

### Service Discovery
The API Gateway can be enhanced with service discovery to dynamically locate and route to microservices:

1. **Consul Integration**
   ```typescript
   // Example service discovery configuration
   const consul = new Consul({
     host: process.env.CONSUL_HOST,
     port: process.env.CONSUL_PORT
   });
   ```

2. **Service Registration**
   - Automatic service registration
   - Health check integration
   - Dynamic service updates

3. **Load Balancing**
   - Round-robin distribution
   - Weighted routing
   - Health-based routing

### Circuit Breaker Pattern
Implement circuit breaker to handle service failures gracefully:

```typescript
const circuitBreaker = new CircuitBreaker({
  failureThreshold: 5,
  resetTimeout: 30000
});
```

### Caching Strategy
Implement caching to improve performance:

1. **Response Caching**
   - In-memory caching
   - Redis integration
   - Cache invalidation

2. **Cache Headers**
   - ETag support
   - Cache-Control headers
   - Conditional requests

### API Documentation
Enhanced API documentation using Swagger/OpenAPI:

1. **Interactive Documentation**
   - Swagger UI integration
   - API versioning
   - Request/response examples

2. **Schema Validation**
   - Request validation
   - Response validation
   - Error documentation

### Monitoring and Analytics
Advanced monitoring capabilities:

1. **Metrics Collection**
   - Request latency
   - Error rates
   - Service health

2. **Logging**
   - Structured logging
   - Log aggregation
   - Error tracking

3. **Alerting**
   - Service down alerts
   - Performance alerts
   - Error rate alerts

## Prerequisites

- Node.js (v18 or higher)
- npm (v8 or higher)
- Docker (optional, for containerization)

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file based on `.env.example`
4. Build the project:
   ```bash
   npm run build
   ```

## Development

Start the development server:
```bash
npm run dev
```

## Production

Build and start the production server:
```bash
npm run build
npm start
```

## Docker

Build and run with Docker:
```bash
docker build -t api-gateway .
docker run -p 3000:3000 api-gateway
```

## API Endpoints

### Health Check
- `GET /health` - Check API Gateway status

### User Service
- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - User login
- `GET /api/users/profile` - Get user profile (protected)

### Restaurant Service
- `GET /api/restaurants` - List restaurants
- `GET /api/restaurants/:id` - Get restaurant details
- `POST /api/restaurants` - Create restaurant (protected)

### Order Service
- `POST /api/orders` - Create order (protected)
- `GET /api/orders` - List user orders (protected)
- `GET /api/orders/:id` - Get order details (protected)

### Booking Service
- `POST /api/bookings` - Create booking (protected)
- `GET /api/bookings` - List user bookings (protected)
- `GET /api/bookings/:id` - Get booking details (protected)

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `JWT_SECRET` - JWT secret key
- `JWT_EXPIRES_IN` - JWT token expiration
- `USER_SERVICE_URL` - User service URL
- `RESTAURANT_SERVICE_URL` - Restaurant service URL
- `ORDER_SERVICE_URL` - Order service URL
- `BOOKING_SERVICE_URL` - Booking service URL
- `RATE_LIMIT_WINDOW_MS` - Rate limit window
- `RATE_LIMIT_MAX` - Maximum requests per window
- `CORS_ORIGIN` - Allowed CORS origin

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License. 