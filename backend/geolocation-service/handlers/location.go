package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"

	"forkLine/backend/geolocation-service/config"
	"forkLine/backend/geolocation-service/models"
)

type LocationHandler struct {
	db     *mongo.Database
	redis  *redis.Client
	config *config.Config
}

func NewLocationHandler(db *mongo.Database, redis *redis.Client, config *config.Config) *LocationHandler {
	return &LocationHandler{
		db:     db,
		redis:  redis,
		config: config,
	}
}

// CalculateDistance calculates the distance between two points
func (h *LocationHandler) CalculateDistance(c *gin.Context) {
	var req models.DistanceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	distance := calculateHaversineDistance(req.Origin, req.Destination)
	duration := distance / h.config.Location.DefaultDeliverySpeed * 60 // Convert to minutes

	c.JSON(http.StatusOK, models.DistanceResponse{
		Distance: distance,
		Duration: duration,
	})
}

// FindNearby finds nearby locations within a specified radius
func (h *LocationHandler) FindNearby(c *gin.Context) {
	var req models.NearbyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	collection := h.db.Collection("restaurant_locations")
	if req.Type == "driver" {
		collection = h.db.Collection("driver_locations")
	}

	filter := bson.M{
		"location": bson.M{
			"$near": bson.M{
				"$geometry": bson.M{
					"type":        "Point",
					"coordinates": []float64{req.Location.Longitude, req.Location.Latitude},
				},
				"$maxDistance": req.Radius * 1000, // Convert km to meters
			},
		},
	}

	cursor, err := collection.Find(context.Background(), filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer cursor.Close(context.Background())

	var results []bson.M
	if err := cursor.All(context.Background(), &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, results)
}

// ValidateAddress validates a given address
func (h *LocationHandler) ValidateAddress(c *gin.Context) {
	var req models.GeocodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check cache first
	cacheKey := "address:" + req.Address.FormattedAddress
	cachedResult, err := h.redis.Get(context.Background(), cacheKey).Result()
	if err == nil {
		var result models.GeocodeResponse
		if err := json.Unmarshal([]byte(cachedResult), &result); err == nil {
			c.JSON(http.StatusOK, result)
			return
		}
	}

	// TODO: Implement actual address validation using Google Maps API
	// For now, return a mock response
	result := models.GeocodeResponse{
		Location: models.Location{
			Latitude:  37.7749,
			Longitude: -122.4194,
		},
		Address: req.Address,
	}

	// Cache the result
	if resultJSON, err := json.Marshal(result); err == nil {
		h.redis.Set(context.Background(), cacheKey, resultJSON, time.Hour*24)
	}

	c.JSON(http.StatusOK, result)
}

// Geocode converts an address to coordinates
func (h *LocationHandler) Geocode(c *gin.Context) {
	var req models.GeocodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check cache first
	cacheKey := "geocode:" + req.Address.FormattedAddress
	cachedResult, err := h.redis.Get(context.Background(), cacheKey).Result()
	if err == nil {
		var result models.GeocodeResponse
		if err := json.Unmarshal([]byte(cachedResult), &result); err == nil {
			c.JSON(http.StatusOK, result)
			return
		}
	}

	// TODO: Implement actual geocoding using Google Maps API
	// For now, return a mock response
	result := models.GeocodeResponse{
		Location: models.Location{
			Latitude:  37.7749,
			Longitude: -122.4194,
		},
		Address: req.Address,
	}

	// Cache the result
	if resultJSON, err := json.Marshal(result); err == nil {
		h.redis.Set(context.Background(), cacheKey, resultJSON, time.Hour*24)
	}

	c.JSON(http.StatusOK, result)
}

// ReverseGeocode converts coordinates to an address
func (h *LocationHandler) ReverseGeocode(c *gin.Context) {
	var req models.Location
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check cache first
	cacheKey := "reverse_geocode:" + fmt.Sprintf("%.6f", req.Latitude) + "," + fmt.Sprintf("%.6f", req.Longitude)
	cachedResult, err := h.redis.Get(context.Background(), cacheKey).Result()
	if err == nil {
		var result models.GeocodeResponse
		if err := json.Unmarshal([]byte(cachedResult), &result); err == nil {
			c.JSON(http.StatusOK, result)
			return
		}
	}

	// TODO: Implement actual reverse geocoding using Google Maps API
	// For now, return a mock response
	result := models.GeocodeResponse{
		Location: req,
		Address: models.Address{
			Street:           "123 Main St",
			City:             "San Francisco",
			State:            "CA",
			Country:          "USA",
			PostalCode:       "94105",
			FormattedAddress: "123 Main St, San Francisco, CA 94105, USA",
		},
	}

	// Cache the result
	if resultJSON, err := json.Marshal(result); err == nil {
		h.redis.Set(context.Background(), cacheKey, resultJSON, time.Hour*24)
	}

	c.JSON(http.StatusOK, result)
}

// Helper function to calculate Haversine distance between two points
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
