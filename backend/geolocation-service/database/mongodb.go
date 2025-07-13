package database

import (
	"context"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// InitializeMongoDB initializes MongoDB connection and creates necessary indexes
func InitializeMongoDB(uri string) (*mongo.Client, error) {
	// Set client options
	clientOptions := options.Client().ApplyURI(uri)

	// Connect to MongoDB
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, err
	}

	// Ping the database
	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}

	log.Println("Connected to MongoDB!")

	return client, nil
}

// CreateIndexes creates necessary indexes for the collections
func CreateIndexes(db *mongo.Database) error {
	ctx := context.Background()

	// Restaurant locations collection
	restaurantLocations := db.Collection("restaurant_locations")
	_, err := restaurantLocations.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{
				{Key: "location", Value: "2dsphere"},
			},
		},
		{
			Keys: bson.D{
				{Key: "restaurant_id", Value: 1},
			},
			Options: options.Index().SetUnique(true),
		},
	})
	if err != nil {
		return err
	}

	// Driver locations collection
	driverLocations := db.Collection("driver_locations")
	_, err = driverLocations.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{
				{Key: "location", Value: "2dsphere"},
			},
		},
		{
			Keys: bson.D{
				{Key: "driver_id", Value: 1},
			},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{
				{Key: "last_updated", Value: 1},
			},
		},
	})
	if err != nil {
		return err
	}

	// Delivery zones collection
	deliveryZones := db.Collection("delivery_zones")
	_, err = deliveryZones.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{
				{Key: "geometry", Value: "2dsphere"},
			},
		},
		{
			Keys: bson.D{
				{Key: "restaurant_id", Value: 1},
			},
		},
	})
	if err != nil {
		return err
	}

	// Address validation cache collection
	addressCache := db.Collection("address_validation_cache")
	_, err = addressCache.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{
				{Key: "address_hash", Value: 1},
			},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{
				{Key: "created_at", Value: 1},
			},
			Options: options.Index().SetExpireAfterSeconds(86400), // 24 hours
		},
	})
	if err != nil {
		return err
	}

	// Geocoding cache collection
	geocodingCache := db.Collection("geocoding_cache")
	_, err = geocodingCache.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{
				{Key: "query_hash", Value: 1},
			},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{
				{Key: "created_at", Value: 1},
			},
			Options: options.Index().SetExpireAfterSeconds(86400), // 24 hours
		},
	})
	if err != nil {
		return err
	}

	log.Println("Created all necessary indexes!")
	return nil
} 