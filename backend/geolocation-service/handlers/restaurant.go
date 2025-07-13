package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"github.com/go-redis/redis/v8"

	"forkLine/backend/geolocation-service/models"
	"forkLine/backend/geolocation-service/config"
)

type RestaurantHandler struct {
	db     *mongo.Database
	redis  *redis.Client
	config *config.Config
}

func NewRestaurantHandler(db *mongo.Database, redis *redis.Client, config *config.Config) *RestaurantHandler {
	return &RestaurantHandler{
		db:     db,
		redis:  redis,
		config: config,
	}
}

// CreateRestaurantLocation creates a new restaurant location
func (h *RestaurantHandler) CreateRestaurantLocation(c *gin.Context) {
	var location models.RestaurantLocation
	if err := c.ShouldBindJSON(&location); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location.CreatedAt = time.Now()
	location.UpdatedAt = time.Now()

	result, err := h.db.Collection("restaurant_locations").InsertOne(context.Background(), location)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	location.ID = result.InsertedID.(primitive.ObjectID)
	c.JSON(http.StatusCreated, location)
}

// GetRestaurantLocation gets a restaurant's location by ID
func (h *RestaurantHandler) GetRestaurantLocation(c *gin.Context) {
	restaurantID := c.Param("id")

	var location models.RestaurantLocation
	err := h.db.Collection("restaurant_locations").FindOne(context.Background(), bson.M{"restaurant_id": restaurantID}).Decode(&location)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Restaurant location not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, location)
}

// UpdateRestaurantLocation updates a restaurant's location
func (h *RestaurantHandler) UpdateRestaurantLocation(c *gin.Context) {
	restaurantID := c.Param("id")

	var location models.RestaurantLocation
	if err := c.ShouldBindJSON(&location); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location.UpdatedAt = time.Now()

	result, err := h.db.Collection("restaurant_locations").UpdateOne(
		context.Background(),
		bson.M{"restaurant_id": restaurantID},
		bson.M{"$set": location},
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Restaurant location not found"})
		return
	}

	c.JSON(http.StatusOK, location)
}

// DeleteRestaurantLocation deletes a restaurant's location
func (h *RestaurantHandler) DeleteRestaurantLocation(c *gin.Context) {
	restaurantID := c.Param("id")

	result, err := h.db.Collection("restaurant_locations").DeleteOne(context.Background(), bson.M{"restaurant_id": restaurantID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Restaurant location not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Restaurant location deleted successfully"})
}

// CreateDeliveryZone creates a new delivery zone for a restaurant
func (h *RestaurantHandler) CreateDeliveryZone(c *gin.Context) {
	var zone models.DeliveryZone
	if err := c.ShouldBindJSON(&zone); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	zone.CreatedAt = time.Now()
	zone.UpdatedAt = time.Now()

	result, err := h.db.Collection("delivery_zones").InsertOne(context.Background(), zone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	zone.ID = result.InsertedID.(primitive.ObjectID)
	c.JSON(http.StatusCreated, zone)
}

// GetDeliveryZones gets all delivery zones for a restaurant
func (h *RestaurantHandler) GetDeliveryZones(c *gin.Context) {
	restaurantID := c.Param("id")

	cursor, err := h.db.Collection("delivery_zones").Find(context.Background(), bson.M{"restaurant_id": restaurantID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer cursor.Close(context.Background())

	var zones []models.DeliveryZone
	if err := cursor.All(context.Background(), &zones); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, zones)
}

// UpdateDeliveryZone updates a delivery zone
func (h *RestaurantHandler) UpdateDeliveryZone(c *gin.Context) {
	zoneID := c.Param("id")

	var zone models.DeliveryZone
	if err := c.ShouldBindJSON(&zone); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	zone.UpdatedAt = time.Now()

	result, err := h.db.Collection("delivery_zones").UpdateOne(
		context.Background(),
		bson.M{"_id": zoneID},
		bson.M{"$set": zone},
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Delivery zone not found"})
		return
	}

	c.JSON(http.StatusOK, zone)
}

// DeleteDeliveryZone deletes a delivery zone
func (h *RestaurantHandler) DeleteDeliveryZone(c *gin.Context) {
	zoneID := c.Param("id")

	result, err := h.db.Collection("delivery_zones").DeleteOne(context.Background(), bson.M{"_id": zoneID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Delivery zone not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Delivery zone deleted successfully"})
} 