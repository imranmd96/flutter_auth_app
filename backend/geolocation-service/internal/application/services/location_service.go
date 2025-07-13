package services

import (
	"context"
	"math"
	"time"

	"forkLine/backend/geolocation-service/internal/domain/interfaces"
	"forkLine/backend/geolocation-service/internal/domain/models"
)

// LocationService handles location-related business logic
type LocationService struct {
	locationRepo    interfaces.LocationRepository
	cacheRepo       interfaces.CacheRepository
	externalService interfaces.ExternalServiceRepository
}

// NewLocationService creates a new instance of LocationService
func NewLocationService(
	locationRepo interfaces.LocationRepository,
	cacheRepo interfaces.CacheRepository,
	externalService interfaces.ExternalServiceRepository,
) *LocationService {
	return &LocationService{
		locationRepo:    locationRepo,
		cacheRepo:       cacheRepo,
		externalService: externalService,
	}
}

// CalculateDistance calculates the distance between two points
func (s *LocationService) CalculateDistance(ctx context.Context, origin, destination *models.Location) (float64, float64, error) {
	distance := calculateHaversineDistance(*origin, *destination)
	duration := distance / 30.0 * 60 // Assuming 30 km/h average speed
	return distance, duration, nil
}

// FindNearbyLocations finds nearby locations within a specified radius
func (s *LocationService) FindNearbyLocations(ctx context.Context, location models.Location, radius float64, locationType string) (interface{}, error) {
	if locationType == "restaurant" {
		return s.locationRepo.FindNearbyRestaurants(ctx, location, radius)
	}
	return s.locationRepo.FindNearbyDrivers(ctx, location, radius)
}

// ValidateAddress validates a given address
func (s *LocationService) ValidateAddress(ctx context.Context, address *models.Address) (*models.Address, error) {
	// Check cache first
	addressHash := generateAddressHash(address)
	if cachedAddress, err := s.cacheRepo.GetAddressValidation(ctx, addressHash); err == nil {
		return cachedAddress, nil
	}

	// Validate using external service
	validatedAddress, err := s.externalService.ValidateAddress(ctx, address)
	if err != nil {
		return nil, err
	}

	// Cache the result
	if err := s.cacheRepo.SetAddressValidation(ctx, addressHash, validatedAddress); err != nil {
		// Log cache error but don't fail the request
	}

	return validatedAddress, nil
}

// GeocodeAddress converts an address to coordinates
func (s *LocationService) GeocodeAddress(ctx context.Context, address *models.Address) (*models.Location, error) {
	// Check cache first
	addressHash := generateAddressHash(address)
	if cachedLocation, err := s.cacheRepo.GetGeocoding(ctx, addressHash); err == nil {
		return cachedLocation, nil
	}

	// Geocode using external service
	location, err := s.externalService.GeocodeAddress(ctx, address)
	if err != nil {
		return nil, err
	}

	// Cache the result
	if err := s.cacheRepo.SetGeocoding(ctx, addressHash, location); err != nil {
		// Log cache error but don't fail the request
	}

	return location, nil
}

// ReverseGeocode converts coordinates to an address
func (s *LocationService) ReverseGeocode(ctx context.Context, location *models.Location) (*models.Address, error) {
	// Check cache first
	locationHash := generateLocationHash(location)
	if cachedAddress, err := s.cacheRepo.GetReverseGeocoding(ctx, locationHash); err == nil {
		return cachedAddress, nil
	}

	// Reverse geocode using external service
	address, err := s.externalService.ReverseGeocode(ctx, location)
	if err != nil {
		return nil, err
	}

	// Cache the result
	if err := s.cacheRepo.SetReverseGeocoding(ctx, locationHash, address); err != nil {
		// Log cache error but don't fail the request
	}

	return address, nil
}

// Helper function to calculate Haversine distance
func calculateHaversineDistance(origin, destination models.Location) float64 {
	const R = 6371 // Earth's radius in kilometers

	lat1 := origin.Latitude * math.Pi / 180
	lat2 := destination.Latitude * math.Pi / 180
	deltaLat := (destination.Latitude - origin.Latitude) * math.Pi / 180
	deltaLon := (destination.Longitude - origin.Longitude) * math.Pi / 180

	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) +
		math.Cos(lat1)*math.Cos(lat2)*
			math.Sin(deltaLon/2)*math.Sin(deltaLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return R * c
}

// Helper function to generate address hash
func generateAddressHash(address *models.Address) string {
	// Implement a proper hashing function
	return address.FormattedAddress
}

// Helper function to generate location hash
func generateLocationHash(location *models.Location) string {
	// Implement a proper hashing function
	return string(location.Latitude) + "," + string(location.Longitude)
} 