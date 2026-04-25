package repository

import (
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
)

// UserRepositoryInterface defines the interface for user repository operations
type UserRepositoryInterface interface {
	Create(user *models.User) error
	GetByID(id uuid.UUID) (*models.User, error)
	GetByEmail(email string) (*models.User, error)
	Update(user *models.User) error
	Delete(id uuid.UUID) error
	List(offset, limit int) ([]models.User, error)
	GetUserGroups(userID uuid.UUID) ([]models.Group, error)
	GetUserExpenses(userID uuid.UUID) ([]models.Expense, error)
}

// GroupRepositoryInterface defines the interface for group repository operations
type GroupRepositoryInterface interface {
	Create(group *models.Group) error
	GetByID(id uuid.UUID) (*models.Group, error)
	Update(group *models.Group) error
	Delete(id uuid.UUID) error
	List(offset, limit int) ([]models.Group, error)
	GetUserGroups(userID uuid.UUID) ([]models.Group, error)
	AddMember(groupID, userID uuid.UUID) error
	RemoveMember(groupID, userID uuid.UUID) error
	IsMember(groupID, userID uuid.UUID) (bool, error)
	GetGroupMembers(groupID uuid.UUID) ([]models.GroupMember, error)
}

// ExpenseRepositoryInterface defines the interface for expense repository operations
type ExpenseRepositoryInterface interface {
	Create(expense *models.Expense) error
	GetByID(id uuid.UUID) (*models.Expense, error)
	Update(expense *models.Expense) error
	Delete(id uuid.UUID) error
	GetGroupExpenses(groupID uuid.UUID) ([]models.Expense, error)
	GetUserExpenses(userID uuid.UUID) ([]models.Expense, error)
	CreateExpenseSplit(split *models.ExpenseSplit) error
	UpdateExpenseSplit(split *models.ExpenseSplit) error
	DeleteExpenseSplit(id uuid.UUID) error
	GetExpenseSplits(expenseID uuid.UUID) ([]models.ExpenseSplit, error)
	DeleteExpenseSplits(expenseID uuid.UUID) error
}

// SettlementRepositoryInterface defines the interface for settlement repository operations
type SettlementRepositoryInterface interface {
	Create(settlement *models.Settlement) error
	GetByID(id uuid.UUID) (*models.Settlement, error)
	Update(settlement *models.Settlement) error
	Delete(id uuid.UUID) error
	GetGroupSettlements(groupID uuid.UUID) ([]models.Settlement, error)
	GetUserSettlements(userID uuid.UUID) ([]models.Settlement, error)
	GetUserSettlementsInGroup(userID, groupID uuid.UUID) ([]models.Settlement, error)
}
