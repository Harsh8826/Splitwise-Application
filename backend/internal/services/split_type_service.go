package services

import (
	"errors"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/repository"

	"github.com/google/uuid"
)

// SplitTypeService handles split type-related business logic
type SplitTypeService struct {
	splitTypeRepo *repository.SplitTypeRepository
}

// NewSplitTypeService creates a new split type service
func NewSplitTypeService(splitTypeRepo *repository.SplitTypeRepository) *SplitTypeService {
	return &SplitTypeService{
		splitTypeRepo: splitTypeRepo,
	}
}

// Create creates a new split type
func (s *SplitTypeService) Create(req *models.SplitTypeCreateRequest) (*models.SplitTypeResponse, error) {
	// Check if split type with same name already exists
	existing, _ := s.splitTypeRepo.GetByName(req.Name)
	if existing != nil {
		return nil, errors.New("split type with this name already exists")
	}

	splitType := &models.SplitType{
		Name:        req.Name,
		Description: req.Description,
		IsActive:    true,
	}

	err := s.splitTypeRepo.Create(splitType)
	if err != nil {
		return nil, err
	}

	return s.toSplitTypeResponse(splitType), nil
}

// GetByID retrieves a split type by ID
func (s *SplitTypeService) GetByID(id uuid.UUID) (*models.SplitTypeResponse, error) {
	splitType, err := s.splitTypeRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toSplitTypeResponse(splitType), nil
}

// Update updates a split type
func (s *SplitTypeService) Update(id uuid.UUID, req *models.SplitTypeUpdateRequest) (*models.SplitTypeResponse, error) {
	splitType, err := s.splitTypeRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Check if name is being changed and if it conflicts with existing
	if splitType.Name != req.Name {
		existing, _ := s.splitTypeRepo.GetByName(req.Name)
		if existing != nil {
			return nil, errors.New("split type with this name already exists")
		}
	}

	splitType.Name = req.Name
	splitType.Description = req.Description
	splitType.IsActive = req.IsActive

	err = s.splitTypeRepo.Update(splitType)
	if err != nil {
		return nil, err
	}

	return s.toSplitTypeResponse(splitType), nil
}

// Delete deletes a split type
func (s *SplitTypeService) Delete(id uuid.UUID) error {
	return s.splitTypeRepo.Delete(id)
}

// List retrieves all split types with pagination
func (s *SplitTypeService) List(offset, limit int) ([]models.SplitTypeResponse, error) {
	splitTypes, err := s.splitTypeRepo.List(offset, limit)
	if err != nil {
		return nil, err
	}

	var responses []models.SplitTypeResponse
	for _, splitType := range splitTypes {
		responses = append(responses, *s.toSplitTypeResponse(&splitType))
	}

	return responses, nil
}

// ListActive retrieves all active split types
func (s *SplitTypeService) ListActive() ([]models.SplitTypeResponse, error) {
	splitTypes, err := s.splitTypeRepo.ListActive()
	if err != nil {
		return nil, err
	}

	var responses []models.SplitTypeResponse
	for _, splitType := range splitTypes {
		responses = append(responses, *s.toSplitTypeResponse(&splitType))
	}

	return responses, nil
}

// InitializeDefaultSplitTypes initializes default split types
func (s *SplitTypeService) InitializeDefaultSplitTypes() error {
	return s.splitTypeRepo.InitializeDefaultSplitTypes()
}

// toSplitTypeResponse converts a SplitType to SplitTypeResponse
func (s *SplitTypeService) toSplitTypeResponse(splitType *models.SplitType) *models.SplitTypeResponse {
	return &models.SplitTypeResponse{
		ID:          splitType.ID,
		Name:        splitType.Name,
		Description: splitType.Description,
		IsActive:    splitType.IsActive,
		CreatedAt:   splitType.CreatedAt,
		UpdatedAt:   splitType.UpdatedAt,
	}
}
