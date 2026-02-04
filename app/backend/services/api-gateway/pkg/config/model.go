package config

type Config struct {
	AppEnv    string          `yaml:"app_env" mapstructure:"app_env"`
	LogLevel  string          `yaml:"log_level" mapstructure:"log_level"`
	Server    ServerConfig    `yaml:"server" mapstructure:"server"`
	Redis     RedisConfig     `yaml:"redis" mapstructure:"redis"`
	Auth      AuthConfig      `yaml:"auth" mapstructure:"auth"`
	RateLimit RateLimitConfig `yaml:"rate_limit" mapstructure:"rate_limit"`
	Services  []ServiceConfig `yaml:"services" mapstructure:"services"`
}

type ServerConfig struct {
	Port    int `yaml:"port" mapstructure:"port"`
	Timeout int `yaml:"timeout" mapstructure:"timeout"`
}

type RedisConfig struct {
	Host     string `yaml:"host" mapstructure:"host"`
	Port     int    `yaml:"port" mapstructure:"port"`
	Password string `yaml:"password" mapstructure:"password"`
	DB       int    `yaml:"db" mapstructure:"db"`
}

type AuthConfig struct {
	JWTSecret                  string `yaml:"jwt_secret" mapstructure:"jwt_secret"`
	AccessTokenExpirationTime  int    `yaml:"access_token_expiration_time" mapstructure:"access_token_expiration_time"`
	RefreshTokenExpirationTime int    `yaml:"refresh_token_expiration_time" mapstructure:"refresh_token_expiration_time"`
}

type RateLimitConfig struct {
	RequestsPerSecond int `yaml:"requests_per_second" mapstructure:"requests_per_second"`
	Burst             int `yaml:"burst" mapstructure:"burst"`
}

type ServiceConfig struct {
	Name     string   `yaml:"name" mapstructure:"name"`
	BasePath string   `yaml:"base_path" mapstructure:"base_path"`
	Target   string   `yaml:"target" mapstructure:"target"`
	Methods  []string `yaml:"methods" mapstructure:"methods"`
	SkipAuth bool     `yaml:"skip_auth" mapstructure:"skip_auth"`
}
