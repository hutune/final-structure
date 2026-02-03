package auth

import (
	"github.com/google/uuid"
	"rmn-backend/services/auth-service/internal/models"
)

type ApiKey struct {
	models.BaseModel
	UserID  uuid.UUID `gorm:"type:uuid;column:user_id;not null;index:idx_user_id" json:"user_id"`
	Key     string    `gorm:"type:varchar(255);column:key;not null;uniqueIndex:idx_key" json:"key"`
	Enabled bool      `gorm:"type:boolean;column:enabled;default:true" json:"enabled"`
	Expiry  int64     `gorm:"type:bigint;column:expiry" json:"expiry"`
}

func (ApiKey) TableName() string {
	return "api_keys"
}
