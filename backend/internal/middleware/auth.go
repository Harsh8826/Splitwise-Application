package middleware

import (
	"expense_management_backend/internal/auth"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// AuthMiddleware creates middleware for JWT authentication
func AuthMiddleware(jwtManager *auth.JWTManager) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// Check if the header starts with "Bearer "
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header format"})
			c.Abort()
			return
		}

		// Extract the token
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")

		// Validate the token
		claims, err := jwtManager.ValidateToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		// Set user information in context
		c.Set("user_id", claims.UserID)
		c.Set("user_email", claims.Email)

		c.Next()
	}
}

// GetUserIDFromContext extracts user ID from gin context
func GetUserIDFromContext(c *gin.Context) (uuid.UUID, bool) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		return uuid.Nil, false
	}

	userID, ok := userIDInterface.(uuid.UUID)
	return userID, ok
}

// GetUserEmailFromContext extracts user email from gin context
func GetUserEmailFromContext(c *gin.Context) (string, bool) {
	userEmailInterface, exists := c.Get("user_email")
	if !exists {
		return "", false
	}

	userEmail, ok := userEmailInterface.(string)
	return userEmail, ok
}
