package config

import (
	"fmt"
	"os"
	"path/filepath"
	"reflect"
	"strconv"
	"strings"

	"gopkg.in/yaml.v3"
)

// LoadConfig loads configuration from YAML files and environment variables.
// Load order: config.yaml → config.{env}.yaml → Environment Variables override
//
// Sensitive data should be passed via environment variables.
// Environment variables override YAML values using the format: SECTION_KEY
// Example: HTTP_SERVER_PORT=8080 overrides http_server.port in YAML
func LoadConfig(configDir string, cfg interface{}) error {
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "development"
	}

	// 1. Load base config.yaml (if exists)
	baseConfigPath := filepath.Join(configDir, "config.yaml")
	if err := loadYAMLFile(baseConfigPath, cfg); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("load base config: %w", err)
	}

	// 2. Load environment-specific config (config.{env}.yaml)
	envConfigPath := filepath.Join(configDir, fmt.Sprintf("config.%s.yaml", env))
	if err := loadYAMLFile(envConfigPath, cfg); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("load env config: %w", err)
	}

	// 3. Fallback: Load legacy app.{env}.yaml (backward compatibility)
	legacyConfigPath := filepath.Join(configDir, fmt.Sprintf("app.%s.yaml", env))
	if err := loadYAMLFile(legacyConfigPath, cfg); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("load legacy config: %w", err)
	}

	// 4. Override with environment variables
	applyEnvOverrides(cfg)

	return nil
}

// loadYAMLFile loads a YAML file into the config struct
func loadYAMLFile(path string, cfg interface{}) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	if err := yaml.Unmarshal(data, cfg); err != nil {
		return fmt.Errorf("parse yaml %s: %w", path, err)
	}

	return nil
}

// applyEnvOverrides applies environment variable overrides to config struct.
// Format: SECTION_KEY (uppercase, underscore-separated)
// Example: HTTP_SERVER_PORT → http_server.port
func applyEnvOverrides(cfg interface{}) {
	applyEnvOverridesRecursive(reflect.ValueOf(cfg), "")
}

func applyEnvOverridesRecursive(v reflect.Value, prefix string) {
	if v.Kind() == reflect.Ptr {
		v = v.Elem()
	}
	if v.Kind() != reflect.Struct {
		return
	}

	t := v.Type()
	for i := 0; i < v.NumField(); i++ {
		field := v.Field(i)
		fieldType := t.Field(i)

		if !field.CanSet() {
			continue
		}

		// Get yaml tag or field name
		yamlTag := fieldType.Tag.Get("yaml")
		if yamlTag == "" || yamlTag == "-" {
			yamlTag = strings.ToLower(fieldType.Name)
		}
		yamlTag = strings.Split(yamlTag, ",")[0]

		// Build env key
		envKey := yamlTag
		if prefix != "" {
			envKey = prefix + "_" + yamlTag
		}
		envKey = strings.ToUpper(strings.ReplaceAll(envKey, "-", "_"))

		// Handle nested structs
		if field.Kind() == reflect.Struct {
			applyEnvOverridesRecursive(field, envKey)
			continue
		}

		// Check if env var exists
		envVal := os.Getenv(envKey)
		if envVal == "" {
			continue
		}

		// Set value based on field type
		setFieldFromEnv(field, envVal)
	}
}

func setFieldFromEnv(field reflect.Value, envVal string) {
	switch field.Kind() {
	case reflect.String:
		field.SetString(envVal)
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		if val, err := strconv.ParseInt(envVal, 10, 64); err == nil {
			field.SetInt(val)
		}
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		if val, err := strconv.ParseUint(envVal, 10, 64); err == nil {
			field.SetUint(val)
		}
	case reflect.Float32, reflect.Float64:
		if val, err := strconv.ParseFloat(envVal, 64); err == nil {
			field.SetFloat(val)
		}
	case reflect.Bool:
		if val, err := strconv.ParseBool(envVal); err == nil {
			field.SetBool(val)
		}
	case reflect.Slice:
		if field.Type().Elem().Kind() == reflect.String {
			parts := strings.Split(envVal, ",")
			for i := range parts {
				parts[i] = strings.TrimSpace(parts[i])
			}
			field.Set(reflect.ValueOf(parts))
		}
	}
}

// MustLoadConfig loads config and panics on error
func MustLoadConfig(configDir string, cfg interface{}) {
	if err := LoadConfig(configDir, cfg); err != nil {
		panic(fmt.Sprintf("failed to load config: %v", err))
	}
}

// GetConfigPath returns the config directory path.
// Uses CONFIG_PATH env var or defaults to "./config"
func GetConfigPath() string {
	if path := os.Getenv("CONFIG_PATH"); path != "" {
		return path
	}
	return "./config"
}
