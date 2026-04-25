package handlers

import (
	"expense_management_backend/internal/middleware"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// SettlementHandler handles settlement-related HTTP requests
type SettlementHandler struct {
	settlementService *services.SettlementService
}

// NewSettlementHandler creates a new settlement handler
func NewSettlementHandler(settlementService *services.SettlementService) *SettlementHandler {
	return &SettlementHandler{
		settlementService: settlementService,
	}
}

// Create handles settlement creation
func (h *SettlementHandler) Create(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req models.SettlementCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	settlement, err := h.settlementService.Create(&req, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Settlement created successfully",
		"settlement": settlement,
	})
}

// GetByID handles getting a settlement by ID
func (h *SettlementHandler) GetByID(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	settlementIDStr := c.Param("id")
	settlementID, err := uuid.Parse(settlementIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid settlement ID"})
		return
	}

	settlement, err := h.settlementService.GetByID(settlementID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Settlement not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"settlement": settlement})
}

// Update handles settlement updates
func (h *SettlementHandler) Update(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	settlementIDStr := c.Param("id")
	settlementID, err := uuid.Parse(settlementIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid settlement ID"})
		return
	}

	var req struct {
		Amount      float64 `json:"amount" binding:"required,gt=0"`
		Description string  `json:"description"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	settlement, err := h.settlementService.Update(settlementID, req.Amount, req.Description, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Settlement updated successfully",
		"settlement": settlement,
	})
}

// Delete handles settlement deletion
func (h *SettlementHandler) Delete(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	settlementIDStr := c.Param("id")
	settlementID, err := uuid.Parse(settlementIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid settlement ID"})
		return
	}

	err = h.settlementService.Delete(settlementID, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Settlement deleted successfully"})
}

// GetGroupSettlements handles getting all settlements for a group
func (h *SettlementHandler) GetGroupSettlements(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	groupIDStr := c.Param("id")
	groupID, err := uuid.Parse(groupIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	settlements, err := h.settlementService.GetGroupSettlements(groupID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"settlements": settlements})
}

// GetUserSettlements handles getting all settlements for a user
func (h *SettlementHandler) GetUserSettlements(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	settlements, err := h.settlementService.GetUserSettlements(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"settlements": settlements})
}

// GetUserSettlementsInGroup handles getting all settlements for a user in a specific group
func (h *SettlementHandler) GetUserSettlementsInGroup(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	groupIDStr := c.Param("id")
	groupID, err := uuid.Parse(groupIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	settlements, err := h.settlementService.GetUserSettlementsInGroup(userID, groupID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"settlements": settlements})
}

// CalculateGroupBalance handles calculating group balance
func (h *SettlementHandler) CalculateGroupBalance(c *gin.Context) {
	_, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	groupIDStr := c.Param("id")
	groupID, err := uuid.Parse(groupIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	balance, err := h.settlementService.CalculateGroupBalance(groupID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"balance": balance})
}
