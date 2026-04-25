package handlers

import (
	"expense_management_backend/internal/middleware"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// SplitTypeHandler handles split type-related HTTP requests
type SplitTypeHandler struct {
	splitTypeService *services.SplitTypeService
}

// NewSplitTypeHandler creates a new split type handler
func NewSplitTypeHandler(splitTypeService *services.SplitTypeService) *SplitTypeHandler {
	return &SplitTypeHandler{
		splitTypeService: splitTypeService,
	}
}

// Create handles split type creation
func (h *SplitTypeHandler) Create(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req models.SplitTypeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	splitType, err := h.splitTypeService.Create(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Split type created successfully",
		"split_type": splitType,
	})
}

// GetByID handles getting a split type by ID
func (h *SplitTypeHandler) GetByID(c *gin.Context) {
	splitTypeIDStr := c.Param("id")
	splitTypeID, err := uuid.Parse(splitTypeIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid split type ID"})
		return
	}

	splitType, err := h.splitTypeService.GetByID(splitTypeID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Split type not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"split_type": splitType})
}

// Update handles split type updates
func (h *SplitTypeHandler) Update(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	splitTypeIDStr := c.Param("id")
	splitTypeID, err := uuid.Parse(splitTypeIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid split type ID"})
		return
	}

	var req models.SplitTypeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	splitType, err := h.splitTypeService.Update(splitTypeID, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Split type updated successfully",
		"split_type": splitType,
	})
}

// Delete handles split type deletion
func (h *SplitTypeHandler) Delete(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	splitTypeIDStr := c.Param("id")
	splitTypeID, err := uuid.Parse(splitTypeIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid split type ID"})
		return
	}

	err = h.splitTypeService.Delete(splitTypeID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Split type deleted successfully"})
}

// List handles listing all split types with pagination
func (h *SplitTypeHandler) List(c *gin.Context) {
	offsetStr := c.DefaultQuery("offset", "0")
	limitStr := c.DefaultQuery("limit", "10")

	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid offset"})
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid limit"})
		return
	}

	splitTypes, err := h.splitTypeService.List(offset, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"split_types": splitTypes})
}

// ListActive handles listing all active split types
func (h *SplitTypeHandler) ListActive(c *gin.Context) {
	splitTypes, err := h.splitTypeService.ListActive()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"split_types": splitTypes})
}
