package services

import (
	"errors"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/repository"

	"github.com/google/uuid"
)

// ExpenseService handles expense-related business logic
type ExpenseService struct {
	expenseRepo repository.ExpenseRepositoryInterface
	groupRepo   repository.GroupRepositoryInterface
	userRepo    repository.UserRepositoryInterface
}

// NewExpenseService creates a new expense service
func NewExpenseService(expenseRepo repository.ExpenseRepositoryInterface, groupRepo repository.GroupRepositoryInterface, userRepo repository.UserRepositoryInterface) *ExpenseService {
	return &ExpenseService{
		expenseRepo: expenseRepo,
		groupRepo:   groupRepo,
		userRepo:    userRepo,
	}
}

// Create creates a new expense with splits
func (s *ExpenseService) Create(req *models.ExpenseCreateRequest, paidByID uuid.UUID) (*models.ExpenseResponse, error) {
	// Check if user is a member of the group
	isMember, err := s.groupRepo.IsMember(req.GroupID, paidByID)
	if err != nil {
		return nil, err
	}
	if !isMember {
		return nil, errors.New("user is not a member of this group")
	}

	// Create expense
	expense := &models.Expense{
		GroupID:     req.GroupID,
		PaidByID:    paidByID,
		Title:       req.Title,
		Description: req.Description,
		Amount:      req.Amount,
		SplitType:   req.SplitType,
	}

	err = s.expenseRepo.Create(expense)
	if err != nil {
		return nil, err
	}

	// Create expense splits based on split type
	err = s.createExpenseSplits(expense, req)
	if err != nil {
		return nil, err
	}

	// Get the complete expense with splits
	completeExpense, err := s.expenseRepo.GetByID(expense.ID)
	if err != nil {
		return nil, err
	}

	return s.toExpenseResponse(completeExpense), nil
}

// GetByID retrieves an expense by ID
func (s *ExpenseService) GetByID(id uuid.UUID) (*models.ExpenseResponse, error) {
	expense, err := s.expenseRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toExpenseResponse(expense), nil
}

// Update updates an expense
func (s *ExpenseService) Update(id uuid.UUID, req *models.ExpenseUpdateRequest, userID uuid.UUID) (*models.ExpenseResponse, error) {
	expense, err := s.expenseRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Check if user is the one who paid for the expense
	if expense.PaidByID != userID {
		return nil, errors.New("only the person who paid can update the expense")
	}

	expense.Title = req.Title
	expense.Description = req.Description
	expense.Amount = req.Amount
	expense.SplitType = req.SplitType

	err = s.expenseRepo.Update(expense)
	if err != nil {
		return nil, err
	}

	// Delete existing splits and create new ones
	err = s.expenseRepo.DeleteExpenseSplits(expense.ID)
	if err != nil {
		return nil, err
	}

	// Create new splits
	expenseReq := &models.ExpenseCreateRequest{
		GroupID:     expense.GroupID,
		Title:       req.Title,
		Description: req.Description,
		Amount:      req.Amount,
		SplitType:   req.SplitType,
		Splits:      req.Splits,
	}
	err = s.createExpenseSplits(expense, expenseReq)
	if err != nil {
		return nil, err
	}

	// Get the updated expense
	updatedExpense, err := s.expenseRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	return s.toExpenseResponse(updatedExpense), nil
}

// Delete deletes an expense
func (s *ExpenseService) Delete(id uuid.UUID, userID uuid.UUID) error {
	expense, err := s.expenseRepo.GetByID(id)
	if err != nil {
		return err
	}

	// Check if user is the one who paid for the expense
	if expense.PaidByID != userID {
		return errors.New("only the person who paid can delete the expense")
	}

	return s.expenseRepo.Delete(id)
}

// GetGroupExpenses retrieves all expenses for a group
func (s *ExpenseService) GetGroupExpenses(groupID uuid.UUID) ([]models.Expense, error) {
	return s.expenseRepo.GetGroupExpenses(groupID)
}

// GetUserExpenses retrieves all expenses for a user
func (s *ExpenseService) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	return s.expenseRepo.GetUserExpenses(userID)
}

