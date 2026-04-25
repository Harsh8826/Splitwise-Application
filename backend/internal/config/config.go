package config

import (
	"os"
	"strconv"
)

// Config holds all configuration for our application
type Config struct {
	DBPath         string
	JWTSecret      string
	JWTExpiryHours int
	Port           string
	Environment    string
	LogLevel       string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		DBPath:         getEnv("DB_PATH", "./expense_management.db"),
		JWTSecret:      getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-this-in-production"),
		JWTExpiryHours: getEnvAsInt("JWT_EXPIRY_HOURS", 24),
		Port:           getEnv("PORT", "8080"),
		Environment:    getEnv("ENV", "development"),
		LogLevel:       getEnv("LOG_LEVEL", "info"),
	}
}

// getEnv gets an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvAsInt gets an environment variable as integer or returns a default value
func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}
