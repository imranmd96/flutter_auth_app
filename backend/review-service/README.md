# Review Service

The Review Service is a microservice responsible for managing restaurant reviews in the ForkLine system. It provides functionality for creating, reading, updating, and deleting reviews, as well as advanced analytics and insights.

## Features

- Create, read, update, and delete reviews
- Sentiment analysis of review comments
- Review analytics and insights
- Caching with Redis
- MongoDB for data persistence
- JWT authentication
- Input validation
- Error handling
- Logging with Winston

## Prerequisites

- Node.js (v16 or higher)
- MongoDB
- Redis
- npm or yarn

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file with the following variables:
   ```
   # Server Configuration
   PORT=3008
   NODE_ENV=development

   # MongoDB Configuration
   MONGODB_URI=mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/review-service?retryWrites=true&w=majority

   # Redis Configuration
   REDIS_HOST=localhost
   REDIS_PORT=6379
   REDIS_PASSWORD=

   # JWT Configuration
   JWT_SECRET=your-secret-key
   JWT_EXPIRES_IN=24h

   # Logging Configuration
   LOG_LEVEL=info
   ```
4. Build the project:
   ```bash
   npm run build
   ```

## Running the Service

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## API Endpoints

### Reviews

- `POST /api/reviews` - Create a new review
- `GET /api/reviews/restaurant/:restaurantId` - Get reviews for a restaurant
- `GET /api/reviews/user` - Get user's reviews
- `PUT /api/reviews/:reviewId` - Update a review
- `DELETE /api/reviews/:reviewId` - Delete a review

### Analytics

- `GET /api/reviews/analytics/:restaurantId` - Get review analytics
- `GET /api/reviews/insights/:restaurantId` - Get review insights

## Data Models

### Review

```typescript
interface Review {
  userId: string;
  restaurantId: string;
  rating: number;
  comment: string;
  status: ReviewStatus;
  createdAt: Date;
  updatedAt: Date;
}

enum ReviewStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED'
}
```

### Review Analytics

```typescript
interface ReviewAnalytics {
  restaurantId: string;
  totalReviews: number;
  averageRating: number;
  sentimentDistribution: {
    positive: number;
    neutral: number;
    negative: number;
  };
  commonTopics: Array<{
    word: string;
    count: number;
  }>;
  ratingTrends: {
    daily: Array<{
      date: string;
      average: number;
    }>;
    weekly: Array<{
      week: string;
      average: number;
    }>;
    monthly: Array<{
      month: string;
      average: number;
    }>;
  };
  lastUpdated: Date;
}
```

## Testing

Run tests:
```bash
npm test
```

Run tests with coverage:
```bash
npm run test:coverage
```

## Error Handling

The service uses a centralized error handling middleware that:
- Logs errors
- Returns appropriate HTTP status codes
- Provides detailed error messages in development mode
- Sanitizes error messages in production

## Logging

The service uses Winston for logging with the following features:
- Console and file logging
- Different log levels for different environments
- Structured logging with timestamps
- Error logging to separate file

## Caching

Redis is used for caching:
- Review analytics are cached for 1 hour
- Cache invalidation on review updates
- Fallback to database on cache miss

## Security

- JWT authentication
- Input validation with Joi
- Helmet for HTTP security headers
- CORS configuration
- Rate limiting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT 