package auth

import (
	"time"

	"github.com/google/uuid"
	"rmn-backend/services/auth-service/internal/models"
)

type Session struct {
	models.BaseModel
	UserID       uuid.UUID  `gorm:"type:uuid;column:user_id;not null;index:idx_user_id" json:"user_id"`
	RefreshToken string     `gorm:"type:varchar(255);column:refresh_token;not null;uniqueIndex:idx_refresh_token" json:"refresh_token"`
	IPAddress    string     `gorm:"type:varchar(45);column:ip_address" json:"ip_address"`
	UserAgent    string     `gorm:"type:text;column:user_agent" json:"user_agent"`
	ExpiredAt    time.Time  `gorm:"type:timestamp;column:expired_at;not null" json:"expired_at"`
	RevokedAt    *time.Time `gorm:"type:timestamp;column:revoked_at" json:"revoked_at"`
	IsSuperAdmin bool       `gorm:"type:boolean;column:is_super_admin;default:false" json:"is_super_admin"`
}

func (Session) TableName() string {
	return "sessions"
}
