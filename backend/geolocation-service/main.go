package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"forkLine/backend/geolocation-service/config"
	"forkLine/backend/geolocation-service/handlers"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Connect to MongoDB
	mongoClient, err := mongo.Connect(context.Background(), options.Client().ApplyURI(cfg.MongoDB.URI))
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	defer mongoClient.Disconnect(context.Background())

	// Connect to Redis
	redisClient := redis.NewClient(&redis.Options{
		Addr:     cfg.Redis.Addr,
		Password: cfg.Redis.Password,
		DB:       cfg.Redis.DB,
	})
	defer redisClient.Close()

	// Initialize handlers
	locationHandler := handlers.NewLocationHandler(mongoClient.Database(cfg.MongoDB.Database), redisClient, cfg)
	restaurantHandler := handlers.NewRestaurantHandler(mongoClient.Database(cfg.MongoDB.Database), redisClient, cfg)
	deliveryHandler := handlers.NewDeliveryHandler(mongoClient.Database(cfg.MongoDB.Database), redisClient, cfg)

	// Initialize router
	router := gin.Default()

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"time":   time.Now().Format(time.RFC3339),
		})
	})

	// Location routes
	locationGroup := router.Group("/api/v1/locations")
	{
		locationGroup.POST("/distance", locationHandler.CalculateDistance)
		locationGroup.POST("/nearby", locationHandler.FindNearby)
		locationGroup.POST("/validate", locationHandler.ValidateAddress)
		locationGroup.POST("/geocode", locationHandler.Geocode)
		locationGroup.POST("/reverse-geocode", locationHandler.ReverseGeocode)
	}

	// Restaurant routes
	restaurantGroup := router.Group("/api/v1/restaurants")
	{
		restaurantGroup.POST("/locations", restaurantHandler.CreateRestaurantLocation)
		restaurantGroup.GET("/locations/:id", restaurantHandler.GetRestaurantLocation)
		restaurantGroup.PUT("/locations/:id", restaurantHandler.UpdateRestaurantLocation)
		restaurantGroup.DELETE("/locations/:id", restaurantHandler.DeleteRestaurantLocation)

		restaurantGroup.POST("/zones", restaurantHandler.CreateDeliveryZone)
		restaurantGroup.GET("/zones/:id", restaurantHandler.GetDeliveryZones)
		restaurantGroup.PUT("/zones/:id", restaurantHandler.UpdateDeliveryZone)
		restaurantGroup.DELETE("/zones/:id", restaurantHandler.DeleteDeliveryZone)
	}

	// Delivery routes
	deliveryGroup := router.Group("/api/v1/delivery")
	{
		deliveryGroup.POST("/estimate", deliveryHandler.EstimateDeliveryTime)
		deliveryGroup.POST("/optimize", deliveryHandler.OptimizeDeliveryRoute)
		deliveryGroup.PUT("/drivers/:id/location", deliveryHandler.UpdateDriverLocation)
		deliveryGroup.GET("/drivers/:id/location", deliveryHandler.GetDriverLocation)
	}

	// Create HTTP server
	srv := &http.Server{
		Addr:    ":" + cfg.Server.Port,
		Handler: router,
	}

	// Start server in a goroutine
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	// Create shutdown context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Attempt graceful shutdown
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exiting")
} 