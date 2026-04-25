package repository

import (
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// GroupRepository handles group-related database operations
type GroupRepository struct {
	db *gorm.DB
}

// NewGroupRepository creates a new group repository
func NewGroupRepository() *GroupRepository {
	return &GroupRepository{
		db: database.GetDB(),
	}
}

// Create creates a new group
func (r *GroupRepository) Create(group *models.Group) error {
	return r.db.Create(group).Error
}

// GetByID retrieves a group by ID with members and expenses
func (r *GroupRepository) GetByID(id uuid.UUID) (*models.Group, error) {
	var group models.Group
	err := r.db.Where("id = ?", id).
		Preload("Creator").
		Preload("Members").
		Preload("Members.User").
		Preload("Expenses").
		Preload("Expenses.PaidBy").
		Preload("Expenses.Splits").
		Preload("Expenses.Splits.User").
		First(&group).Error
	if err != nil {
		return nil, err
	}
	return &group, nil
}

// Update updates a group
func (r *GroupRepository) Update(group *models.Group) error {
	return r.db.Save(group).Error
}

// Delete deletes a group
func (r *GroupRepository) Delete(id uuid.UUID) error {
	return r.db.Delete(&models.Group{}, id).Error
}

// List retrieves all groups with pagination
func (r *GroupRepository) List(offset, limit int) ([]models.Group, error) {
	var groups []models.Group
	err := r.db.Offset(offset).Limit(limit).
		Preload("Creator").
		Preload("Members").
		Find(&groups).Error
	return groups, err
}

// GetUserGroups retrieves all groups a user is a member of
func (r *GroupRepository) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	var groups []models.Group
	err := r.db.Joins("JOIN group_members ON groups.id = group_members.group_id").
		Where("group_members.user_id = ?", userID).
		Preload("Creator").
		Preload("Members").
		Preload("Members.User").
		Find(&groups).Error
	return groups, err
}

// AddMember adds a user to a group
func (r *GroupRepository) AddMember(groupID, userID uuid.UUID) error {
	member := &models.GroupMember{
		GroupID: groupID,
		UserID:  userID,
	}
	return r.db.Create(member).Error
}

// RemoveMember removes a user from a group
func (r *GroupRepository) RemoveMember(groupID, userID uuid.UUID) error {
	return r.db.Where("group_id = ? AND user_id = ?", groupID, userID).
		Delete(&models.GroupMember{}).Error
}

// IsMember checks if a user is a member of a group
func (r *GroupRepository) IsMember(groupID, userID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.GroupMember{}).
		Where("group_id = ? AND user_id = ?", groupID, userID).
		Count(&count).Error
	return count > 0, err
}

// GetGroupMembers retrieves all members of a group
func (r *GroupRepository) GetGroupMembers(groupID uuid.UUID) ([]models.GroupMember, error) {
	var members []models.GroupMember
	err := r.db.Where("group_id = ?", groupID).
		Preload("User").
		Find(&members).Error
	return members, err
}
