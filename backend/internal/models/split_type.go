package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// SplitType represents the master table for expense split types
type SplitType struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key"`
	Name        string         `json:"name" gorm:"not null;unique"`
	Description string         `json:"description"`
	IsActive    bool           `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (st *SplitType) BeforeCreate(tx *gorm.DB) error {
	if st.ID == uuid.Nil {
		st.ID = uuid.New()
	}
	return nil
}

// SplitTypeCreateRequest represents the split type creation request structure
type SplitTypeCreateRequest struct {
	Name        string `json:"name" binding:"required,min=2"`
	Description string `json:"description"`
}

// SplitTypeUpdateRequest represents the split type update request structure
type SplitTypeUpdateRequest struct {
	Name        string `json:"name" binding:"required,min=2"`
	Description string `json:"description"`
	IsActive    bool   `json:"is_active"`
}

// SplitTypeResponse represents the split type response structure
type SplitTypeResponse struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
