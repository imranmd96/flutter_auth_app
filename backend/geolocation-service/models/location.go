package models

import (
	"time"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Location represents a geographical point
type Location struct {
	Latitude  float64 `json:"latitude" bson:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" bson:"longitude" binding:"required"`
}

// Address represents a physical address
type Address struct {
	Street          string `json:"street" bson:"street" binding:"required"`
	City            string `json:"city" bson:"city" binding:"required"`
	State           string `json:"state" bson:"state" binding:"required"`
	Country         string `json:"country" bson:"country" binding:"required"`
	PostalCode      string `json:"postal_code" bson:"postal_code" binding:"required"`
	FormattedAddress string `json:"formatted_address,omitempty" bson:"formatted_address,omitempty"`
}

// DistanceRequest represents a request to calculate distance
type DistanceRequest struct {
	Origin      Location `json:"origin" binding:"required"`
	Destination Location `json:"destination" binding:"required"`
}

// DistanceResponse represents the response for distance calculation
type DistanceResponse struct {
	Distance float64 `json:"distance"` // in kilometers
	Duration float64 `json:"duration"` // in minutes
}

// NearbyRequest represents a request to find nearby locations
type NearbyRequest struct {
	Location Location `json:"location" binding:"required"`
	Radius   float64  `json:"radius" binding:"required,min=0,max=50"` // in kilometers
	Type     string   `json:"type" binding:"required,oneof=restaurant driver"`
}

// GeocodeRequest represents a request to geocode an address
type GeocodeRequest struct {
	Address Address `json:"address" binding:"required"`
}

// GeocodeResponse represents the response for geocoding
type GeocodeResponse struct {
	Location Location `json:"location"`
	Address  Address  `json:"address"`
}

// RestaurantLocation represents a restaurant's location
type RestaurantLocation struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	RestaurantID string            `json:"restaurant_id" bson:"restaurant_id" binding:"required"`
	Location     Location          `json:"location" bson:"location" binding:"required"`
	Address      Address           `json:"address" bson:"address" binding:"required"`
	CreatedAt    time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at" bson:"updated_at"`
}

// DriverLocation represents a driver's location
type DriverLocation struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	DriverID    string            `json:"driver_id" bson:"driver_id" binding:"required"`
	Location    Location          `json:"location" bson:"location" binding:"required"`
	LastUpdated time.Time         `json:"last_updated" bson:"last_updated"`
	Status      string            `json:"status" bson:"status" binding:"required,oneof=available busy offline"`
}

// DeliveryZone represents a delivery zone
type DeliveryZone struct {
	ID            primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	RestaurantID  string            `json:"restaurant_id" bson:"restaurant_id" binding:"required"`
	Name          string            `json:"name" bson:"name" binding:"required"`
	Geometry      interface{}       `json:"geometry" bson:"geometry" binding:"required"` // GeoJSON polygon
	DeliveryFee   float64           `json:"delivery_fee" bson:"delivery_fee" binding:"required"`
	MinimumOrder  float64           `json:"minimum_order" bson:"minimum_order" binding:"required"`
	EstimatedTime int               `json:"estimated_time" bson:"estimated_time" binding:"required"` // in minutes
	CreatedAt     time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt     time.Time         `json:"updated_at" bson:"updated_at"`
}

// DeliveryTimeRequest represents a request to estimate delivery time
type DeliveryTimeRequest struct {
	Origin       Location `json:"origin" binding:"required"`
	Destination  Location `json:"destination" binding:"required"`
	RestaurantID string   `json:"restaurant_id" binding:"required"`
}

// DeliveryTimeResponse represents the response for delivery time estimation
type DeliveryTimeResponse struct {
	EstimatedTime int     `json:"estimated_time"` // in minutes
	Distance      float64 `json:"distance"`       // in kilometers
	DeliveryFee   float64 `json:"delivery_fee"`
}

// RouteOptimizationRequest represents a request to optimize delivery route
type RouteOptimizationRequest struct {
	RestaurantLocation Location   `json:"restaurant_location" binding:"required"`
	DeliveryLocations  []Location `json:"delivery_locations" binding:"required,min=1"`
	DriverID          string     `json:"driver_id" binding:"required"`
}

// RouteOptimizationResponse represents the response for route optimization
type RouteOptimizationResponse struct {
	OptimizedRoute    []Location `json:"optimized_route"`
	TotalDistance     float64    `json:"total_distance"`     // in kilometers
	EstimatedDuration int        `json:"estimated_duration"` // in minutes
} 