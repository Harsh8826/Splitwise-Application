package services

import (
	"errors"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/repository"

	"github.com/google/uuid"
)

// SettlementService handles settlement-related business logic
type SettlementService struct {
	settlementRepo *repository.SettlementRepository
	expenseRepo    *repository.ExpenseRepository
	groupRepo      *repository.GroupRepository
	userRepo       *repository.UserRepository
}

// NewSettlementService creates a new settlement service
func NewSettlementService(settlementRepo *repository.SettlementRepository, expenseRepo *repository.ExpenseRepository, groupRepo *repository.GroupRepository, userRepo *repository.UserRepository) *SettlementService {
	return &SettlementService{
		settlementRepo: settlementRepo,
		expenseRepo:    expenseRepo,
		groupRepo:      groupRepo,
		userRepo:       userRepo,
	}
}

// Create creates a new settlement
func (s *SettlementService) Create(req *models.SettlementCreateRequest, fromUserID uuid.UUID) (*models.SettlementResponse, error) {
	// Check if both users are members of the group
	isFromUserMember, err := s.groupRepo.IsMember(req.GroupID, fromUserID)
	if err != nil {
		return nil, err
	}
	if !isFromUserMember {
		return nil, errors.New("from user is not a member of this group")
	}

	isToUserMember, err := s.groupRepo.IsMember(req.GroupID, req.ToUserID)
	if err != nil {
		return nil, err
	}
	if !isToUserMember {
		return nil, errors.New("to user is not a member of this group")
	}

	// Check if users are different
	if fromUserID == req.ToUserID {
		return nil, errors.New("cannot settle with yourself")
	}

	settlement := &models.Settlement{
		FromUserID:  fromUserID,
		ToUserID:    req.ToUserID,
		GroupID:     req.GroupID,
		Amount:      req.Amount,
		Description: req.Description,
	}

	err = s.settlementRepo.Create(settlement)
	if err != nil {
		return nil, err
	}

	// Get the complete settlement
	completeSettlement, err := s.settlementRepo.GetByID(settlement.ID)
	if err != nil {
		return nil, err
	}

	return s.toSettlementResponse(completeSettlement), nil
}

// GetByID retrieves a settlement by ID
func (s *SettlementService) GetByID(id uuid.UUID) (*models.SettlementResponse, error) {
	settlement, err := s.settlementRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toSettlementResponse(settlement), nil
}

// Update updates a settlement
func (s *SettlementService) Update(id uuid.UUID, amount float64, description string, userID uuid.UUID) (*models.SettlementResponse, error) {
	settlement, err := s.settlementRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Check if user is the one who made the settlement
	if settlement.FromUserID != userID {
		return nil, errors.New("only the person who made the settlement can update it")
	}

	settlement.Amount = amount
	settlement.Description = description

	err = s.settlementRepo.Update(settlement)
	if err != nil {
		return nil, err
	}

	return s.toSettlementResponse(settlement), nil
}

// Delete deletes a settlement
func (s *SettlementService) Delete(id uuid.UUID, userID uuid.UUID) error {
	settlement, err := s.settlementRepo.GetByID(id)
	if err != nil {
		return err
	}

	// Check if user is the one who made the settlement
	if settlement.FromUserID != userID {
		return errors.New("only the person who made the settlement can delete it")
	}

	return s.settlementRepo.Delete(id)
}

// GetGroupSettlements retrieves all settlements for a group
func (s *SettlementService) GetGroupSettlements(groupID uuid.UUID) ([]models.Settlement, error) {
	return s.settlementRepo.GetGroupSettlements(groupID)
}

// GetUserSettlements retrieves all settlements for a user
func (s *SettlementService) GetUserSettlements(userID uuid.UUID) ([]models.Settlement, error) {
	return s.settlementRepo.GetUserSettlements(userID)
}

// GetUserSettlementsInGroup retrieves all settlements for a user in a specific group
func (s *SettlementService) GetUserSettlementsInGroup(userID, groupID uuid.UUID) ([]models.Settlement, error) {
	return s.settlementRepo.GetUserSettlementsInGroup(userID, groupID)
}

// CalculateGroupBalance calculates the balance for each user in a group
func (s *SettlementService) CalculateGroupBalance(groupID uuid.UUID) (*models.GroupBalance, error) {
	// Get group
	group, err := s.groupRepo.GetByID(groupID)
	if err != nil {
		return nil, err
	}

	// Get all expenses for the group
	expenses, err := s.expenseRepo.GetGroupExpenses(groupID)
	if err != nil {
		return nil, err
	}

	// Calculate total expenses
	var totalExpenses float64
	for _, expense := range expenses {
		totalExpenses += expense.Amount
	}

	// Calculate balances for each user
	balances := make(map[uuid.UUID]float64)

	// Initialize balances for all members
	for _, member := range group.Members {
		balances[member.UserID] = 0.0
	}

	// Calculate what each user paid and what they owe
	for _, expense := range expenses {
		// Add what the payer paid
		balances[expense.PaidByID] += expense.Amount

		// Subtract what each person owes
		for _, split := range expense.Splits {
			balances[split.UserID] -= split.Amount
		}
	}

	// Get settlements and adjust balances
	settlements, err := s.settlementRepo.GetGroupSettlements(groupID)
	if err != nil {
		return nil, err
	}

	for _, settlement := range settlements {
		balances[settlement.FromUserID] -= settlement.Amount
		balances[settlement.ToUserID] += settlement.Amount
	}

	// Convert to response format
	balanceResponses := make([]models.Balance, 0, len(balances))
	for userID, balance := range balances {
		user, err := s.userRepo.GetByID(userID)
		if err != nil {
			continue
		}
		balanceResponses = append(balanceResponses, models.Balance{
			UserID:   userID,
			UserName: user.Name,
			Balance:  balance,
		})
	}

	return &models.GroupBalance{
		GroupID:       groupID,
		GroupName:     group.Name,
		Balances:      balanceResponses,
		TotalExpenses: totalExpenses,
	}, nil
}

// toSettlementResponse converts a Settlement to SettlementResponse
func (s *SettlementService) toSettlementResponse(settlement *models.Settlement) *models.SettlementResponse {
	return &models.SettlementResponse{
		ID:          settlement.ID,
		FromUserID:  settlement.FromUserID,
		ToUserID:    settlement.ToUserID,
		GroupID:     settlement.GroupID,
		Amount:      settlement.Amount,
		Description: settlement.Description,
		CreatedAt:   settlement.CreatedAt,
		UpdatedAt:   settlement.UpdatedAt,
		FromUser: models.UserResponse{
			ID:        settlement.FromUser.ID,
			Email:     settlement.FromUser.Email,
			Name:      settlement.FromUser.Name,
			CreatedAt: settlement.FromUser.CreatedAt,
			UpdatedAt: settlement.FromUser.UpdatedAt,
		},
		ToUser: models.UserResponse{
			ID:        settlement.ToUser.ID,
			Email:     settlement.ToUser.Email,
			Name:      settlement.ToUser.Name,
			CreatedAt: settlement.ToUser.CreatedAt,
			UpdatedAt: settlement.ToUser.UpdatedAt,
		},
	}
}
