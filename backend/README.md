# Expense Management Backend

A scalable expense management backend built in Go (Golang) similar to Splitwise, using SQLite as the database. This application allows users to create groups, add expenses, split expenses among group members, and settle balances.

## Features

- **User Management**: Register, login, and authenticate users using JWT
- **Group Management**: Create, update, delete, and list groups. Users can join or leave groups
- **Enhanced Member Management**:
  - List all authenticated users for group member selection
  - Search users by email address for easy member discovery
  - Add members to groups using email addresses (no need for UUIDs)
  - Real-time user search with pagination support
- **Expense Management**: Add, update, delete, and list expenses within a group. Support equal and unequal splits (percentage or exact amounts)
- **Settlement**: Calculate balances for each user in a group and allow users to settle debts (record payments)
- **Balance Tracking**: Display simplified balances for users in a group (who owes whom and how much)
- **Split Types Management**: Master table for expense split types with full CRUD operations
  - Create, read, update, and delete split types
  - List all split types with pagination
  - List only active split types
  - Default split types (equal, percentage, custom) auto-initialized
  - Customizable split types for future expansion

## Recent Updates

### Split Types Master Table (Latest)

**New Features Added:**

- **Split Types Management**: Complete CRUD operations for expense split types
- **Master Table System**: Centralized management of all split types
- **Default Split Types**: Auto-initialization of standard split types (equal, percentage, custom)
- **Active/Inactive Status**: Ability to enable/disable split types without deletion
- **Customizable Split Types**: Add new split types as needed for future requirements

**API Endpoints Added:**

- `POST /api/v1/split-types/` - Create new split type
- `GET /api/v1/split-types/` - List all split types with pagination
- `GET /api/v1/split-types/active` - List only active split types
- `GET /api/v1/split-types/{id}` - Get specific split type by ID
- `PUT /api/v1/split-types/{id}` - Update split type
- `DELETE /api/v1/split-types/{id}` - Delete split type

**Technical Implementation:**

- New `SplitType` model with UUID primary key and soft delete support
- Complete repository layer with database operations
- Service layer with business logic and validation
- HTTP handlers with authentication and request validation
- Automatic initialization of default split types on server startup

### Enhanced Group Member Management

**New Features Added:**

- **Email-based Member Addition**: Users can now be added to groups using their email addresses instead of UUIDs
- **User Search Functionality**: Real-time search for users by email with partial matching
- **User Listing**: Complete list of all authenticated users for easy member selection
- **Improved UX**: No need to know or store user UUIDs in the frontend

**API Changes:**

- Updated `POST /api/v1/groups/{group_id}/members` to accept email instead of user_id
- Added `GET /api/v1/users/` endpoint for listing all users
- Added `GET /api/v1/users/search?email=query` endpoint for user search
- Enhanced error handling for invalid email addresses and duplicate members

**Technical Improvements:**

- Added `SearchByEmail` method to user repository and service
- Updated group service with `AddMemberByEmail` method
- Enhanced validation and error messages
- Improved database queries with proper indexing
- **Database Fixes**: Resolved SQLite UUID generation issues by removing `gen_random_uuid()` defaults and using GORM hooks instead

## Technical Stack

- **Language**: Go 1.21+
- **Framework**: Gin (HTTP web framework)
- **Database**: SQLite with GORM ORM
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **Logging**: Logrus
- **Configuration**: Environment variables with godotenv

## Project Structure

```
expense_management_backend/
├── cmd/
│   └── main.go                 # Application entry point
├── internal/
│   ├── auth/
│   │   ├── jwt.go             # JWT authentication utilities
│   │   └── password.go        # Password hashing utilities
│   ├── config/
│   │   └── config.go          # Configuration management
│   ├── database/
│   │   └── database.go        # Database connection and migrations
│   ├── handlers/
│   │   ├── user_handler.go    # User HTTP handlers
│   │   ├── group_handler.go   # Group HTTP handlers
│   │   ├── expense_handler.go # Expense HTTP handlers
│   │   ├── settlement_handler.go # Settlement HTTP handlers
│   │   └── split_type_handler.go # Split Type HTTP handlers
│   ├── middleware/
│   │   └── auth.go           # JWT authentication middleware
│   ├── models/
│   │   ├── user.go           # User model and DTOs
│   │   ├── group.go          # Group model and DTOs
│   │   ├── expense.go        # Expense model and DTOs
│   │   ├── settlement.go     # Settlement model and DTOs
│   │   └── split_type.go     # Split Type model and DTOs
│   ├── repository/
│   │   ├── user_repository.go    # User data access layer
│   │   ├── group_repository.go   # Group data access layer
│   │   ├── expense_repository.go # Expense data access layer
│   │   ├── settlement_repository.go # Settlement data access layer
│   │   └── split_type_repository.go # Split Type data access layer
│   ├── router/
│   │   └── router.go         # HTTP router setup
│   └── services/
│       ├── user_service.go       # User business logic
│       ├── group_service.go      # Group business logic
│       ├── expense_service.go    # Expense business logic
│       ├── settlement_service.go # Settlement business logic
│       └── split_type_service.go # Split Type business logic
├── go.mod                     # Go module file
├── go.sum                     # Go module checksums
├── env.example               # Environment variables example
└── README.md                 # This file
```

