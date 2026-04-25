package repository

import (
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// SplitTypeRepository handles split type-related database operations
type SplitTypeRepository struct {
	db *gorm.DB
}

// NewSplitTypeRepository creates a new split type repository
func NewSplitTypeRepository() *SplitTypeRepository {
	return &SplitTypeRepository{
		db: database.GetDB(),
	}
}

// Create creates a new split type
func (r *SplitTypeRepository) Create(splitType *models.SplitType) error {
	return r.db.Create(splitType).Error
}

// GetByID retrieves a split type by ID
func (r *SplitTypeRepository) GetByID(id uuid.UUID) (*models.SplitType, error) {
	var splitType models.SplitType
	err := r.db.Where("id = ?", id).First(&splitType).Error
	if err != nil {
		return nil, err
	}
	return &splitType, nil
}

// GetByName retrieves a split type by name
func (r *SplitTypeRepository) GetByName(name string) (*models.SplitType, error) {
	var splitType models.SplitType
	err := r.db.Where("name = ?", name).First(&splitType).Error
	if err != nil {
		return nil, err
	}
	return &splitType, nil
}

// Update updates a split type
func (r *SplitTypeRepository) Update(splitType *models.SplitType) error {
	return r.db.Save(splitType).Error
}

// Delete deletes a split type
func (r *SplitTypeRepository) Delete(id uuid.UUID) error {
	return r.db.Delete(&models.SplitType{}, id).Error
}

// List retrieves all split types with pagination
func (r *SplitTypeRepository) List(offset, limit int) ([]models.SplitType, error) {
	var splitTypes []models.SplitType
	err := r.db.Offset(offset).Limit(limit).Find(&splitTypes).Error
	return splitTypes, err
}

// ListActive retrieves all active split types
func (r *SplitTypeRepository) ListActive() ([]models.SplitType, error) {
	var splitTypes []models.SplitType
	err := r.db.Where("is_active = ?", true).Find(&splitTypes).Error
	return splitTypes, err
}

// InitializeDefaultSplitTypes creates default split types if they don't exist
func (r *SplitTypeRepository) InitializeDefaultSplitTypes() error {
	defaultTypes := []models.SplitType{
		{
			Name:        "equal",
			Description: "Split equally among all group members",
			IsActive:    true,
		},
		{
			Name:        "percentage",
			Description: "Split based on percentages",
			IsActive:    true,
		},
		{
			Name:        "custom",
			Description: "Split based on custom amounts",
			IsActive:    true,
		},
	}

	for _, splitType := range defaultTypes {
		// Check if split type already exists
		existing, err := r.GetByName(splitType.Name)
		if err != nil && err != gorm.ErrRecordNotFound {
			return err
		}

		// If not found, create it
		if existing == nil {
			if err := r.Create(&splitType); err != nil {
				return err
			}
		}
	}

	return nil
}