// createExpenseSplits creates expense splits based on the split type
func (s *ExpenseService) createExpenseSplits(expense *models.Expense, req *models.ExpenseCreateRequest) error {
	// Get group members
	members, err := s.groupRepo.GetGroupMembers(expense.GroupID)
	if err != nil {
		return err
	}

	switch req.SplitType {
	case "equal":
		return s.createEqualSplits(expense, members)
	case "percentage":
		return s.createPercentageSplits(expense, req.Splits)
	case "custom":
		return s.createCustomSplits(expense, req.Splits)
	default:
		return errors.New("invalid split type")
	}
}

// createEqualSplits creates equal splits among all group members
func (s *ExpenseService) createEqualSplits(expense *models.Expense, members []models.GroupMember) error {
	if len(members) == 0 {
		return errors.New("no members in group")
	}

	amountPerPerson := expense.Amount / float64(len(members))
	percentagePerPerson := 100.0 / float64(len(members))

	for _, member := range members {
		split := &models.ExpenseSplit{
			ExpenseID:  expense.ID,
			UserID:     member.UserID,
			Amount:     amountPerPerson,
			Percentage: percentagePerPerson,
		}
		err := s.expenseRepo.CreateExpenseSplit(split)
		if err != nil {
			return err
		}
	}

	return nil
}

// createPercentageSplits creates splits based on percentages
func (s *ExpenseService) createPercentageSplits(expense *models.Expense, splits []models.ExpenseSplitInput) error {
	if len(splits) == 0 {
		return errors.New("no splits provided for percentage split")
	}

	var totalPercentage float64
	for _, split := range splits {
		totalPercentage += split.Percentage
	}

	if totalPercentage != 100.0 {
		return errors.New("total percentage must equal 100")
	}

	for _, split := range splits {
		amount := (expense.Amount * split.Percentage) / 100.0
		expenseSplit := &models.ExpenseSplit{
			ExpenseID:  expense.ID,
			UserID:     split.UserID,
			Amount:     amount,
			Percentage: split.Percentage,
		}
		err := s.expenseRepo.CreateExpenseSplit(expenseSplit)
		if err != nil {
			return err
		}
	}

	return nil
}

// createCustomSplits creates splits based on custom amounts
func (s *ExpenseService) createCustomSplits(expense *models.Expense, splits []models.ExpenseSplitInput) error {
	if len(splits) == 0 {
		return errors.New("no splits provided for custom split")
	}

	var totalAmount float64
	for _, split := range splits {
		totalAmount += split.Amount
	}

	if totalAmount != expense.Amount {
		return errors.New("total split amount must equal expense amount")
	}

	for _, split := range splits {
		percentage := (split.Amount / expense.Amount) * 100.0
		expenseSplit := &models.ExpenseSplit{
			ExpenseID:  expense.ID,
			UserID:     split.UserID,
			Amount:     split.Amount,
			Percentage: percentage,
		}
		err := s.expenseRepo.CreateExpenseSplit(expenseSplit)
		if err != nil {
			return err
		}
	}

	return nil
}

// toExpenseResponse converts an Expense to ExpenseResponse
func (s *ExpenseService) toExpenseResponse(expense *models.Expense) *models.ExpenseResponse {
	splits := make([]models.ExpenseSplitResponse, len(expense.Splits))
	for i, split := range expense.Splits {
		splits[i] = models.ExpenseSplitResponse{
			ID:         split.ID,
			UserID:     split.UserID,
			Amount:     split.Amount,
			Percentage: split.Percentage,
			User: models.UserResponse{
				ID:        split.User.ID,
				Email:     split.User.Email,
				Name:      split.User.Name,
				CreatedAt: split.User.CreatedAt,
				UpdatedAt: split.User.UpdatedAt,
			},
		}
	}

	return &models.ExpenseResponse{
		ID:          expense.ID,
		GroupID:     expense.GroupID,
		PaidByID:    expense.PaidByID,
		Title:       expense.Title,
		Description: expense.Description,
		Amount:      expense.Amount,
		SplitType:   expense.SplitType,
		CreatedAt:   expense.CreatedAt,
		UpdatedAt:   expense.UpdatedAt,
		PaidBy: models.UserResponse{
			ID:        expense.PaidBy.ID,
			Email:     expense.PaidBy.Email,
			Name:      expense.PaidBy.Name,
			CreatedAt: expense.PaidBy.CreatedAt,
			UpdatedAt: expense.PaidBy.UpdatedAt,
		},
		Splits: splits,
	}
}
