package example

import (
	"rmn-backend/services/auth-service/internal/common/errors"
	"rmn-backend/services/auth-service/internal/models"
	"rmn-backend/services/auth-service/internal/repositories"

	"github.com/google/uuid"
)

type ExampleLogic struct {
	repo *repositories.ExampleRepository
}

func NewExampleLogic(repo *repositories.ExampleRepository) *ExampleLogic {
	return &ExampleLogic{repo: repo}
}

func (l *ExampleLogic) Create(example *models.Example) error {
	if example.Name == "" {
		return errors.ErrUnprocessableEntity
	}

	if example.Status == "" {
		example.Status = "active"
	}

	return l.repo.Create(example)
}

func (l *ExampleLogic) GetByID(id uuid.UUID) (*models.Example, error) {
	example, err := l.repo.GetByID(id)
	if err != nil {
		return nil, errors.ErrNotFound
	}
	return example, nil
}

func (l *ExampleLogic) GetAll(limit, offset int) ([]*models.Example, int64, error) {
	return l.repo.GetAll(limit, offset)
}

func (l *ExampleLogic) Update(example *models.Example) error {
	existing, err := l.repo.GetByID(example.ID)
	if err != nil {
		return errors.ErrNotFound
	}

	if example.Name != "" {
		existing.Name = example.Name
	}
	if example.Description != "" {
		existing.Description = example.Description
	}
	if example.Status != "" {
		existing.Status = example.Status
	}

	return l.repo.Update(existing)
}

func (l *ExampleLogic) Delete(id uuid.UUID) error {
	_, err := l.repo.GetByID(id)
	if err != nil {
		return errors.ErrNotFound
	}
	return l.repo.Delete(id)
}
