package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Settlement represents a payment made to settle debt between users
type Settlement struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key"`
	FromUserID  uuid.UUID      `json:"from_user_id" gorm:"type:uuid;not null"`
	ToUserID    uuid.UUID      `json:"to_user_id" gorm:"type:uuid;not null"`
	GroupID     uuid.UUID      `json:"group_id" gorm:"type:uuid;not null"`
	Amount      float64        `json:"amount" gorm:"not null"`
	Description string         `json:"description"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	FromUser User  `json:"from_user,omitempty" gorm:"foreignKey:FromUserID"`
	ToUser   User  `json:"to_user,omitempty" gorm:"foreignKey:ToUserID"`
	Group    Group `json:"group,omitempty" gorm:"foreignKey:GroupID"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (s *Settlement) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}

// SettlementCreateRequest represents the settlement creation request structure
type SettlementCreateRequest struct {
	ToUserID    uuid.UUID `json:"to_user_id" binding:"required"`
	GroupID     uuid.UUID `json:"group_id" binding:"required"`
	Amount      float64   `json:"amount" binding:"required,gt=0"`
	Description string    `json:"description"`
}

// SettlementResponse represents the settlement response structure
type SettlementResponse struct {
	ID          uuid.UUID    `json:"id"`
	FromUserID  uuid.UUID    `json:"from_user_id"`
	ToUserID    uuid.UUID    `json:"to_user_id"`
	GroupID     uuid.UUID    `json:"group_id"`
	Amount      float64      `json:"amount"`
	Description string       `json:"description"`
	CreatedAt   time.Time    `json:"created_at"`
	UpdatedAt   time.Time    `json:"updated_at"`
	FromUser    UserResponse `json:"from_user"`
	ToUser      UserResponse `json:"to_user"`
}

// Balance represents the balance between two users in a group
type Balance struct {
	UserID   uuid.UUID `json:"user_id"`
	UserName string    `json:"user_name"`
	Balance  float64   `json:"balance"` // Positive means they are owed money, negative means they owe money
}

// GroupBalance represents the balance summary for a group
type GroupBalance struct {
	GroupID       uuid.UUID `json:"group_id"`
	GroupName     string    `json:"group_name"`
	Balances      []Balance `json:"balances"`
	TotalExpenses float64   `json:"total_expenses"`
}
