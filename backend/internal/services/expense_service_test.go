package services

import (
	"expense_management_backend/internal/models"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Mock repositories for testing
type MockExpenseRepository struct {
	mock.Mock
}

func (m *MockExpenseRepository) Create(expense *models.Expense) error {
	args := m.Called(expense)
	return args.Error(0)
}

func (m *MockExpenseRepository) GetByID(id uuid.UUID) (*models.Expense, error) {
	args := m.Called(id)
	return args.Get(0).(*models.Expense), args.Error(1)
}

func (m *MockExpenseRepository) Update(expense *models.Expense) error {
	args := m.Called(expense)
	return args.Error(0)
}

func (m *MockExpenseRepository) Delete(id uuid.UUID) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockExpenseRepository) GetGroupExpenses(groupID uuid.UUID) ([]models.Expense, error) {
	args := m.Called(groupID)
	return args.Get(0).([]models.Expense), args.Error(1)
}

func (m *MockExpenseRepository) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	args := m.Called(userID)
	return args.Get(0).([]models.Expense), args.Error(1)
}

func (m *MockExpenseRepository) CreateExpenseSplit(split *models.ExpenseSplit) error {
	args := m.Called(split)
	return args.Error(0)
}

func (m *MockExpenseRepository) UpdateExpenseSplit(split *models.ExpenseSplit) error {
	args := m.Called(split)
	return args.Error(0)
}

func (m *MockExpenseRepository) DeleteExpenseSplit(id uuid.UUID) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockExpenseRepository) GetExpenseSplits(expenseID uuid.UUID) ([]models.ExpenseSplit, error) {
	args := m.Called(expenseID)
	return args.Get(0).([]models.ExpenseSplit), args.Error(1)
}

func (m *MockExpenseRepository) DeleteExpenseSplits(expenseID uuid.UUID) error {
	args := m.Called(expenseID)
	return args.Error(0)
}

type MockGroupRepository struct {
	mock.Mock
}

func (m *MockGroupRepository) Create(group *models.Group) error {
	args := m.Called(group)
	return args.Error(0)
}

func (m *MockGroupRepository) GetByID(id uuid.UUID) (*models.Group, error) {
	args := m.Called(id)
	return args.Get(0).(*models.Group), args.Error(1)
}

func (m *MockGroupRepository) Update(group *models.Group) error {
	args := m.Called(group)
	return args.Error(0)
}

func (m *MockGroupRepository) Delete(id uuid.UUID) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockGroupRepository) List(offset, limit int) ([]models.Group, error) {
	args := m.Called(offset, limit)
	return args.Get(0).([]models.Group), args.Error(1)
}

func (m *MockGroupRepository) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	args := m.Called(userID)
	return args.Get(0).([]models.Group), args.Error(1)
}

func (m *MockGroupRepository) AddMember(groupID, userID uuid.UUID) error {
	args := m.Called(groupID, userID)
	return args.Error(0)
}

func (m *MockGroupRepository) RemoveMember(groupID, userID uuid.UUID) error {
	args := m.Called(groupID, userID)
	return args.Error(0)
}

func (m *MockGroupRepository) IsMember(groupID, userID uuid.UUID) (bool, error) {
	args := m.Called(groupID, userID)
	return args.Bool(0), args.Error(1)
}

func (m *MockGroupRepository) GetGroupMembers(groupID uuid.UUID) ([]models.GroupMember, error) {
	args := m.Called(groupID)
	return args.Get(0).([]models.GroupMember), args.Error(1)
}

type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(user *models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func (m *MockUserRepository) GetByID(id uuid.UUID) (*models.User, error) {
	args := m.Called(id)
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) GetByEmail(email string) (*models.User, error) {
	args := m.Called(email)
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) Update(user *models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func (m *MockUserRepository) Delete(id uuid.UUID) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockUserRepository) List(offset, limit int) ([]models.User, error) {
	args := m.Called(offset, limit)
	return args.Get(0).([]models.User), args.Error(1)
}

func (m *MockUserRepository) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	args := m.Called(userID)
	return args.Get(0).([]models.Group), args.Error(1)
}

func (m *MockUserRepository) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	args := m.Called(userID)
	return args.Get(0).([]models.Expense), args.Error(1)
}

