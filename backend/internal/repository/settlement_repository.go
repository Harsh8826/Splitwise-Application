package repository

import (
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// SettlementRepository handles settlement-related database operations
type SettlementRepository struct {
	db *gorm.DB
}

// NewSettlementRepository creates a new settlement repository
func NewSettlementRepository() *SettlementRepository {
	return &SettlementRepository{
		db: database.GetDB(),
	}
}

// Create creates a new settlement
func (r *SettlementRepository) Create(settlement *models.Settlement) error {
	return r.db.Create(settlement).Error
}

// GetByID retrieves a settlement by ID
func (r *SettlementRepository) GetByID(id uuid.UUID) (*models.Settlement, error) {
	var settlement models.Settlement
	err := r.db.Where("id = ?", id).
		Preload("FromUser").
		Preload("ToUser").
		Preload("Group").
		First(&settlement).Error
	if err != nil {
		return nil, err
	}
	return &settlement, nil
}

// Update updates a settlement
func (r *SettlementRepository) Update(settlement *models.Settlement) error {
	return r.db.Save(settlement).Error
}

// Delete deletes a settlement
func (r *SettlementRepository) Delete(id uuid.UUID) error {
	return r.db.Delete(&models.Settlement{}, id).Error
}

// GetGroupSettlements retrieves all settlements for a group
func (r *SettlementRepository) GetGroupSettlements(groupID uuid.UUID) ([]models.Settlement, error) {
	var settlements []models.Settlement
	err := r.db.Where("group_id = ?", groupID).
		Preload("FromUser").
		Preload("ToUser").
		Order("created_at DESC").
		Find(&settlements).Error
	return settlements, err
}

// GetUserSettlements retrieves all settlements involving a user
func (r *SettlementRepository) GetUserSettlements(userID uuid.UUID) ([]models.Settlement, error) {
	var settlements []models.Settlement
	err := r.db.Where("from_user_id = ? OR to_user_id = ?", userID, userID).
		Preload("FromUser").
		Preload("ToUser").
		Preload("Group").
		Order("created_at DESC").
		Find(&settlements).Error
	return settlements, err
}

// GetUserSettlementsInGroup retrieves all settlements for a user in a specific group
func (r *SettlementRepository) GetUserSettlementsInGroup(userID, groupID uuid.UUID) ([]models.Settlement, error) {
	var settlements []models.Settlement
	err := r.db.Where("group_id = ? AND (from_user_id = ? OR to_user_id = ?)", groupID, userID, userID).
		Preload("FromUser").
		Preload("ToUser").
		Order("created_at DESC").
		Find(&settlements).Error
	return settlements, err
}
