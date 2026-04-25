package router

import (
	"expense_management_backend/internal/auth"
	"expense_management_backend/internal/config"
	"expense_management_backend/internal/handlers"
	"expense_management_backend/internal/middleware"
	"expense_management_backend/internal/repository"
	"expense_management_backend/internal/services"

	"github.com/gin-gonic/gin"
)

// SetupRouter sets up the Gin router with all routes and middleware
func SetupRouter(cfg *config.Config) *gin.Engine {
	// Set Gin mode
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// Initialize repositories
	userRepo := repository.NewUserRepository()
	groupRepo := repository.NewGroupRepository()
	expenseRepo := repository.NewExpenseRepository()
	settlementRepo := repository.NewSettlementRepository()
	splitTypeRepo := repository.NewSplitTypeRepository()

	// Initialize JWT manager
	jwtManager := auth.NewJWTManager(cfg.JWTSecret, cfg.JWTExpiryHours)

	// Initialize services
	userService := services.NewUserService(userRepo, jwtManager)
	groupService := services.NewGroupService(groupRepo, userRepo)
	expenseService := services.NewExpenseService(expenseRepo, groupRepo, userRepo)
	settlementService := services.NewSettlementService(settlementRepo, expenseRepo, groupRepo, userRepo)
	splitTypeService := services.NewSplitTypeService(splitTypeRepo)

	// Initialize handlers
	userHandler := handlers.NewUserHandler(userService)
	groupHandler := handlers.NewGroupHandler(groupService)
	expenseHandler := handlers.NewExpenseHandler(expenseService)
	settlementHandler := handlers.NewSettlementHandler(settlementService)
	splitTypeHandler := handlers.NewSplitTypeHandler(splitTypeService)

	// API routes
	api := router.Group("/api/v1")
	{
		// Public routes (no authentication required)
		authRoutes := api.Group("/auth")
		{
			authRoutes.POST("/register", userHandler.Register)
			authRoutes.POST("/login", userHandler.Login)
		}

		// Protected routes (authentication required)
		protected := api.Group("/")
		protected.Use(middleware.AuthMiddleware(jwtManager))
		{
			// User routes
			users := protected.Group("/users")
			{
				users.GET("/profile", userHandler.GetProfile)
				users.PUT("/profile", userHandler.UpdateProfile)
				users.DELETE("/profile", userHandler.DeleteProfile)
				users.GET("/groups", userHandler.GetUserGroups)
				users.GET("/expenses", userHandler.GetUserExpenses)
				users.GET("/search", userHandler.SearchUsers)
				users.GET("/:id", userHandler.GetUserByID)
				users.GET("/", userHandler.ListUsers)
			}

			// Group routes
			groups := protected.Group("/groups")
			{
				groups.POST("/", groupHandler.Create)
				groups.GET("/", groupHandler.List)
				groups.GET("/my", groupHandler.GetUserGroups)
				groups.GET("/:id", groupHandler.GetByID)
				groups.PUT("/:id", groupHandler.Update)
				groups.DELETE("/:id", groupHandler.Delete)
				groups.GET("/:id/members", groupHandler.GetGroupMembers)
				groups.POST("/:id/members", groupHandler.AddMember)
				groups.DELETE("/:id/members/:member_id", groupHandler.RemoveMember)
			}

			// Expense routes
			expenses := protected.Group("/expenses")
			{
				expenses.POST("/", expenseHandler.Create)
				expenses.GET("/", expenseHandler.GetUserExpenses)
				expenses.GET("/:id", expenseHandler.GetByID)
				expenses.PUT("/:id", expenseHandler.Update)
				expenses.DELETE("/:id", expenseHandler.Delete)
			}

			// Group expenses
			groups.GET("/:id/expenses", expenseHandler.GetGroupExpenses)

			// Settlement routes
			settlements := protected.Group("/settlements")
			{
				settlements.POST("/", settlementHandler.Create)
				settlements.GET("/", settlementHandler.GetUserSettlements)
				settlements.GET("/:id", settlementHandler.GetByID)
				settlements.PUT("/:id", settlementHandler.Update)
				settlements.DELETE("/:id", settlementHandler.Delete)
			}

			// Group settlements and balance
			groups.GET("/:id/settlements", settlementHandler.GetGroupSettlements)
			groups.GET("/:id/balance", settlementHandler.CalculateGroupBalance)
			groups.GET("/:id/settlements/my", settlementHandler.GetUserSettlementsInGroup)

			// Split Type routes (Admin/Management)
			splitTypes := protected.Group("/split-types")
			{
				splitTypes.POST("/", splitTypeHandler.Create)
				splitTypes.GET("/", splitTypeHandler.List)
				splitTypes.GET("/active", splitTypeHandler.ListActive)
				splitTypes.GET("/:id", splitTypeHandler.GetByID)
				splitTypes.PUT("/:id", splitTypeHandler.Update)
				splitTypes.DELETE("/:id", splitTypeHandler.Delete)
			}
		}
	}

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "Expense Management API is running",
		})
	})

	return router
}
