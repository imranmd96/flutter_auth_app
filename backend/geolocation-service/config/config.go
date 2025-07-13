package config

import (
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Server struct {
		Port string
	}
	MongoDB struct {
		URI      string
		Database string
	}
	Redis struct {
		Addr     string
		Password string
		DB       int
	}
	GoogleMaps struct {
		APIKey string
	}
	ServiceURLs struct {
		RestaurantService string
		OrderService      string
		NotificationService string
	}
	Cache struct {
		TTL      time.Duration
		MaxSize  int
	}
	Location struct {
		DefaultSearchRadius float64
		MaxSearchRadius    float64
		DefaultDeliverySpeed float64 // km/h
	}
}

func Load() (*Config, error) {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		// It's okay if .env file doesn't exist
	}

	config := &Config{}

	// Server configuration
	config.Server.Port = getEnv("PORT", "3014")

	// MongoDB configuration
	config.MongoDB.URI = getEnv("MONGODB_URI", "mongodb://localhost:27017")
	config.MongoDB.Database = getEnv("MONGODB_DATABASE", "geolocation")

	// Redis configuration
	config.Redis.Addr = getEnv("REDIS_ADDR", "localhost:6379")
	config.Redis.Password = getEnv("REDIS_PASSWORD", "")
	config.Redis.DB = getEnvAsInt("REDIS_DB", 0)

	// Google Maps configuration
	config.GoogleMaps.APIKey = getEnv("GOOGLE_MAPS_API_KEY", "")

	// Service URLs
	config.ServiceURLs.RestaurantService = getEnv("RESTAURANT_SERVICE_URL", "http://localhost:3010")
	config.ServiceURLs.OrderService = getEnv("ORDER_SERVICE_URL", "http://localhost:3011")
	config.ServiceURLs.NotificationService = getEnv("NOTIFICATION_SERVICE_URL", "http://localhost:3012")

	// Cache configuration
	config.Cache.TTL = getEnvAsDuration("CACHE_TTL", 24*time.Hour)
	config.Cache.MaxSize = getEnvAsInt("CACHE_MAX_SIZE", 1000)

	// Location configuration
	config.Location.DefaultSearchRadius = getEnvAsFloat("DEFAULT_SEARCH_RADIUS", 5.0) // 5 km
	config.Location.MaxSearchRadius = getEnvAsFloat("MAX_SEARCH_RADIUS", 50.0)        // 50 km
	config.Location.DefaultDeliverySpeed = getEnvAsFloat("DEFAULT_DELIVERY_SPEED", 30.0) // 30 km/h

	return config, nil
}

// Helper functions to get environment variables with defaults
func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value, exists := os.LookupEnv(key); exists {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func getEnvAsFloat(key string, defaultValue float64) float64 {
	if value, exists := os.LookupEnv(key); exists {
		if floatValue, err := strconv.ParseFloat(value, 64); err == nil {
			return floatValue
		}
	}
	return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
	if value, exists := os.LookupEnv(key); exists {
		if duration, err := time.ParseDuration(value); err == nil {
			return duration
		}
	}
	return defaultValue
} 