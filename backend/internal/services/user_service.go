package services

import (
	"errors"
	"expense_management_backend/internal/auth"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/repository"

	"github.com/google/uuid"
)

// UserService handles user-related business logic
type UserService struct {
	userRepo   *repository.UserRepository
	jwtManager *auth.JWTManager
}

// NewUserService creates a new user service
func NewUserService(userRepo *repository.UserRepository, jwtManager *auth.JWTManager) *UserService {
	return &UserService{
		userRepo:   userRepo,
		jwtManager: jwtManager,
	}
}

// Register registers a new user
func (s *UserService) Register(req *models.UserRegisterRequest) (string, *models.UserResponse, error) {
	// Check if user already exists
	existingUser, _ := s.userRepo.GetByEmail(req.Email)
	if existingUser != nil {
		return "", nil, errors.New("user with this email already exists")
	}

	// Hash password
	hashedPassword, err := auth.HashPassword(req.Password)
	if err != nil {
		return "", nil, err
	}

	// Create user
	user := &models.User{
		Email:    req.Email,
		Password: hashedPassword,
		Name:     req.Name,
	}

	err = s.userRepo.Create(user)
	if err != nil {
		return "", nil, err
	}

	// Generate JWT token for the newly registered user
	token, err := s.jwtManager.GenerateToken(user.ID, user.Email)
	if err != nil {
		return "", nil, err
	}

	return token, s.toUserResponse(user), nil
}

// Login authenticates a user and returns a JWT token
func (s *UserService) Login(req *models.UserLoginRequest) (string, *models.UserResponse, error) {
	// Get user by email
	user, err := s.userRepo.GetByEmail(req.Email)
	if err != nil {
		return "", nil, errors.New("invalid email or password")
	}

	// Check password
	if !auth.CheckPassword(req.Password, user.Password) {
		return "", nil, errors.New("invalid email or password")
	}

	// Generate JWT token
	token, err := s.jwtManager.GenerateToken(user.ID, user.Email)
	if err != nil {
		return "", nil, err
	}

	return token, s.toUserResponse(user), nil
}

// GetByID retrieves a user by ID
func (s *UserService) GetByID(id uuid.UUID) (*models.UserResponse, error) {
	user, err := s.userRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toUserResponse(user), nil
}

// Update updates a user
func (s *UserService) Update(id uuid.UUID, name string) (*models.UserResponse, error) {
	user, err := s.userRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	user.Name = name
	err = s.userRepo.Update(user)
	if err != nil {
		return nil, err
	}

	return s.toUserResponse(user), nil
}

// Delete deletes a user
func (s *UserService) Delete(id uuid.UUID) error {
	return s.userRepo.Delete(id)
}

// GetUserGroups retrieves all groups a user is a member of
func (s *UserService) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	return s.userRepo.GetUserGroups(userID)
}

// GetUserExpenses retrieves all expenses for a user
func (s *UserService) GetUserExpenses(userID uuid.UUID) ([]models.Expense, error) {
	return s.userRepo.GetUserExpenses(userID)
}

// List retrieves all users with pagination
func (s *UserService) List(offset, limit int) ([]models.User, error) {
	return s.userRepo.List(offset, limit)
}

// SearchByEmail searches for users by email with partial matching
func (s *UserService) SearchByEmail(emailQuery string, offset, limit int) ([]models.User, error) {
	return s.userRepo.SearchByEmail(emailQuery, offset, limit)
}

// toUserResponse converts a User to UserResponse
func (s *UserService) toUserResponse(user *models.User) *models.UserResponse {
	return &models.UserResponse{
		ID:        user.ID,
		Email:     user.Email,
		Name:      user.Name,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}
}
