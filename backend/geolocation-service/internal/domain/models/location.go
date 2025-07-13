package models

import (
	"time"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Location represents a geographical point
type Location struct {
	Latitude  float64 `json:"latitude" bson:"latitude"`
	Longitude float64 `json:"longitude" bson:"longitude"`
}

// Address represents a physical address
type Address struct {
	Street          string `json:"street" bson:"street"`
	City            string `json:"city" bson:"city"`
	State           string `json:"state" bson:"state"`
	Country         string `json:"country" bson:"country"`
	PostalCode      string `json:"postal_code" bson:"postal_code"`
	FormattedAddress string `json:"formatted_address,omitempty" bson:"formatted_address,omitempty"`
}

// RestaurantLocation represents a restaurant's location
type RestaurantLocation struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	RestaurantID string            `json:"restaurant_id" bson:"restaurant_id"`
	Location     Location          `json:"location" bson:"location"`
	Address      Address           `json:"address" bson:"address"`
	CreatedAt    time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at" bson:"updated_at"`
}

// DriverLocation represents a driver's location
type DriverLocation struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	DriverID    string            `json:"driver_id" bson:"driver_id"`
	Location    Location          `json:"location" bson:"location"`
	LastUpdated time.Time         `json:"last_updated" bson:"last_updated"`
	Status      string            `json:"status" bson:"status"`
}

// DeliveryZone represents a delivery zone
type DeliveryZone struct {
	ID            primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	RestaurantID  string            `json:"restaurant_id" bson:"restaurant_id"`
	Name          string            `json:"name" bson:"name"`
	Geometry      interface{}       `json:"geometry" bson:"geometry"` // GeoJSON polygon
	DeliveryFee   float64           `json:"delivery_fee" bson:"delivery_fee"`
	MinimumOrder  float64           `json:"minimum_order" bson:"minimum_order"`
	EstimatedTime int               `json:"estimated_time" bson:"estimated_time"` // in minutes
	CreatedAt     time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt     time.Time         `json:"updated_at" bson:"updated_at"`
} 