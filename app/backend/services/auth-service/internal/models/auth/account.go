package auth

import (
	"github.com/google/uuid"
	"rmn-backend/services/auth-service/internal/models"
)

type AuthType string

const (
	AuthTypeCredential AuthType = "credential"
	AuthTypeGoogle     AuthType = "google"
	AuthTypeGitHub     AuthType = "github"
	AuthTypeFacebook   AuthType = "facebook"
)

type AccountStatus string

const (
	AccountStatusActive     AccountStatus = "active"
	AccountStatusInactive   AccountStatus = "inactive"
	AccountStatusUnverified AccountStatus = "unverified"
	AccountStatusDisabled   AccountStatus = "disabled"
)

type Account struct {
	models.BaseModel
	UserID   uuid.UUID     `gorm:"type:uuid;column:user_id;not null;index:idx_user_id" json:"user_id"`
	Email    string        `gorm:"type:varchar(255);column:email;not null;uniqueIndex:idx_email" json:"email"`
	Password string        `gorm:"type:varchar(255);column:password" json:"password,omitempty"`
	AuthType AuthType      `gorm:"type:varchar(20);column:auth_type;not null" json:"auth_type"`
	AuthID   string        `gorm:"type:varchar(255);column:auth_id" json:"auth_id,omitempty"`
	Status   AccountStatus `gorm:"type:varchar(20);column:status;not null;default:'unverified'" json:"status"`
}

func (Account) TableName() string {
	return "accounts"
}

type SuperAdmin struct {
	models.BaseModel
	UserID   uuid.UUID     `gorm:"type:uuid;column:user_id;not null;uniqueIndex:idx_user_id" json:"user_id"`
	Email    string        `gorm:"type:varchar(255);column:email;not null;uniqueIndex:idx_email" json:"email"`
	Password string        `gorm:"type:varchar(255);column:password;not null" json:"password,omitempty"`
	Status   AccountStatus `gorm:"type:varchar(20);column:status;not null;default:'active'" json:"status"`
}

func (SuperAdmin) TableName() string {
	return "super_admins"
}