## Prerequisites

- Go 1.21 or later
- SQLite (included with Go)

## Installation and Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd expense_management_backend
   ```

2. **Install dependencies**

   ```bash
   go mod tidy
   ```

3. **Set up environment variables**

   ```bash
   cp env.example .env
   ```

   Edit the `.env` file with your configuration:

   ```env
   # Database Configuration
   DB_PATH=./expense_management.db

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_EXPIRY_HOURS=24

   # Server Configuration
   PORT=8080
   ENV=development

   # Logging
   LOG_LEVEL=info
   ```

4. **Run the application**

   ```bash
   go run cmd/main.go
   ```

   The server will start on `http://localhost:8080`

## API Documentation

### Authentication Endpoints

#### Register User

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

#### Login

```http
POST /api/v1/auth/login
Content-Type: application/json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### User Endpoints (Protected)

#### Get Profile

```http
GET /api/v1/users/profile
Authorization: Bearer <jwt_token>
```

#### Update Profile

```http
PUT /api/v1/users/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "John Smith"
}
```

#### Get User Groups

```http
GET /api/v1/users/groups
Authorization: Bearer <jwt_token>
```

#### Get User Expenses

```http
GET /api/v1/users/expenses
Authorization: Bearer <jwt_token>
```

### Group Endpoints (Protected)

#### Create Group

```http
POST /api/v1/groups/
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "Trip to Paris",
  "description": "Vacation expenses"
}
```

#### Get Group Details

```http
GET /api/v1/groups/{group_id}
Authorization: Bearer <jwt_token>
```

#### Update Group

```http
PUT /api/v1/groups/{group_id}
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "Updated Group Name",
  "description": "Updated description"
}
```

#### Add Member to Group

```http
POST /api/v1/groups/{group_id}/members
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Note:** Members are now added using email addresses instead of UUIDs for better user experience.

#### Get Group Members

```http
GET /api/v1/groups/{group_id}/members
Authorization: Bearer <jwt_token>
```

### User Management Endpoints (Protected)

#### List All Users

```http
GET /api/v1/users/
Authorization: Bearer <jwt_token>
```

**Query Parameters:**

- `offset` (optional): Number of users to skip (default: 0)
- `limit` (optional): Number of users to return (default: 10)

**Response:**

```json
{
  "users": [
    {
      "id": "user-uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    }
  ]
}
```

#### Search Users by Email

```http
GET /api/v1/users/search?email=john
Authorization: Bearer <jwt_token>
```

**Query Parameters:**

- `email` (required): Email query for partial matching
- `offset` (optional): Number of users to skip (default: 0)
- `limit` (optional): Number of users to return (default: 10)

**Response:**

```json
{
  "users": [
    {
      "id": "user-uuid",
      "email": "john@example.com",
      "name": "John Doe",
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    }
  ]
}
```

**Features:**

- Partial email matching (e.g., "john" will find "john@example.com", "johnny@test.com")
- Pagination support for large user lists
- Real-time search for group member selection

### Expense Endpoints (Protected)

#### Create Expense

```http
POST /api/v1/expenses/
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "group_id": "group-uuid",
  "title": "Dinner",
  "description": "Restaurant dinner",
  "amount": 100.0,
  "split_type": "equal"
}
```

**Split Types:**

- `equal`: Split equally among all group members
- `percentage`: Split based on percentages
- `custom`: Split based on custom amounts

**For percentage split:**

```json
{
  "group_id": "group-uuid",
  "title": "Dinner",
  "description": "Restaurant dinner",
  "amount": 100.0,
  "split_type": "percentage",
  "splits": [
    { "user_id": "user1-uuid", "percentage": 50.0 },
    { "user_id": "user2-uuid", "percentage": 30.0 },
    { "user_id": "user3-uuid", "percentage": 20.0 }
  ]
}
```

**For custom split:**

```json
{
  "group_id": "group-uuid",
  "title": "Dinner",
  "description": "Restaurant dinner",
  "amount": 100.0,
  "split_type": "custom",
  "splits": [
    { "user_id": "user1-uuid", "amount": 50.0 },
    { "user_id": "user2-uuid", "amount": 30.0 },
    { "user_id": "user3-uuid", "amount": 20.0 }
  ]
}
```

