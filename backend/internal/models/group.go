package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Group represents a group for expense sharing
type Group struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key"`
	Name        string         `json:"name" gorm:"not null"`
	Description string         `json:"description"`
	CreatedBy   uuid.UUID      `json:"created_by" gorm:"type:uuid;not null"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	Creator  User          `json:"creator,omitempty" gorm:"foreignKey:CreatedBy"`
	Members  []GroupMember `json:"members,omitempty" gorm:"foreignKey:GroupID"`
	Expenses []Expense     `json:"expenses,omitempty" gorm:"foreignKey:GroupID"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (g *Group) BeforeCreate(tx *gorm.DB) error {
	if g.ID == uuid.Nil {
		g.ID = uuid.New()
	}
	return nil
}

// GroupMember represents the many-to-many relationship between users and groups
type GroupMember struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;primary_key"`
	GroupID   uuid.UUID `json:"group_id" gorm:"type:uuid;not null"`
	UserID    uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	JoinedAt  time.Time `json:"joined_at"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relationships
	Group Group `json:"group,omitempty" gorm:"foreignKey:GroupID"`
	User  User  `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

// BeforeCreate will set a UUID rather than numeric ID
func (gm *GroupMember) BeforeCreate(tx *gorm.DB) error {
	if gm.ID == uuid.Nil {
		gm.ID = uuid.New()
	}
	gm.JoinedAt = time.Now()
	return nil
}

// GroupCreateRequest represents the group creation request structure
type GroupCreateRequest struct {
	Name        string `json:"name" binding:"required,min=2"`
	Description string `json:"description"`
}

// GroupUpdateRequest represents the group update request structure
type GroupUpdateRequest struct {
	Name        string `json:"name" binding:"required,min=2"`
	Description string `json:"description"`
}

// GroupResponse represents the group response structure
type GroupResponse struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	CreatedBy   uuid.UUID `json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	MemberCount int       `json:"member_count"`
}
