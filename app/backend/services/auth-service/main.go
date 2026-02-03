package main

import (
	"flag"
	"fmt"
	"log"
	"rmn-backend/pkg/logger"
	"rmn-backend/services/auth-service/internal/app"
	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/migrations"
	"rmn-backend/services/auth-service/pkg/config"
	"rmn-backend/services/auth-service/pkg/database"
	"rmn-backend/services/auth-service/pkg/redis"
)

var (
	confPath = flag.String("config", "./config/app.development.yaml", "config file path")
)

func main() {
	conf, err := config.LoadConfig(*confPath)
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize Zerolog
	zeroLogger, err := logger.NewLogger(logger.Config{
		Level:   logger.Level(conf.HttpServer.LogLevel),
		Service: "auth-service",
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
