package config

import "time"

type AppConfig struct {
	App struct {
		Name    string `mapstructure:"name"`
		Version string `mapstructure:"version"`
	} `mapstructure:"app"`

	HttpServer       HttpServerConfig       `mapstructure:"http_server"`
	GRPCClient       GRPCClientConfig       `mapstructure:"grpc_client"`
	Logger           LoggerConfig           `mapstructure:"logger"`
	Kafka            KafkaConfig            `mapstructure:"kafka"`
	CockroachDB      CockroachConfig        `mapstructure:"cockroach_db"`
	Token            TokenConfig            `mapstructure:"token"`
	Redis            RedisConfig            `mapstructure:"redis"`
	ExternalServices ExternalServicesConfig `mapstructure:"external_services"`
}

type HttpServerConfig struct {
	Host         string   `mapstructure:"host"`
	Port         int      `mapstructure:"port"`
	GRPCPort     int      `mapstructure:"grpc_port"`
	AllowOrigins []string `mapstructure:"allow_origins"`
	AllowMethods []string `mapstructure:"allow_methods"`
	AllowHeaders []string `mapstructure:"allow_headers"`
	Mode         string   `mapstructure:"mode"`
	LogLevel     string   `mapstructure:"log_level"`
}

type LoggerConfig struct {
	Level string `mapstructure:"level"`
}

type CockroachConfig struct {
	Host            string        `mapstructure:"host"`
	Port            int           `mapstructure:"port"`
	User            string        `mapstructure:"user"`
	Password        string        `mapstructure:"password"`
	DBName          string        `mapstructure:"db_name"`
	SSLMode         string        `mapstructure:"ssl_mode"`
	MaxOpenConns    int           `mapstructure:"max_open_conns"`
	MaxIdleConns    int           `mapstructure:"max_idle_conns"`
	ConnMaxLifetime time.Duration `mapstructure:"conn_max_lifetime"`
	LogLevel        string        `mapstructure:"log_level"`
}

type TokenConfig struct {
	Secret                     string `mapstructure:"secret"`
	AccessTokenExpirationTime  int    `mapstructure:"access_token_expiration_time"`
	RefreshTokenExpirationTime int    `mapstructure:"refresh_token_expiration_time"`
}

type RedisConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Password string `mapstructure:"password"`
}

type KafkaConfig struct {
	Brokers                 string             `mapstructure:"brokers"`
	ClientID                string             `mapstructure:"client_id"`
	GroupID                 string             `mapstructure:"group_id"`
	AutoOffsetReset         string             `mapstructure:"auto_offset_reset"`
	EnableAutoCommit        bool               `mapstructure:"enable_auto_commit"`
	MaxPollIntervalMs       int                `mapstructure:"max_poll_interval_ms"`
	SessionTimeoutMs        int                `mapstructure:"session_timeout_ms"`
	HeartbeatIntervalMs     int                `mapstructure:"heartbeat_interval_ms"`
	RetryBackoffMs          int                `mapstructure:"retry_backoff_ms"`
	FetchMinBytes           int                `mapstructure:"fetch_min_bytes"`
	FetchWaitMaxMs          int                `mapstructure:"fetch_wait_max_ms"`
	SchemaRegistryURL       string             `mapstructure:"schema_registry_url"`
	TopicAutoCreates        []KafkaTopicConfig `mapstructure:"topic_auto_creates"`
	ProducerCompressionType string             `mapstructure:"producer_compression_type"`
}

type KafkaTopicAutoCreatesConfig struct {
	TopicPattern  string `mapstructure:"topic_pattern"`
	NumPartitions int    `mapstructure:"num_partitions"`
	NumReplicas   int    `mapstructure:"num_replicas"`
}

type KafkaTopicConfig struct {
	TopicPattern  string `mapstructure:"topic_pattern"`
	NumPartitions int    `mapstructure:"num_partitions"`
	NumReplicas   int    `mapstructure:"num_replicas"`
}

type Config = AppConfig

type GRPCClientConfig struct {
	AddrStoreInfo string `mapstructure:"addr_store_info"`
}

type ExternalServicesConfig struct {
	ViettelBaseURL string `mapstructure:"viettel_base_url"`
}
