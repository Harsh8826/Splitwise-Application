package main

import (
	"context"
	"expense_management_backend/internal/config"
	"expense_management_backend/internal/database"
	"expense_management_backend/internal/router"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"expense_management_backend/internal/repository"
	"expense_management_backend/internal/services"

	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using default configuration")
	}

	// Load configuration
	cfg := config.Load()

	// Setup logging
	setupLogging(cfg.LogLevel)

	// Initialize database
	if err := database.InitDatabase(); err != nil {
		logrus.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDatabase()

	// Initialize default split types
	splitTypeRepo := repository.NewSplitTypeRepository()
	splitTypeService := services.NewSplitTypeService(splitTypeRepo)
	if err := splitTypeService.InitializeDefaultSplitTypes(); err != nil {
		logrus.Warnf("Failed to initialize default split types: %v", err)
	} else {
		logrus.Info("Default split types initialized successfully")
	}

	// Setup router
	router := router.SetupRouter(cfg)

	// Create HTTP server
	server := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		logrus.Infof("Starting server on port %s", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logrus.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logrus.Info("Shutting down server...")

	// Create a deadline for server shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Attempt graceful shutdown
	if err := server.Shutdown(ctx); err != nil {
		logrus.Errorf("Server forced to shutdown: %v", err)
	}

	logrus.Info("Server exited")
}

// setupLogging configures the logging level
func setupLogging(level string) {
	switch level {
	case "debug":
		logrus.SetLevel(logrus.DebugLevel)
	case "info":
		logrus.SetLevel(logrus.InfoLevel)
	case "warn":
		logrus.SetLevel(logrus.WarnLevel)
	case "error":
		logrus.SetLevel(logrus.ErrorLevel)
	default:
		logrus.SetLevel(logrus.InfoLevel)
	}

	// Set log format
	logrus.SetFormatter(&logrus.TextFormatter{
		FullTimestamp: true,
	})
}
