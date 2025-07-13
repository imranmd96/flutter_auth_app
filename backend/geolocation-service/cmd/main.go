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
	"forkLine/backend/geolocation-service/internal/application/services"
	"forkLine/backend/geolocation-service/internal/infrastructure/cache/redis"
	"forkLine/backend/geolocation-service/internal/infrastructure/external/google_maps"
	"forkLine/backend/geolocation-service/internal/infrastructure/persistence/mongodb"
	"forkLine/backend/geolocation-service/internal/interfaces/http/handlers"
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

	// Initialize repositories
	locationRepo := mongodb.NewLocationRepository(mongoClient.Database(cfg.MongoDB.Database))
	cacheRepo := redis.NewCacheRepository(redisClient, cfg.Cache.TTL)
	externalService := google_maps.NewExternalService(cfg.GoogleMaps.APIKey)

	// Initialize services
	locationService := services.NewLocationService(locationRepo, cacheRepo, externalService)

	// Initialize handlers
	locationHandler := handlers.NewLocationHandler(locationService)

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