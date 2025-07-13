# 🍽️ Restaurant Service

## Overview
The Restaurant Service is a core component of the ForkLine platform, handling all restaurant-related operations including restaurant management, menu items, tables, reservations, staff management, reviews, and promotions.

## Features

### Restaurant Management
- Complete CRUD operations for restaurants
- Validation for all restaurant data
- Geolocation support
- Operating hours management
- Delivery radius and fees configuration

### Menu Management
- Dynamic menu item creation and updates
- Category management
- Price and preparation time tracking
- Nutritional information
- Special tags (spicy, popular, etc.)

### Table Management
- Table creation and status tracking
- Capacity management
- Reservation handling
- Table type categorization
- Accessibility features

### Staff Management
- Staff profiles and roles
- Work schedules
- Performance reviews
- Role-based access control
- Emergency contact information

### Review System
- Restaurant and menu item reviews
- Rating system
- Review moderation
- Response management
- Review analytics

### Promotions
- Multiple promotion types:
  - Percentage discounts
  - Fixed amount discounts
  - Buy-one-get-one offers
  - Free items
  - Minimum spend rewards
  - Happy hour specials
- Promotion scheduling
- Usage tracking
- Performance analytics

## Technical Details

### API Endpoints

#### Restaurant Endpoints
- `POST /api/restaurants` - Create restaurant
- `GET /api/restaurants` - List restaurants (with filtering)
- `GET /api/restaurants/{id}` - Get restaurant details
- `PUT /api/restaurants/{id}` - Update restaurant
- `DELETE /api/restaurants/{id}` - Delete restaurant

#### Menu Endpoints
- `POST /api/restaurants/{id}/menu-items` - Add menu item
- `GET /api/restaurants/{id}/menu-items` - List menu items
- `PUT /api/restaurants/{id}/menu-items/{itemId}` - Update menu item
- `DELETE /api/restaurants/{id}/menu-items/{itemId}` - Delete menu item

#### Table Endpoints
- `POST /api/restaurants/{id}/tables` - Add table
- `GET /api/restaurants/{id}/tables` - List tables
- `PUT /api/restaurants/{id}/tables/{tableId}` - Update table
- `DELETE /api/restaurants/{id}/tables/{tableId}` - Delete table

#### Staff Endpoints
- `POST /api/restaurants/{id}/staff` - Add staff member
- `GET /api/restaurants/{id}/staff` - List staff
- `PUT /api/restaurants/{id}/staff/{staffId}` - Update staff
- `DELETE /api/restaurants/{id}/staff/{staffId}` - Delete staff
- `POST /api/restaurants/{id}/staff/{staffId}/schedule` - Create schedule
- `GET /api/restaurants/{id}/staff/{staffId}/schedule` - Get schedules
- `POST /api/restaurants/{id}/staff/{staffId}/performance` - Add performance review
- `GET /api/restaurants/{id}/staff/{staffId}/performance` - Get performance reviews

### Data Models

- Restaurant
- MenuItem
- Table
- Reservation
- Staff
- Review
- Promotion

### Features

#### Validation
- Comprehensive input validation
- Custom validators for:
  - Phone numbers
  - Email addresses
  - Opening hours
  - Coordinates
  - Prices
  - Ratings
  - Capacities

#### Pagination
- Cursor-based pagination
- Sorting options
- Filtering capabilities
- Search functionality

#### Database
- MongoDB with proper indexing
- Geospatial queries
- Text search capabilities
- Efficient query optimization

## Getting Started

### Prerequisites
- Python 3.8+
- MongoDB
- FastAPI
- Motor (async MongoDB driver)

### Environment Variables
```env
# Server Configuration
PORT=3002
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/restaurant-service?retryWrites=true&w=majority

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
# Install dependencies
pip install -r requirements.txt

# Start the service
uvicorn main:app --host 0.0.0.0 --port 3002 --reload
```

### API Documentation
Once the service is running, visit:
- Swagger UI: `http://localhost:3002/docs`
- ReDoc: `http://localhost:3002/redoc`

## Testing
```bash
# Run tests
pytest

# Run with coverage
pytest --cov=src
``` 