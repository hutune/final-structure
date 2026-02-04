package main

import (
	"fmt"
	"log"
	pkgconfig "rmn-backend/pkg/config"
	"rmn-backend/pkg/logger"
	"rmn-backend/services/user-service/internal/app"
	"rmn-backend/services/user-service/internal/common"
	"rmn-backend/services/user-service/internal/migrations"
	"rmn-backend/services/user-service/pkg/config"
	"rmn-backend/services/user-service/pkg/database"
	"rmn-backend/services/user-service/pkg/redis"
)

func main() {
	conf := &config.Config{}
	configDir := pkgconfig.GetConfigPath()
	if err := pkgconfig.LoadConfig(configDir, conf); err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize Zerolog
	zeroLogger, err := logger.NewLogger(logger.Config{
		Level:   logger.Level(conf.HttpServer.LogLevel),
		Service: "user-service",
	})
	if err != nil {
		fmt.Println("Failed to initialize zerolog", err)
		return
	}
	fmt.Println("Configuration loaded successfully")
	// Init database
	db, err := database.InitCockroadDB(conf.CockroachDB)
	if err != nil {
		fmt.Println("Failed to connect to CockroadDB", err)
		return
	}
	fmt.Println("CockroadDB database connected successfully")

	err = database.Migrate(db, migrations.FS)
	if err != nil {
		fmt.Println("Failed to migrate database", err)
		return
	}
	fmt.Println("Database migrated successfully")

	redisClient, err := redis.InitRedis(conf.Redis)
	if err != nil {
		fmt.Println("Failed to connect to redis", err)
		return
	}
	fmt.Println("Redis database connected successfully")

	defer func() {
		redisClient.Close()
		sqlDB, _ := db.DB()
		sqlDB.Close()
	}()

	appContext := &common.App{
		Cfg:    conf,
		DB:     db,
		Redis:  redisClient,
		Logger: zeroLogger,
	}

	server := app.NewServer(appContext)
	server.Run()
}
