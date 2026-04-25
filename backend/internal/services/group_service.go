package services

import (
	"errors"
	"expense_management_backend/internal/models"
	"expense_management_backend/internal/repository"

	"github.com/google/uuid"
)

// GroupService handles group-related business logic
type GroupService struct {
	groupRepo *repository.GroupRepository
	userRepo  *repository.UserRepository
}

// NewGroupService creates a new group service
func NewGroupService(groupRepo *repository.GroupRepository, userRepo *repository.UserRepository) *GroupService {
	return &GroupService{
		groupRepo: groupRepo,
		userRepo:  userRepo,
	}
}

// Create creates a new group
func (s *GroupService) Create(req *models.GroupCreateRequest, createdBy uuid.UUID) (*models.GroupResponse, error) {
	group := &models.Group{
		Name:        req.Name,
		Description: req.Description,
		CreatedBy:   createdBy,
	}

	err := s.groupRepo.Create(group)
	if err != nil {
		return nil, err
	}

	// Add creator as a member
	err = s.groupRepo.AddMember(group.ID, createdBy)
	if err != nil {
		return nil, err
	}

	return s.toGroupResponse(group), nil
}

// GetByID retrieves a group by ID
func (s *GroupService) GetByID(id uuid.UUID) (*models.Group, error) {
	return s.groupRepo.GetByID(id)
}

// Update updates a group
func (s *GroupService) Update(id uuid.UUID, req *models.GroupUpdateRequest, userID uuid.UUID) (*models.GroupResponse, error) {
	group, err := s.groupRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Check if user is the creator
	if group.CreatedBy != userID {
		return nil, errors.New("only group creator can update the group")
	}

	group.Name = req.Name
	group.Description = req.Description

	err = s.groupRepo.Update(group)
	if err != nil {
		return nil, err
	}

	return s.toGroupResponse(group), nil
}

// Delete deletes a group
func (s *GroupService) Delete(id uuid.UUID, userID uuid.UUID) error {
	group, err := s.groupRepo.GetByID(id)
	if err != nil {
		return err
	}

	// Check if user is the creator
	if group.CreatedBy != userID {
		return errors.New("only group creator can delete the group")
	}

	return s.groupRepo.Delete(id)
}

// List retrieves all groups with pagination
func (s *GroupService) List(offset, limit int) ([]models.Group, error) {
	return s.groupRepo.List(offset, limit)
}

// GetUserGroups retrieves all groups a user is a member of
func (s *GroupService) GetUserGroups(userID uuid.UUID) ([]models.Group, error) {
	return s.groupRepo.GetUserGroups(userID)
}

// AddMember adds a user to a group
func (s *GroupService) AddMember(groupID, userID, addedBy uuid.UUID) error {
	// Check if user exists
	_, err := s.userRepo.GetByID(userID)
	if err != nil {
		return errors.New("user not found")
	}

	// Check if user is already a member
	isMember, err := s.groupRepo.IsMember(groupID, userID)
	if err != nil {
		return err
	}
	if isMember {
		return errors.New("user is already a member of this group")
	}

	return s.groupRepo.AddMember(groupID, userID)
}

// AddMemberByEmail adds a user to a group by their email address
func (s *GroupService) AddMemberByEmail(groupID uuid.UUID, email string, addedBy uuid.UUID) error {
	// Find user by email
	user, err := s.userRepo.GetByEmail(email)
	if err != nil {
		return errors.New("user not found with this email address")
	}

	// Check if user is already a member
	isMember, err := s.groupRepo.IsMember(groupID, user.ID)
	if err != nil {
		return err
	}
	if isMember {
		return errors.New("user is already a member of this group")
	}

	return s.groupRepo.AddMember(groupID, user.ID)
}

// RemoveMember removes a user from a group
func (s *GroupService) RemoveMember(groupID, userID, removedBy uuid.UUID) error {
	group, err := s.groupRepo.GetByID(groupID)
	if err != nil {
		return err
	}

	// Only group creator can remove members
	if group.CreatedBy != removedBy {
		return errors.New("only group creator can remove members")
	}

	// Cannot remove the creator
	if userID == group.CreatedBy {
		return errors.New("cannot remove group creator")
	}

	return s.groupRepo.RemoveMember(groupID, userID)
}

// GetGroupMembers retrieves all members of a group
func (s *GroupService) GetGroupMembers(groupID uuid.UUID) ([]models.GroupMember, error) {
	return s.groupRepo.GetGroupMembers(groupID)
}

// IsMember checks if a user is a member of a group
func (s *GroupService) IsMember(groupID, userID uuid.UUID) (bool, error) {
	return s.groupRepo.IsMember(groupID, userID)
}

// toGroupResponse converts a Group to GroupResponse
func (s *GroupService) toGroupResponse(group *models.Group) *models.GroupResponse {
	return &models.GroupResponse{
		ID:          group.ID,
		Name:        group.Name,
		Description: group.Description,
		CreatedBy:   group.CreatedBy,
		CreatedAt:   group.CreatedAt,
		UpdatedAt:   group.UpdatedAt,
		MemberCount: len(group.Members),
	}
}
