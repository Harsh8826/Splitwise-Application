package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Expense represents an expense in a group
type Expense struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key"`
	GroupID     uuid.UUID      `json:"group_id" gorm:"type:uuid;not null"`
	PaidByID    uuid.UUID      `json:"paid_by_id" gorm:"type:uuid;not null"`
	Title       string         `json:"title" gorm:"not null"`
	Description string         `json:"description"`
	Amount      float64        `json:"amount" gorm:"not null"`
	SplitType   string         `json:"split_type" gorm:"not null;default:'equal'"` // equal, percentage, custom
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	Group  Group          `json:"group,omitempty" gorm:"foreignKey:GroupID"`
	PaidBy User           `json:"paid_by,omitempty" gorm:"foreignKey:PaidByID"`
	Splits []ExpenseSplit `json:"splits,omitempty" gorm:"foreignKey:ExpenseID"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (e *Expense) BeforeCreate(tx *gorm.DB) error {
	if e.ID == uuid.Nil {
		e.ID = uuid.New()
	}
	return nil
}

// ExpenseSplit represents how an expense is split among group members
type ExpenseSplit struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;primary_key"`
	ExpenseID  uuid.UUID `json:"expense_id" gorm:"type:uuid;not null"`
	UserID     uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Amount     float64   `json:"amount" gorm:"not null"`
	Percentage float64   `json:"percentage" gorm:"not null;default:0"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// Relationships
	Expense Expense `json:"expense,omitempty" gorm:"foreignKey:ExpenseID"`
	User    User    `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (es *ExpenseSplit) BeforeCreate(tx *gorm.DB) error {
	if es.ID == uuid.Nil {
		es.ID = uuid.New()
	}
	return nil
}

// ExpenseCreateRequest represents the expense creation request structure
type ExpenseCreateRequest struct {
	GroupID     uuid.UUID           `json:"group_id" binding:"required"`
	Title       string              `json:"title" binding:"required,min=1"`
	Description string              `json:"description"`
	Amount      float64             `json:"amount" binding:"required,gt=0"`
	SplitType   string              `json:"split_type" binding:"required,oneof=equal percentage custom"`
	Splits      []ExpenseSplitInput `json:"splits,omitempty"`
}

// ExpenseSplitInput represents the input for expense splits
type ExpenseSplitInput struct {
	UserID     uuid.UUID `json:"user_id" binding:"required"`
	Amount     float64   `json:"amount,omitempty"`
	Percentage float64   `json:"percentage,omitempty"`
}

// ExpenseUpdateRequest represents the expense update request structure
type ExpenseUpdateRequest struct {
	Title       string              `json:"title" binding:"required,min=1"`
	Description string              `json:"description"`
	Amount      float64             `json:"amount" binding:"required,gt=0"`
	SplitType   string              `json:"split_type" binding:"required,oneof=equal percentage custom"`
	Splits      []ExpenseSplitInput `json:"splits,omitempty"`
}

// ExpenseResponse represents the expense response structure
type ExpenseResponse struct {
	ID          uuid.UUID              `json:"id"`
	GroupID     uuid.UUID              `json:"group_id"`
	PaidByID    uuid.UUID              `json:"paid_by_id"`
	Title       string                 `json:"title"`
	Description string                 `json:"description"`
	Amount      float64                `json:"amount"`
	SplitType   string                 `json:"split_type"`
	CreatedAt   time.Time              `json:"created_at"`
	UpdatedAt   time.Time              `json:"updated_at"`
	PaidBy      UserResponse           `json:"paid_by"`
	Splits      []ExpenseSplitResponse `json:"splits"`
}

// ExpenseSplitResponse represents the expense split response structure
type ExpenseSplitResponse struct {
	ID         uuid.UUID    `json:"id"`
	UserID     uuid.UUID    `json:"user_id"`
	Amount     float64      `json:"amount"`
	Percentage float64      `json:"percentage"`
	User       UserResponse `json:"user"`
}