#### Get Group Expenses

```http
GET /api/v1/groups/{group_id}/expenses
Authorization: Bearer <jwt_token>
```

#### Update Expense

```http
PUT /api/v1/expenses/{expense_id}
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "title": "Updated Dinner",
  "description": "Updated description",
  "amount": 120.0,
  "split_type": "equal"
}
```

### Settlement Endpoints (Protected)

#### Create Settlement

```http
POST /api/v1/settlements/
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "to_user_id": "user-uuid",
  "group_id": "group-uuid",
  "amount": 25.0,
  "description": "Payment for dinner"
}
```

#### Get Group Balance

```http
GET /api/v1/groups/{group_id}/balance
Authorization: Bearer <jwt_token>
```

#### Get Group Settlements

```http
GET /api/v1/groups/{group_id}/settlements
Authorization: Bearer <jwt_token>
```

### Split Types Endpoints (Protected)

#### List All Split Types

```http
GET /api/v1/split-types/
Authorization: Bearer <jwt_token>
```

**Query Parameters:**

- `offset` (optional): Number of split types to skip (default: 0)
- `limit` (optional): Number of split types to return (default: 10)

**Response:**

```json
{
  "split_types": [
    {
      "id": "split-type-uuid",
      "name": "equal",
      "description": "Split equally among all group members",
      "is_active": true,
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    }
  ]
}
```

#### List Active Split Types

```http
GET /api/v1/split-types/active
Authorization: Bearer <jwt_token>
```

**Response:**

```json
{
  "split_types": [
    {
      "id": "split-type-uuid",
      "name": "equal",
      "description": "Split equally among all group members",
      "is_active": true,
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    },
    {
      "id": "split-type-uuid-2",
      "name": "percentage",
      "description": "Split based on percentages",
      "is_active": true,
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    },
    {
      "id": "split-type-uuid-3",
      "name": "custom",
      "description": "Split based on custom amounts",
      "is_active": true,
      "created_at": "2025-07-28T10:55:04.958902817+05:30",
      "updated_at": "2025-07-28T10:55:04.958902817+05:30"
    }
  ]
}
```

#### Get Split Type by ID

```http
GET /api/v1/split-types/{split_type_id}
Authorization: Bearer <jwt_token>
```

**Response:**

```json
{
  "split_type": {
    "id": "split-type-uuid",
    "name": "equal",
    "description": "Split equally among all group members",
    "is_active": true,
    "created_at": "2025-07-28T10:55:04.958902817+05:30",
    "updated_at": "2025-07-28T10:55:04.958902817+05:30"
  }
}
```

#### Create New Split Type

```http
POST /api/v1/split-types/
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "proportional",
  "description": "Split based on proportional shares"
}
```

**Response:**

```json
{
  "message": "Split type created successfully",
  "split_type": {
    "id": "new-split-type-uuid",
    "name": "proportional",
    "description": "Split based on proportional shares",
    "is_active": true,
    "created_at": "2025-07-28T10:55:04.958902817+05:30",
    "updated_at": "2025-07-28T10:55:04.958902817+05:30"
  }
}
```

#### Update Split Type

```http
PUT /api/v1/split-types/{split_type_id}
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "updated-proportional",
  "description": "Updated description for proportional split",
  "is_active": true
}
```

**Response:**

```json
{
  "message": "Split type updated successfully",
  "split_type": {
    "id": "split-type-uuid",
    "name": "updated-proportional",
    "description": "Updated description for proportional split",
    "is_active": true,
    "created_at": "2025-07-28T10:55:04.958902817+05:30",
    "updated_at": "2025-07-28T10:55:04.958902817+05:30"
  }
}
```

#### Delete Split Type

```http
DELETE /api/v1/split-types/{split_type_id}
Authorization: Bearer <jwt_token>
```

**Response:**

```json
{
  "message": "Split type deleted successfully"
}
```

**Note:** Split types are soft-deleted, meaning they are marked as deleted but not physically removed from the database.

### Default Split Types

The system automatically initializes the following default split types:

1. **equal** - Split equally among all group members
2. **percentage** - Split based on percentages
3. **custom** - Split based on custom amounts

These split types are created when the server starts for the first time and can be customized or extended as needed.

## Complete Group Member Management Workflow

### Step-by-Step Process

1. **Create a Group**

   - User creates a group and automatically becomes a member

2. **Find Users to Add**

   - Use `/api/v1/users/` to list all available users
   - Use `/api/v1/users/search?email=query` to search for specific users

3. **Add Members to Group**
   - Use `/api/v1/groups/{group_id}/members` with email address
   - System validates user exists and adds them to the group

