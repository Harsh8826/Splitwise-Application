package database

import (
	"expense_management_backend/internal/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// InitDatabase initializes the database connection and runs migrations
func InitDatabase() error {
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "./expense_management.db"
	}

	// Configure GORM logger
	gormLogger := logger.Default
	if os.Getenv("ENV") == "development" {
		gormLogger = logger.Default.LogMode(logger.Info)
	}

	// Open database connection
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{
		Logger: gormLogger,
	})
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// Run migrations
	err = runMigrations(db)
	if err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	DB = db
	log.Println("Database initialized successfully")
	return nil
}

// runMigrations runs all database migrations
func runMigrations(db *gorm.DB) error {
	return db.AutoMigrate(
		&models.User{},
		&models.Group{},
		&models.GroupMember{},
		&models.Expense{},
		&models.ExpenseSplit{},
		&models.Settlement{},
		&models.SplitType{},
	)
}

// GetDB returns the database instance
func GetDB() *gorm.DB {
	return DB
}

// CloseDatabase closes the database connection
func CloseDatabase() error {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			return err
		}
		return sqlDB.Close()
	}
	return nil
}
