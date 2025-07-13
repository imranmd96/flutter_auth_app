package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"forkLine/backend/geolocation-service/internal/application/services"
	"forkLine/backend/geolocation-service/internal/domain/models"
)

// LocationHandler handles HTTP requests for location-related operations
type LocationHandler struct {
	locationService *services.LocationService
}

// NewLocationHandler creates a new instance of LocationHandler
func NewLocationHandler(locationService *services.LocationService) *LocationHandler {
	return &LocationHandler{
		locationService: locationService,
	}
}

// CalculateDistance handles distance calculation requests
func (h *LocationHandler) CalculateDistance(c *gin.Context) {
	var req struct {
		Origin      models.Location `json:"origin" binding:"required"`
		Destination models.Location `json:"destination" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	distance, duration, err := h.locationService.CalculateDistance(c.Request.Context(), &req.Origin, &req.Destination)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"distance": distance,
		"duration": duration,
	})
}

// FindNearby handles nearby location search requests
func (h *LocationHandler) FindNearby(c *gin.Context) {
	var req struct {
		Location models.Location `json:"location" binding:"required"`
		Radius   float64        `json:"radius" binding:"required,min=0,max=50"`
		Type     string         `json:"type" binding:"required,oneof=restaurant driver"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	locations, err := h.locationService.FindNearbyLocations(c.Request.Context(), req.Location, req.Radius, req.Type)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, locations)
}

// ValidateAddress handles address validation requests
func (h *LocationHandler) ValidateAddress(c *gin.Context) {
	var req struct {
		Address models.Address `json:"address" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	validatedAddress, err := h.locationService.ValidateAddress(c.Request.Context(), &req.Address)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, validatedAddress)
}

// Geocode handles geocoding requests
func (h *LocationHandler) Geocode(c *gin.Context) {
	var req struct {
		Address models.Address `json:"address" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location, err := h.locationService.GeocodeAddress(c.Request.Context(), &req.Address)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, location)
}

// ReverseGeocode handles reverse geocoding requests
func (h *LocationHandler) ReverseGeocode(c *gin.Context) {
	var req models.Location

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	address, err := h.locationService.ReverseGeocode(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, address)
} 