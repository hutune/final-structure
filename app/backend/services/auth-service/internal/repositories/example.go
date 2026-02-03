package repositories

import (
	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ExampleRepository struct {
	ctx *common.App
}

func NewExampleRepository(ctx *common.App) *ExampleRepository {
	return &ExampleRepository{ctx: ctx}
}

func (r *ExampleRepository) Create(example *models.Example) error {
	return r.ctx.DB.Create(example).Error
}

func (r *ExampleRepository) GetByID(id uuid.UUID) (*models.Example, error) {
	var example models.Example
	err := r.ctx.DB.Where("id = ? AND deleted_at IS NULL", id).First(&example).Error
	if err != nil {
		return nil, err
	}
	return &example, nil
}

func (r *ExampleRepository) GetAll(limit, offset int) ([]*models.Example, int64, error) {
	var examples []*models.Example
	var total int64

	query := r.ctx.DB.Model(&models.Example{}).Where("deleted_at IS NULL")

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := query.Limit(limit).Offset(offset).Find(&examples).Error; err != nil {
		return nil, 0, err
	}

	return examples, total, nil
}

func (r *ExampleRepository) Update(example *models.Example) error {
	return r.ctx.DB.Model(example).Updates(example).Error
}

func (r *ExampleRepository) Delete(id uuid.UUID) error {
	return r.ctx.DB.Model(&models.Example{}).
		Where("id = ?", id).
		Update("deleted_at", gorm.Expr("NOW()")).Error
}
