package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"forkLine/backend/geolocation-service/config"
	"forkLine/backend/geolocation-service/models"
)

type DeliveryHandler struct {
	db     *mongo.Database
	redis  *redis.Client
	config *config.Config
}

func NewDeliveryHandler(db *mongo.Database, redis *redis.Client, config *config.Config) *DeliveryHandler {
	return &DeliveryHandler{
		db:     db,
		redis:  redis,
		config: config,
	}
}

// EstimateDeliveryTime estimates delivery time for an order
func (h *DeliveryHandler) EstimateDeliveryTime(c *gin.Context) {
	var req models.DeliveryTimeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get restaurant location
	var restaurantLocation models.RestaurantLocation
	err := h.db.Collection("restaurant_locations").FindOne(context.Background(), bson.M{"restaurant_id": req.RestaurantID}).Decode(&restaurantLocation)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get restaurant location"})
		return
	}

	// Calculate distance from restaurant to destination
	distance := calculateHaversineDistance(restaurantLocation.Location, req.Destination)

	// Get delivery zone
	var deliveryZone models.DeliveryZone
	err = h.db.Collection("delivery_zones").FindOne(context.Background(), bson.M{
		"restaurant_id": req.RestaurantID,
		"geometry": bson.M{
			"$geoIntersects": bson.M{
				"$geometry": bson.M{
					"type":        "Point",
					"coordinates": []float64{req.Destination.Longitude, req.Destination.Latitude},
				},
			},
		},
	}).Decode(&deliveryZone)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Delivery location is not in any delivery zone"})
		return
	}

	// Calculate estimated time
	estimatedTime := int(distance / h.config.Location.DefaultDeliverySpeed * 60) // Convert to minutes
	if estimatedTime < deliveryZone.EstimatedTime {
		estimatedTime = deliveryZone.EstimatedTime
	}

	c.JSON(http.StatusOK, models.DeliveryTimeResponse{
		EstimatedTime: estimatedTime,
		Distance:      distance,
		DeliveryFee:   deliveryZone.DeliveryFee,
	})
}

// OptimizeDeliveryRoute optimizes the delivery route for multiple orders
func (h *DeliveryHandler) OptimizeDeliveryRoute(c *gin.Context) {
	var req models.RouteOptimizationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get driver's current location
	var driverLocation models.DriverLocation
	err := h.db.Collection("driver_locations").FindOne(context.Background(), bson.M{"driver_id": req.DriverID}).Decode(&driverLocation)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get driver location"})
		return
	}

	// Simple nearest neighbor algorithm for route optimization
	locations := append([]models.Location{driverLocation.Location}, req.DeliveryLocations...)
	optimizedRoute := make([]models.Location, 0, len(locations))
	visited := make(map[int]bool)

	current := 0
	optimizedRoute = append(optimizedRoute, locations[current])
	visited[current] = true

	for len(visited) < len(locations) {
		next := -1
		minDist := float64(1<<63 - 1)

		for i, loc := range locations {
			if visited[i] {
				continue
			}

			dist := calculateHaversineDistance(locations[current], loc)
			if dist < minDist {
				minDist = dist
				next = i
			}
		}

		if next == -1 {
			break
		}

		optimizedRoute = append(optimizedRoute, locations[next])
		visited[next] = true
		current = next
	}

	// Calculate total distance and duration
	totalDistance := 0.0
	for i := 0; i < len(optimizedRoute)-1; i++ {
		totalDistance += calculateHaversineDistance(optimizedRoute[i], optimizedRoute[i+1])
	}

	estimatedDuration := int(totalDistance / h.config.Location.DefaultDeliverySpeed * 60) // Convert to minutes

	c.JSON(http.StatusOK, models.RouteOptimizationResponse{
		OptimizedRoute:    optimizedRoute,
		TotalDistance:     totalDistance,
		EstimatedDuration: estimatedDuration,
	})
}

// UpdateDriverLocation updates a driver's location
func (h *DeliveryHandler) UpdateDriverLocation(c *gin.Context) {
	driverID := c.Param("id")

	var location models.DriverLocation
	if err := c.ShouldBindJSON(&location); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location.DriverID = driverID
	location.LastUpdated = time.Now()

	opts := options.Update().SetUpsert(true)
	_, err := h.db.Collection("driver_locations").UpdateOne(
		context.Background(),
		bson.M{"driver_id": driverID},
		bson.M{"$set": location},
		opts,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, location)
}

// GetDriverLocation gets a driver's current location
func (h *DeliveryHandler) GetDriverLocation(c *gin.Context) {
	driverID := c.Param("id")

	var location models.DriverLocation
	err := h.db.Collection("driver_locations").FindOne(context.Background(), bson.M{"driver_id": driverID}).Decode(&location)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Driver location not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, location)
}
