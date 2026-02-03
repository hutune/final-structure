package database

import (
	"embed"
	"fmt"

	"github.com/pressly/goose/v3"
	"github.com/rs/zerolog/log"
	"gorm.io/gorm"
)

func Migrate(db *gorm.DB, fs embed.FS) error {
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB from GORM: %v", err)
	}

	log.Info().Msg("Running Database migrations using goose")

	goose.SetLogger(&GooseLogger{})
	// Set the base filesystem for migrations
	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("database migrations: could not set dialect: %v", err)
	}

	// Run migrations
	goose.SetBaseFS(fs)
	if err := goose.Up(sqlDB, "."); err != nil {
		return fmt.Errorf("database migrations: could not apply migrations: %v", err)
	}

	log.Info().Msg("Database migrations applied successfully")
	return nil
}