// Test expense splitting logic
func TestExpenseService_CreateEqualSplits(t *testing.T) {
	// Setup
	mockExpenseRepo := new(MockExpenseRepository)
	mockGroupRepo := new(MockGroupRepository)
	mockUserRepo := new(MockUserRepository)

	service := NewExpenseService(mockExpenseRepo, mockGroupRepo, mockUserRepo)

	// Test data
	groupID := uuid.New()
	userID := uuid.New()
	expense := &models.Expense{
		ID:       uuid.New(),
		GroupID:  groupID,
		PaidByID: userID,
		Amount:   100.0,
	}

	members := []models.GroupMember{
		{UserID: uuid.New()},
		{UserID: uuid.New()},
		{UserID: uuid.New()},
	}

	// Expectations
	mockExpenseRepo.On("CreateExpenseSplit", mock.AnythingOfType("*models.ExpenseSplit")).Return(nil).Times(3)

	// Execute
	err := service.createEqualSplits(expense, members)

	// Assert
	assert.NoError(t, err)
	mockExpenseRepo.AssertExpectations(t)
}

func TestExpenseService_CreatePercentageSplits(t *testing.T) {
	// Setup
	mockExpenseRepo := new(MockExpenseRepository)
	mockGroupRepo := new(MockGroupRepository)
	mockUserRepo := new(MockUserRepository)

	service := NewExpenseService(mockExpenseRepo, mockGroupRepo, mockUserRepo)

	// Test data
	expense := &models.Expense{
		ID:     uuid.New(),
		Amount: 100.0,
	}

	splits := []models.ExpenseSplitInput{
		{UserID: uuid.New(), Percentage: 50.0},
		{UserID: uuid.New(), Percentage: 30.0},
		{UserID: uuid.New(), Percentage: 20.0},
	}

	// Expectations
	mockExpenseRepo.On("CreateExpenseSplit", mock.AnythingOfType("*models.ExpenseSplit")).Return(nil).Times(3)

	// Execute
	err := service.createPercentageSplits(expense, splits)

	// Assert
	assert.NoError(t, err)
	mockExpenseRepo.AssertExpectations(t)
}

func TestExpenseService_CreateCustomSplits(t *testing.T) {
	// Setup
	mockExpenseRepo := new(MockExpenseRepository)
	mockGroupRepo := new(MockGroupRepository)
	mockUserRepo := new(MockUserRepository)

	service := NewExpenseService(mockExpenseRepo, mockGroupRepo, mockUserRepo)

	// Test data
	expense := &models.Expense{
		ID:     uuid.New(),
		Amount: 100.0,
	}

	splits := []models.ExpenseSplitInput{
		{UserID: uuid.New(), Amount: 50.0},
		{UserID: uuid.New(), Amount: 30.0},
		{UserID: uuid.New(), Amount: 20.0},
	}

	// Expectations
	mockExpenseRepo.On("CreateExpenseSplit", mock.AnythingOfType("*models.ExpenseSplit")).Return(nil).Times(3)

	// Execute
	err := service.createCustomSplits(expense, splits)

	// Assert
	assert.NoError(t, err)
	mockExpenseRepo.AssertExpectations(t)
}

func TestExpenseService_CreateCustomSplits_InvalidTotal(t *testing.T) {
	// Setup
	mockExpenseRepo := new(MockExpenseRepository)
	mockGroupRepo := new(MockGroupRepository)
	mockUserRepo := new(MockUserRepository)

	service := NewExpenseService(mockExpenseRepo, mockGroupRepo, mockUserRepo)

	// Test data
	expense := &models.Expense{
		ID:     uuid.New(),
		Amount: 100.0,
	}

	splits := []models.ExpenseSplitInput{
		{UserID: uuid.New(), Amount: 50.0},
		{UserID: uuid.New(), Amount: 30.0},
		{UserID: uuid.New(), Amount: 10.0}, // Total = 90, should be 100
	}

	// Execute
	err := service.createCustomSplits(expense, splits)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "total split amount must equal expense amount")
}

func TestExpenseService_CreatePercentageSplits_InvalidTotal(t *testing.T) {
	// Setup
	mockExpenseRepo := new(MockExpenseRepository)
	mockGroupRepo := new(MockGroupRepository)
	mockUserRepo := new(MockUserRepository)

	service := NewExpenseService(mockExpenseRepo, mockGroupRepo, mockUserRepo)

	// Test data
	expense := &models.Expense{
		ID:     uuid.New(),
		Amount: 100.0,
	}

	splits := []models.ExpenseSplitInput{
		{UserID: uuid.New(), Percentage: 50.0},
		{UserID: uuid.New(), Percentage: 30.0},
		{UserID: uuid.New(), Percentage: 10.0}, // Total = 90%, should be 100%
	}

	// Execute
	err := service.createPercentageSplits(expense, splits)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "total percentage must equal 100")
}
