package mongodb

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"forkLine/backend/geolocation-service/internal/domain/interfaces"
	"forkLine/backend/geolocation-service/internal/domain/models"
)

// LocationRepository implements the LocationRepository interface
type LocationRepository struct {
	db *mongo.Database
}

// NewLocationRepository creates a new instance of LocationRepository
func NewLocationRepository(db *mongo.Database) interfaces.LocationRepository {
	return &LocationRepository{
		db: db,
	}
}

// CreateRestaurantLocation creates a new restaurant location
func (r *LocationRepository) CreateRestaurantLocation(ctx context.Context, location *models.RestaurantLocation) error {
	location.CreatedAt = time.Now()
	location.UpdatedAt = time.Now()

	_, err := r.db.Collection("restaurant_locations").InsertOne(ctx, location)
	return err
}

// GetRestaurantLocation gets a restaurant's location by ID
func (r *LocationRepository) GetRestaurantLocation(ctx context.Context, restaurantID string) (*models.RestaurantLocation, error) {
	var location models.RestaurantLocation
	err := r.db.Collection("restaurant_locations").FindOne(ctx, bson.M{"restaurant_id": restaurantID}).Decode(&location)
	if err != nil {
		return nil, err
	}
	return &location, nil
}

// UpdateRestaurantLocation updates a restaurant's location
func (r *LocationRepository) UpdateRestaurantLocation(ctx context.Context, location *models.RestaurantLocation) error {
	location.UpdatedAt = time.Now()

	_, err := r.db.Collection("restaurant_locations").UpdateOne(
		ctx,
		bson.M{"restaurant_id": location.RestaurantID},
		bson.M{"$set": location},
	)
	return err
}

// DeleteRestaurantLocation deletes a restaurant's location
func (r *LocationRepository) DeleteRestaurantLocation(ctx context.Context, restaurantID string) error {
	_, err := r.db.Collection("restaurant_locations").DeleteOne(ctx, bson.M{"restaurant_id": restaurantID})
	return err
}

// FindNearbyRestaurants finds nearby restaurants within a specified radius
func (r *LocationRepository) FindNearbyRestaurants(ctx context.Context, location models.Location, radius float64) ([]*models.RestaurantLocation, error) {
	filter := bson.M{
		"location": bson.M{
			"$near": bson.M{
				"$geometry": bson.M{
					"type":        "Point",
					"coordinates": []float64{location.Longitude, location.Latitude},
				},
				"$maxDistance": radius * 1000, // Convert km to meters
			},
		},
	}

	cursor, err := r.db.Collection("restaurant_locations").Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var locations []*models.RestaurantLocation
	if err := cursor.All(ctx, &locations); err != nil {
		return nil, err
	}

	return locations, nil
}

// UpdateDriverLocation updates a driver's location
func (r *LocationRepository) UpdateDriverLocation(ctx context.Context, location *models.DriverLocation) error {
	location.LastUpdated = time.Now()

	opts := options.Update().SetUpsert(true)
	_, err := r.db.Collection("driver_locations").UpdateOne(
		ctx,
		bson.M{"driver_id": location.DriverID},
		bson.M{"$set": location},
		opts,
	)
	return err
}

// GetDriverLocation gets a driver's current location
func (r *LocationRepository) GetDriverLocation(ctx context.Context, driverID string) (*models.DriverLocation, error) {
	var location models.DriverLocation
	err := r.db.Collection("driver_locations").FindOne(ctx, bson.M{"driver_id": driverID}).Decode(&location)
	if err != nil {
		return nil, err
	}
	return &location, nil
}

// FindNearbyDrivers finds nearby drivers within a specified radius
func (r *LocationRepository) FindNearbyDrivers(ctx context.Context, location models.Location, radius float64) ([]*models.DriverLocation, error) {
	filter := bson.M{
		"location": bson.M{
			"$near": bson.M{
				"$geometry": bson.M{
					"type":        "Point",
					"coordinates": []float64{location.Longitude, location.Latitude},
				},
				"$maxDistance": radius * 1000, // Convert km to meters
			},
		},
	}

	cursor, err := r.db.Collection("driver_locations").Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var locations []*models.DriverLocation
	if err := cursor.All(ctx, &locations); err != nil {
		return nil, err
	}

	return locations, nil
}

// CreateDeliveryZone creates a new delivery zone
func (r *LocationRepository) CreateDeliveryZone(ctx context.Context, zone *models.DeliveryZone) error {
	zone.CreatedAt = time.Now()
	zone.UpdatedAt = time.Now()

	_, err := r.db.Collection("delivery_zones").InsertOne(ctx, zone)
	return err
}

// GetDeliveryZones gets all delivery zones for a restaurant
func (r *LocationRepository) GetDeliveryZones(ctx context.Context, restaurantID string) ([]*models.DeliveryZone, error) {
	cursor, err := r.db.Collection("delivery_zones").Find(ctx, bson.M{"restaurant_id": restaurantID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var zones []*models.DeliveryZone
	if err := cursor.All(ctx, &zones); err != nil {
		return nil, err
	}

	return zones, nil
}

// UpdateDeliveryZone updates a delivery zone
func (r *LocationRepository) UpdateDeliveryZone(ctx context.Context, zone *models.DeliveryZone) error {
	zone.UpdatedAt = time.Now()

	_, err := r.db.Collection("delivery_zones").UpdateOne(
		ctx,
		bson.M{"_id": zone.ID},
		bson.M{"$set": zone},
	)
	return err
}

// DeleteDeliveryZone deletes a delivery zone
func (r *LocationRepository) DeleteDeliveryZone(ctx context.Context, zoneID string) error {
	id, err := primitive.ObjectIDFromHex(zoneID)
	if err != nil {
		return err
	}

	_, err = r.db.Collection("delivery_zones").DeleteOne(ctx, bson.M{"_id": id})
	return err
}

// FindDeliveryZoneByLocation finds a delivery zone containing the given location
func (r *LocationRepository) FindDeliveryZoneByLocation(ctx context.Context, location models.Location, restaurantID string) (*models.DeliveryZone, error) {
	filter := bson.M{
		"restaurant_id": restaurantID,
		"geometry": bson.M{
			"$geoIntersects": bson.M{
				"$geometry": bson.M{
					"type":        "Point",
					"coordinates": []float64{location.Longitude, location.Latitude},
				},
			},
		},
	}

	var zone models.DeliveryZone
	err := r.db.Collection("delivery_zones").FindOne(ctx, filter).Decode(&zone)
	if err != nil {
		return nil, err
	}

	return &zone, nil
} 