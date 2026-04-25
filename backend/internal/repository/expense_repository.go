package repository

import (
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ExpenseRepository handles expense-related database operations
type ExpenseRepository struct {
	db *gorm.DB
}

// NewExpenseRepository creates a new expense repository
func NewExpenseRepository() *ExpenseRepository {
	return &ExpenseRepository{
		db: database.GetDB(),
	}
}

// Create creates a new expense with splits
func (r *ExpenseRepository) Create(expense *models.Expense) error {
	return r.db.Create(expense).Error
}

// GetByID retrieves an expense by ID with all related data
func (r *ExpenseRepository) GetByID(id uuid.UUID) (*models.Expense, error) {
	var expense models.Expense
	err := r.db.Where("id = ?", id).
		Preload("Group").
		Preload("PaidBy").
		Preload("Splits").
		Preload("Splits.User").
		First(&expense).Error
	if err != nil {
		return nil, err
	}
	return &expense, nil
}

// Update updates an expense
func (r *ExpenseRepository) Update(expense *models.Expense) error {
	return r.db.Save(expense).Error
}

// Delete deletes an expense
func (r *ExpenseRepository) Delete(id uuid.UUID) error {
	return r.db.Delete(&models.Expense{}, id).Error
}

// GetGroupExpenses retrieves all expenses for a group
func (r *ExpenseRepository) GetGroupExpenses(groupID uuid.UUID) ([]models.Expense, error) {
	var expenses []models.Expense
	err := r.db.Where("group_id = ?", groupID).
		Preload("PaidBy").
		Preload("Splits").
		Preload("Splits.User").
		Order("created_at DESC").
		Find(&expenses).Error
	return expenses, err
}

// GetUserExpenses retrieves all expenses where user is involved (paid or split)
func (r *ExpenseRepository) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	var expenses []models.Expense
	err := r.db.Joins("LEFT JOIN expense_splits ON expenses.id = expense_splits.expense_id").
		Where("expenses.paid_by_id = ? OR expense_splits.user_id = ?", userID, userID).
		Preload("Group").
		Preload("PaidBy").
		Preload("Splits").
		Preload("Splits.User").
		Order("expenses.created_at DESC").
		Find(&expenses).Error
	return expenses, err
}

// CreateExpenseSplit creates an expense split
func (r *ExpenseRepository) CreateExpenseSplit(split *models.ExpenseSplit) error {
	return r.db.Create(split).Error
}

// UpdateExpenseSplit updates an expense split
func (r *ExpenseRepository) UpdateExpenseSplit(split *models.ExpenseSplit) error {
	return r.db.Save(split).Error
}

// DeleteExpenseSplit deletes an expense split
func (r *ExpenseRepository) DeleteExpenseSplit(id uuid.UUID) error {
	return r.db.Delete(&models.ExpenseSplit{}, id).Error
}

// GetExpenseSplits retrieves all splits for an expense
func (r *ExpenseRepository) GetExpenseSplits(expenseID uuid.UUID) ([]models.ExpenseSplit, error) {
	var splits []models.ExpenseSplit
	err := r.db.Where("expense_id = ?", expenseID).
		Preload("User").
		Find(&splits).Error
	return splits, err
}

// DeleteExpenseSplits deletes all splits for an expense
func (r *ExpenseRepository) DeleteExpenseSplits(expenseID uuid.UUID) error {
	return r.db.Where("expense_id = ?", expenseID).Delete(&models.ExpenseSplit{}).Error
}
