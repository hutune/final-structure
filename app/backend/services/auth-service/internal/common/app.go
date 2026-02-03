package common

import (
	"rmn-backend/pkg/logger"
	"rmn-backend/services/auth-service/pkg/config"
	"rmn-backend/services/auth-service/pkg/redis"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

type App struct {
	Cfg    *config.Config
	DB     *gorm.DB
	Redis  *redis.RedisClient
	Minio  *minio.Client
	Logger *logger.ZeroLogger
}
