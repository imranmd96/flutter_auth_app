# Geolocation Service

A microservice for handling location-based operations in the ForkLine platform, implemented using Clean Architecture principles.

## Architecture

This service follows Clean Architecture principles, which provides a clear separation of concerns and maintains independence of business rules from external frameworks and tools.

### Layers

1. **Domain Layer** (`internal/domain/`)
   - Contains business entities and rules
   - Defines repository interfaces
   - Has no dependencies on other layers
   - Files:
     - `models/location.go`: Core business entities
     - `interfaces/repository.go`: Repository interfaces

2. **Application Layer** (`internal/application/`)
   - Implements use cases and orchestrates domain objects
   - Depends only on the domain layer
   - Files:
     - `services/location_service.go`: Business logic implementation

3. **Infrastructure Layer** (`internal/infrastructure/`)
   - Implements repository interfaces
   - Handles external services and data persistence
   - Files:
     - `persistence/mongodb/location_repository.go`: MongoDB implementation
     - `cache/redis/cache_repository.go`: Redis cache implementation
     - `external/google_maps/external_service.go`: Google Maps API integration

4. **Interface Layer** (`internal/interfaces/`)
   - Manages HTTP/API concerns
   - Converts between DTOs and domain objects
   - Files:
     - `http/handlers/location_handler.go`: HTTP request handlers

### Benefits

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Rule**: Inner layers don't depend on outer layers
- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Framework Independence**: Business logic is isolated from external frameworks

## API Endpoints

- `POST /api/v1/locations/distance`: Calculate distance between two points
- `POST /api/v1/locations/nearby`: Find nearby locations
- `POST /api/v1/locations/validate`: Validate an address
- `POST /api/v1/locations/geocode`: Convert address to coordinates
- `POST /api/v1/locations/reverse-geocode`: Convert coordinates to address
- `GET /health`: Health check endpoint

## Dependencies

- MongoDB: For persistent storage
- Redis: For caching
- Google Maps API: For geocoding and routing

## Configuration

The service uses environment variables for configuration. See `.env.example` for available options.

## Development

1. Install dependencies:
   ```bash
   go mod download
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. Run the service:
   ```bash
   go run cmd/main.go
   ```

## Docker

Development:
```bash
docker build -f Dockerfile.dev -t geolocation-service:dev .
docker run -p 3014:3014 geolocation-service:dev
```

Production:
```bash
docker build -t geolocation-service .
docker run -p 3014:3014 geolocation-service
```

## Testing

```bash
go test ./...
```

## License

MIT 