### Frontend Integration Example

```javascript
// 1. List all users for dropdown
const response = await fetch("/api/v1/users/", {
  headers: { Authorization: `Bearer ${token}` },
});
const { users } = await response.json();

// 2. Search users by email
const searchResponse = await fetch("/api/v1/users/search?email=john", {
  headers: { Authorization: `Bearer ${token}` },
});
const { users: searchResults } = await searchResponse.json();

// 3. Add member to group
const addMemberResponse = await fetch(`/api/v1/groups/${groupId}/members`, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ email: "user@example.com" }),
});
```

### Key Benefits

- **User-Friendly**: No need to know UUIDs, just use email addresses
- **Real-Time Search**: Instant user discovery with partial email matching
- **Secure**: Only authenticated users can be added to groups
- **Scalable**: Pagination support for large user lists
- **Error Handling**: Clear error messages for invalid emails or duplicate members

## Example Usage with curl

### 1. Register a user

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123",
    "name": "John Doe"
  }'
```

### 2. Login and get token

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 3. Create a group

```bash
curl -X POST http://localhost:8080/api/v1/groups/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Trip to Paris",
    "description": "Vacation expenses"
  }'
```

### 4. List all users (for member selection)

```bash
curl -X GET http://localhost:8080/api/v1/users/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 5. Search users by email

```bash
curl -X GET "http://localhost:8080/api/v1/users/search?email=john" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 6. Add member to group

```bash
curl -X POST http://localhost:8080/api/v1/groups/GROUP_UUID/members \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

### 7. Get group members

```bash
curl -X GET http://localhost:8080/api/v1/groups/GROUP_UUID/members \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 8. Add an expense

```bash
curl -X POST http://localhost:8080/api/v1/expenses/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "GROUP_UUID",
    "title": "Dinner",
    "description": "Restaurant dinner",
    "amount": 100.0,
    "split_type": "equal"
  }'
```

### 9. Check group balance

```bash
curl -X GET http://localhost:8080/api/v1/groups/GROUP_UUID/balance \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 10. List all split types

```bash
curl -X GET http://localhost:8080/api/v1/split-types/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 11. List active split types

```bash
curl -X GET http://localhost:8080/api/v1/split-types/active \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 12. Create a new split type

```bash
curl -X POST http://localhost:8080/api/v1/split-types/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "proportional",
    "description": "Split based on proportional shares"
  }'
```

### 13. Update a split type

```bash
curl -X PUT http://localhost:8080/api/v1/split-types/SPLIT_TYPE_UUID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "updated-proportional",
    "description": "Updated description for proportional split",
    "is_active": true
  }'
```

### 14. Delete a split type

```bash
curl -X DELETE http://localhost:8080/api/v1/split-types/SPLIT_TYPE_UUID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Running Tests

```bash
go test ./...
```

To run tests with coverage:

```bash
go test -cover ./...
```

## Database Schema

The application uses the following main tables:

- **users**: User information
- **groups**: Group information
- **group_members**: Many-to-many relationship between users and groups
- **expenses**: Expense records
- **expense_splits**: How expenses are split among users
- **settlements**: Debt settlements between users
- **split_types**: Master table for expense split types (equal, percentage, custom, etc.)

## Scalability Considerations

- **Database Indexes**: Proper indexes on frequently queried fields
- **Connection Pooling**: GORM handles database connection pooling
- **Caching Ready**: Architecture supports easy integration with Redis for caching
- **Horizontal Scaling**: Can be easily containerized and scaled horizontally
- **Database Migration**: Automatic schema migration with GORM

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for secure password storage
- **Input Validation**: Comprehensive request validation
- **Authorization**: Role-based access control for group operations
- **SQL Injection Protection**: GORM provides protection against SQL injection

## Error Handling

The application provides comprehensive error handling with:

- HTTP status codes
- Descriptive error messages
- Structured error responses
- Logging for debugging

## Logging

The application uses structured logging with Logrus:

- Configurable log levels
- Timestamp and context information
- JSON formatting for production

## Environment Variables

| Variable           | Description                          | Default                                               |
| ------------------ | ------------------------------------ | ----------------------------------------------------- |
| `DB_PATH`          | SQLite database file path            | `./expense_management.db`                             |
| `JWT_SECRET`       | JWT signing secret                   | `your-super-secret-jwt-key-change-this-in-production` |
| `JWT_EXPIRY_HOURS` | JWT token expiry in hours            | `24`                                                  |
| `PORT`             | Server port                          | `8080`                                                |
| `ENV`              | Environment (development/production) | `development`                                         |
| `LOG_LEVEL`        | Logging level                        | `info`                                                |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository.
