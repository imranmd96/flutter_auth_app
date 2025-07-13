# ForkLine Notification Service

The Notification Service is a microservice responsible for handling all notification-related functionality in the ForkLine restaurant management system. It supports multiple notification channels, templates, and user preferences.

## Features

- Multi-channel notification support:
  - Email (via SendGrid)
  - SMS (via Twilio)
  - Push notifications (via Firebase)
  - In-app notifications
  - Web notifications (via WebSocket)

- Notification Templates
  - Dynamic content with variable substitution
  - Multi-language support
  - Channel-specific templates
  - Template versioning

- User Preferences
  - Channel preferences
  - Notification type preferences
  - Quiet hours
  - Language preferences

- Real-time Notifications
  - WebSocket support for real-time updates
  - Event-driven architecture
  - Scalable message delivery

## API Endpoints

### Notifications

- `POST /notifications` - Create a new notification
- `GET /notifications` - List notifications with filtering and pagination
- `GET /notifications/:id` - Get a specific notification
- `PATCH /notifications/:id/status` - Update notification status
- `DELETE /notifications/:id` - Delete a notification

### Templates

- `POST /templates` - Create a new notification template
- `GET /templates` - List templates with filtering
- `GET /templates/:id` - Get a specific template
- `PUT /templates/:id` - Update a template
- `DELETE /templates/:id` - Delete a template

### Preferences

- `GET /preferences/:userId` - Get user notification preferences
- `PUT /preferences/:userId` - Update user notification preferences

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Create a `.env` file based on `.env.example` and configure the environment variables.

3. Start the development server:
   ```bash
   npm run dev
   ```

4. For production:
   ```bash
   npm run build
   npm start
   ```

## Environment Variables

- `PORT` - Server port (default: 3006)
- `NODE_ENV` - Environment (development/production)
- `MONGODB_URI` - MongoDB connection string
- `REDIS_HOST` - Redis host
- `REDIS_PORT` - Redis port
- `SENDGRID_API_KEY` - SendGrid API key
- `TWILIO_ACCOUNT_SID` - Twilio account SID
- `TWILIO_AUTH_TOKEN` - Twilio auth token
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `JWT_SECRET` - JWT secret for authentication
- `CORS_ORIGIN` - Allowed CORS origin

## Dependencies

- Express.js - Web framework
- MongoDB - Database
- Redis - Caching and pub/sub
- SendGrid - Email notifications
- Twilio - SMS notifications
- Firebase Admin - Push notifications
- WebSocket - Real-time notifications
- TypeScript - Type safety
- Jest - Testing

## Security Considerations

- All API endpoints are protected with JWT authentication
- Rate limiting is implemented to prevent abuse
- Sensitive data is encrypted
- Input validation and sanitization
- Secure WebSocket connections
- Environment variable protection

## Best Practices

- Use templates for consistent notification formatting
- Implement retry mechanisms for failed notifications
- Monitor notification delivery rates
- Respect user preferences and quiet hours
- Implement proper error handling
- Use appropriate notification channels based on priority
- Maintain notification history for auditing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 