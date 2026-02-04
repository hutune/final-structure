package config

import "time"

type AppConfig struct {
	App struct {
		Name    string `yaml:"name" mapstructure:"name"`
		Version string `yaml:"version" mapstructure:"version"`
	} `yaml:"app" mapstructure:"app"`

	HttpServer       HttpServerConfig       `yaml:"http_server" mapstructure:"http_server"`
	GRPCClient       GRPCClientConfig       `yaml:"grpc_client" mapstructure:"grpc_client"`
	Logger           LoggerConfig           `yaml:"logger" mapstructure:"logger"`
	Kafka            KafkaConfig            `yaml:"kafka" mapstructure:"kafka"`
	CockroachDB      CockroachConfig        `yaml:"cockroach_db" mapstructure:"cockroach_db"`
	Token            TokenConfig            `yaml:"token" mapstructure:"token"`
	Redis            RedisConfig            `yaml:"redis" mapstructure:"redis"`
	ExternalServices ExternalServicesConfig `yaml:"external_services" mapstructure:"external_services"`
}

type HttpServerConfig struct {
	Host         string   `yaml:"host" mapstructure:"host"`
	Port         int      `yaml:"port" mapstructure:"port"`
	GRPCPort     int      `yaml:"grpc_port" mapstructure:"grpc_port"`
	AllowOrigins []string `yaml:"allow_origins" mapstructure:"allow_origins"`
	AllowMethods []string `yaml:"allow_methods" mapstructure:"allow_methods"`
	AllowHeaders []string `yaml:"allow_headers" mapstructure:"allow_headers"`
	Mode         string   `yaml:"mode" mapstructure:"mode"`
	LogLevel     string   `yaml:"log_level" mapstructure:"log_level"`
}

type LoggerConfig struct {
	Level string `yaml:"level" mapstructure:"level"`
}

type CockroachConfig struct {
	Host            string        `yaml:"host" mapstructure:"host"`
	Port            int           `yaml:"port" mapstructure:"port"`
	User            string        `yaml:"user" mapstructure:"user"`
	Password        string        `yaml:"password" mapstructure:"password"`
	DBName          string        `yaml:"db_name" mapstructure:"db_name"`
	SSLMode         string        `yaml:"ssl_mode" mapstructure:"ssl_mode"`
	MaxOpenConns    int           `yaml:"max_open_conns" mapstructure:"max_open_conns"`
	MaxIdleConns    int           `yaml:"max_idle_conns" mapstructure:"max_idle_conns"`
	ConnMaxLifetime time.Duration `yaml:"conn_max_lifetime" mapstructure:"conn_max_lifetime"`
	LogLevel        string        `yaml:"log_level" mapstructure:"log_level"`
}

type TokenConfig struct {
	Secret                     string `yaml:"secret" mapstructure:"secret"`
	AccessTokenExpirationTime  int    `yaml:"access_token_expiration_time" mapstructure:"access_token_expiration_time"`
	RefreshTokenExpirationTime int    `yaml:"refresh_token_expiration_time" mapstructure:"refresh_token_expiration_time"`
}

type RedisConfig struct {
	Host     string `yaml:"host" mapstructure:"host"`
	Port     int    `yaml:"port" mapstructure:"port"`
	Password string `yaml:"password" mapstructure:"password"`
}

type KafkaConfig struct {
	Brokers                 string             `yaml:"brokers" mapstructure:"brokers"`
	ClientID                string             `yaml:"client_id" mapstructure:"client_id"`
	GroupID                 string             `yaml:"group_id" mapstructure:"group_id"`
	AutoOffsetReset         string             `yaml:"auto_offset_reset" mapstructure:"auto_offset_reset"`
	EnableAutoCommit        bool               `yaml:"enable_auto_commit" mapstructure:"enable_auto_commit"`
	MaxPollIntervalMs       int                `yaml:"max_poll_interval_ms" mapstructure:"max_poll_interval_ms"`
	SessionTimeoutMs        int                `yaml:"session_timeout_ms" mapstructure:"session_timeout_ms"`
	HeartbeatIntervalMs     int                `yaml:"heartbeat_interval_ms" mapstructure:"heartbeat_interval_ms"`
	RetryBackoffMs          int                `yaml:"retry_backoff_ms" mapstructure:"retry_backoff_ms"`
	FetchMinBytes           int                `yaml:"fetch_min_bytes" mapstructure:"fetch_min_bytes"`
	FetchWaitMaxMs          int                `yaml:"fetch_wait_max_ms" mapstructure:"fetch_wait_max_ms"`
	SchemaRegistryURL       string             `yaml:"schema_registry_url" mapstructure:"schema_registry_url"`
	TopicAutoCreates        []KafkaTopicConfig `yaml:"topic_auto_creates" mapstructure:"topic_auto_creates"`
	ProducerCompressionType string             `yaml:"producer_compression_type" mapstructure:"producer_compression_type"`
}

type KafkaTopicAutoCreatesConfig struct {
	TopicPattern  string `yaml:"topic_pattern" mapstructure:"topic_pattern"`
	NumPartitions int    `yaml:"num_partitions" mapstructure:"num_partitions"`
	NumReplicas   int    `yaml:"num_replicas" mapstructure:"num_replicas"`
}

type KafkaTopicConfig struct {
	TopicPattern  string `yaml:"topic_pattern" mapstructure:"topic_pattern"`
	NumPartitions int    `yaml:"num_partitions" mapstructure:"num_partitions"`
	NumReplicas   int    `yaml:"num_replicas" mapstructure:"num_replicas"`
}

type Config = AppConfig

type GRPCClientConfig struct {
	AddrStoreInfo string `yaml:"addr_store_info" mapstructure:"addr_store_info"`
}

type ExternalServicesConfig struct {
	ViettelBaseURL string `yaml:"viettel_base_url" mapstructure:"viettel_base_url"`
}
