package repository

import (
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// UserRepository handles user-related database operations
type UserRepository struct {
	db *gorm.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository() *UserRepository {
	return &UserRepository{
		db: database.GetDB(),
	}
}

// Create creates a new user
func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(id uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.db.Where("id = ?", id).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// SearchByEmail searches for users by email with partial matching
func (r *UserRepository) SearchByEmail(emailQuery string, offset, limit int) ([]models.User, error) {
	var users []models.User
	err := r.db.Where("email LIKE ?", "%"+emailQuery+"%").
		Offset(offset).
		Limit(limit).
		Find(&users).Error
	return users, err
}

// Update updates a user
func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

// Delete deletes a user
func (r *UserRepository) Delete(id uuid.UUID) error {
	return r.db.Delete(&models.User{}, id).Error
}

// List retrieves all users with pagination
func (r *UserRepository) List(offset, limit int) ([]models.User, error) {
	var users []models.User
	err := r.db.Offset(offset).Limit(limit).Find(&users).Error
	return users, err
}

// GetUserGroups retrieves all groups a user is a member of
func (r *UserRepository) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	var groups []models.Group
	err := r.db.Joins("JOIN group_members ON groups.id = group_members.group_id").
		Where("group_members.user_id = ?", userID).
		Find(&groups).Error
	return groups, err
}

// GetUserExpenses retrieves all expenses for a user
func (r *UserRepository) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	var expenses []models.Expense
	err := r.db.Where("paid_by_id = ?", userID).
		Preload("Group").
		Preload("Splits").
		Preload("Splits.User").
		Find(&expenses).Error
	return expenses, err
}
