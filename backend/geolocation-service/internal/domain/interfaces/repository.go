package interfaces

import (
	"context"
	"forkLine/backend/geolocation-service/models"
)

// LocationRepository defines the interface for location data operations
type LocationRepository interface {
	Create(ctx context.Context, location *models.Location) error
	GetByID(ctx context.Context, id string) (*models.Location, error)
	GetByUserID(ctx context.Context, userID string) ([]*models.Location, error)
	GetNearby(ctx context.Context, lat, lng float64, radius float64) ([]*models.Location, error)
	Update(ctx context.Context, location *models.Location) error
	Delete(ctx context.Context, id string) error
}

// GeolocationService defines the interface for geolocation services
type GeolocationService interface {
	GetLocation(ctx context.Context, address string) (*models.Location, error)
	GetAddress(ctx context.Context, lat, lng float64) (*models.Address, error)
	CalculateDistance(ctx context.Context, from, to *models.Location) (float64, error)
}
