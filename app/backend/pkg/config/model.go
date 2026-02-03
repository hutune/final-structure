package config

import "time"

// BaseConfig contains common configuration fields for all services
type BaseConfig struct {
	App        AppConfig        `yaml:"app"`
	HTTPServer HTTPServerConfig `yaml:"http_server"`
	Logger     LoggerConfig     `yaml:"logger"`
	Database   DatabaseConfig   `yaml:"database"`
	Redis      RedisConfig      `yaml:"redis"`
	Kafka      KafkaConfig      `yaml:"kafka"`
}

// AppConfig contains application metadata
type AppConfig struct {
	Name        string `yaml:"name"`
	Version     string `yaml:"version"`
	Environment string `yaml:"environment"`
}

// HTTPServerConfig contains HTTP server settings
type HTTPServerConfig struct {
	Host         string `yaml:"host"`
	Port         int    `yaml:"port"`
	AllowOrigins string `yaml:"allow_origins"`
	AllowMethods string `yaml:"allow_methods"`
	AllowHeaders string `yaml:"allow_headers"`
	Mode         string `yaml:"mode"` // debug, release, test
	ReadTimeout  string `yaml:"read_timeout"`
	WriteTimeout string `yaml:"write_timeout"`
}

// LoggerConfig contains logging settings
type LoggerConfig struct {
	Level  string `yaml:"level"`  // debug, info, warn, error
	Format string `yaml:"format"` // json, console
}

// DatabaseConfig contains CockroachDB settings
type DatabaseConfig struct {
	Host            string        `yaml:"host"`
	Port            int           `yaml:"port"`
	User            string        `yaml:"user"`
	Password        string        `yaml:"password"` // Should be overridden by env var
	DBName          string        `yaml:"db_name"`
	SSLMode         string        `yaml:"ssl_mode"`
	MaxOpenConns    int           `yaml:"max_open_conns"`
	MaxIdleConns    int           `yaml:"max_idle_conns"`
	ConnMaxLifetime time.Duration `yaml:"conn_max_lifetime"`
	LogLevel        string        `yaml:"log_level"`
}

// RedisConfig contains Redis settings
type RedisConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Password string `yaml:"password"` // Should be overridden by env var
	DB       int    `yaml:"db"`
}

// KafkaConfig contains Kafka settings
type KafkaConfig struct {
	Brokers           string `yaml:"brokers"`
	ClientID          string `yaml:"client_id"`
	GroupID           string `yaml:"group_id"`
	AutoOffsetReset   string `yaml:"auto_offset_reset"`
	SchemaRegistryURL string `yaml:"schema_registry_url"`
}

// TokenConfig contains JWT/PASETO token settings
type TokenConfig struct {
	Secret                     string `yaml:"secret"` // Should be overridden by env var
	AccessTokenExpirationTime  string `yaml:"access_token_expiration_time"`
	RefreshTokenExpirationTime string `yaml:"refresh_token_expiration_time"`
}

// ServiceClientConfig contains settings for calling other services
type ServiceClientConfig struct {
	BaseURL string `yaml:"base_url"`
	Timeout string `yaml:"timeout"`
}
