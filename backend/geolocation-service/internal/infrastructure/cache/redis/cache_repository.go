package redis

import (
	"context"
	"encoding/json"
	"time"

	"github.com/go-redis/redis/v8"
	"forkLine/backend/geolocation-service/internal/domain/interfaces"
	"forkLine/backend/geolocation-service/internal/domain/models"
)

// CacheRepository implements the CacheRepository interface
type CacheRepository struct {
	client *redis.Client
	ttl    time.Duration
}

// NewCacheRepository creates a new instance of CacheRepository
func NewCacheRepository(client *redis.Client, ttl time.Duration) interfaces.CacheRepository {
	return &CacheRepository{
		client: client,
		ttl:    ttl,
	}
}

// GetAddressValidation gets address validation from cache
func (r *CacheRepository) GetAddressValidation(ctx context.Context, addressHash string) (*models.Address, error) {
	key := "address:" + addressHash
	data, err := r.client.Get(ctx, key).Bytes()
	if err != nil {
		return nil, err
	}

	var address models.Address
	if err := json.Unmarshal(data, &address); err != nil {
		return nil, err
	}

	return &address, nil
}

// SetAddressValidation sets address validation in cache
func (r *CacheRepository) SetAddressValidation(ctx context.Context, addressHash string, address *models.Address) error {
	key := "address:" + addressHash
	data, err := json.Marshal(address)
	if err != nil {
		return err
	}

	return r.client.Set(ctx, key, data, r.ttl).Err()
}

// GetGeocoding gets geocoding result from cache
func (r *CacheRepository) GetGeocoding(ctx context.Context, queryHash string) (*models.Location, error) {
	key := "geocode:" + queryHash
	data, err := r.client.Get(ctx, key).Bytes()
	if err != nil {
		return nil, err
	}

	var location models.Location
	if err := json.Unmarshal(data, &location); err != nil {
		return nil, err
	}

	return &location, nil
}

// SetGeocoding sets geocoding result in cache
func (r *CacheRepository) SetGeocoding(ctx context.Context, queryHash string, location *models.Location) error {
	key := "geocode:" + queryHash
	data, err := json.Marshal(location)
	if err != nil {
		return err
	}

	return r.client.Set(ctx, key, data, r.ttl).Err()
}

// GetReverseGeocoding gets reverse geocoding result from cache
func (r *CacheRepository) GetReverseGeocoding(ctx context.Context, locationHash string) (*models.Address, error) {
	key := "reverse_geocode:" + locationHash
	data, err := r.client.Get(ctx, key).Bytes()
	if err != nil {
		return nil, err
	}

	var address models.Address
	if err := json.Unmarshal(data, &address); err != nil {
		return nil, err
	}

	return &address, nil
}

// SetReverseGeocoding sets reverse geocoding result in cache
func (r *CacheRepository) SetReverseGeocoding(ctx context.Context, locationHash string, address *models.Address) error {
	key := "reverse_geocode:" + locationHash
	data, err := json.Marshal(address)
	if err != nil {
		return err
	}

	return r.client.Set(ctx, key, data, r.ttl).Err()
} 