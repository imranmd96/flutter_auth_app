# Booking Service

The Booking Service is a critical component of the ForkLine system, responsible for managing table reservations, waitlists, and restaurant capacity planning. It provides a robust API for handling all booking-related operations.

## Features

### Table Management
- Create and manage restaurant tables
- Track table status (Available, Reserved, Occupied)
- Support for table features and capacity
- Real-time table availability updates

### Booking Management
- Create, update, and cancel bookings
- Support for different booking types (Dine-in, Takeaway, Delivery)
- Real-time availability checking
- Overlapping booking prevention
- Booking status tracking
- Waitlist management

### Analytics and Reporting
- Booking statistics and trends
- Peak hours analysis
- Popular tables tracking
- Waitlist analytics
- No-show tracking
- Revenue forecasting

## API Endpoints

### Table Endpoints
- `POST /api/tables` - Create a new table
- `GET /api/tables` - Get paginated list of tables with filters

### Booking Endpoints
- `POST /api/bookings` - Create a new booking
- `GET /api/bookings` - Get paginated list of bookings with filters
- `GET /api/bookings/{booking_id}` - Get booking details
- `PUT /api/bookings/{booking_id}` - Update booking
- `POST /api/bookings/{booking_id}/join-waitlist` - Join waitlist for a booking

### Analytics Endpoints
- `GET /api/restaurants/{restaurant_id}/bookings/stats` - Get booking statistics

## Data Models

### Table
- ID
- Restaurant ID
- Table Number
- Capacity
- Status
- Features
- Timestamps

### Booking
- ID
- Booking Number
- Restaurant ID
- Customer ID
- Table ID
- Booking Type
- Party Size
- Booking Date
- Start Time
- End Time
- Status
- Contact Information
- Special Requests
- Timestamps

### Waitlist
- ID
- Booking ID
- Restaurant ID
- Customer ID
- Party Size
- Position
- Status
- Timestamps

## Technical Details

### Database
- MongoDB for primary data storage
- Indexed collections for efficient querying
- Real-time updates using MongoDB change streams

### Authentication & Authorization
- JWT-based authentication
- Role-based access control
- Restaurant owner and staff permissions

### Integration
- Payment Service for deposits and cancellations
- Restaurant Service for table management
- Notification Service for booking updates
- Analytics Service for reporting

## Getting Started

### Prerequisites
- Python 3.8+
- MongoDB
- FastAPI
- Uvicorn

### Environment Variables
```env
# Server Configuration
PORT=3004
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/booking-service?retryWrites=true&w=majority

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

### Installation
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run the service
uvicorn main:app --reload --port 3004
```

### API Documentation
- Swagger UI: `http://localhost:3004/docs`
- ReDoc: `http://localhost:3004/redoc`

## Testing
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src tests/
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details. 