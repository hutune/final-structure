package models

import (
	"rmn-backend/services/auth-service/internal/common/errors"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Example represents an example entity model
type Example struct {
	BaseModel
	Name        string `gorm:"column:name;type:varchar(255);not null" json:"name"`
	Description string `gorm:"column:description;type:text" json:"description"`
	Status      string `gorm:"column:status;type:varchar(50);default:'active'" json:"status"`
}

func (Example) TableName() string {
	return "examples"
}

func (e *Example) BeforeCreate(tx *gorm.DB) error {
	if e.ID == uuid.Nil {
		e.ID = uuid.New()
	}
	return nil
}

func (e *Example) BeforeUpdate(tx *gorm.DB) error {
	now := time.Now()
	e.UpdatedAt = &now
	return nil
}

func (e *Example) Delete(tx *gorm.DB) error {
	if e.DeletedAt != nil {
		return errors.ErrNotFound
	}

	now := time.Now()
	e.DeletedAt = &now

	return nil
}
