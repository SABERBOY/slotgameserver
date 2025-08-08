# Copilot Instructions - Saber Game Server Project

## 🎯 Project Overview

This is a high-performance web game server project built with Rust, primarily implementing slot machine game functionality with a microservice architecture design.

# Enterprise Application Development Guidelines

## Programming Language: Rust

## Framework: Actix Web

## Code Style: Enterprise Patterns

**Enterprise Patterns Guidelines:**
- Follow Enterprise Patterns principles and best practices
- Maintain consistency with the chosen architectural style
- Apply patterns and practices appropriate to this approach

## Testing: Rust Testing

**Testing Guidelines:**
- Write comprehensive unit tests for all business logic
- Follow the AAA pattern: Arrange, Act, Assert
- Maintain good test coverage (aim for 80%+ for critical paths)
- Write descriptive test names that explain the expected behavior
- Use test doubles (mocks, stubs, spies) appropriately
- Implement integration tests for API endpoints and user flows
- Keep tests fast, isolated, and deterministic

## AI Code Generation Preferences

When generating code, please:

- Generate complete, working code examples with proper imports
- Include inline comments for complex logic and business rules
- Follow the established patterns and conventions in this project
- Suggest improvements and alternative approaches when relevant
- Consider performance, security, and maintainability
- Include error handling and edge case considerations
- Generate appropriate unit tests when creating new functions
- Follow accessibility best practices for UI components
- Use semantic HTML and proper ARIA attributes when applicable

## 📁 Project Structure

```text
slotgameserver/
├── src/                          # Main server - Slot machine config API and universal functions
│   ├── main.rs                   # Main server entry point, includes Todo API and slot machine game
│   ├── slot_config_api.rs        # Slot machine configuration management API
│   ├── slots.rs                  # Slot machine game core logic
│   └── universal_slots.rs        # Universal slot machine functions
├── game_server/                  # Independent game server
│   ├── src/
│   │   ├── main.rs              # Game server entry point
│   │   ├── handlers/            # API handlers
│   │   ├── middleware/          # Middleware (authentication, etc.)
│   │   ├── models/              # Data models
│   │   └── utils/               # Utility functions (JWT, password encryption, etc.)
│   └── migrations/              # SQLite database migrations
├── admin/                        # Admin panel frontend
├── Dockerfile                    # Docker container configuration
├── docker-compose.yml            # Production environment orchestration
├── docker-compose.dev.yml        # Development environment orchestration
├── nginx.conf                    # Nginx reverse proxy configuration
└── schema.sql                    # PostgreSQL database schema
```

## 🛠️ Tech Stack

### Main Frameworks and Libraries
- **Web Framework**: Actix-web 4.11.0
- **Async Runtime**: Tokio 1.47.1 (full features)
- **Database**:
  - Main server: PostgreSQL + SQLx 0.8.6
  - Game server: SQLite + SQLx
- **Serialization**: Serde 1.0.219
- **Authentication**: JWT (actix-web-httpauth)
- **Logging**: env_logger 0.11.8
- **Random Numbers**: rand 0.9.2
- **Time Handling**: chrono 0.4.41

### Containerization
- **Docker**: Multi-stage build optimization
- **Docker Compose**: Service orchestration
- **Nginx**: Reverse proxy and load balancing

## 🎮 Core Functional Modules

### 1. Slot Machine Game System
- **Location**: `src/slots.rs`, `src/universal_slots.rs`
- **Features**: 
  - Slot machine game logic
  - Progressive jackpot system (ProgressiveJackpot)
  - Random number generation and reward calculation

### 2. Game Server API
- **Location**: `game_server/src/handlers/`
- **Features**:
  - User authentication and authorization
  - Game session management
  - JWT Token handling

### 3. Configuration Management System
- **Location**: `src/slot_config_api.rs`
- **Features**: CRUD operations for slot machine game configurations

## 💾 Database Design

### PostgreSQL (Main Server)
- `todos` table: Sample todo items
- `slot_configs` table: Slot machine configurations
- Supports BigDecimal for precise currency calculations

### SQLite (Game Server)
- `users` table: User information
- Lightweight, suitable for game session data

## 🔧 Development Guide

### Code Style
1. **Asynchronous Programming**: Use `async/await` and Tokio
2. **Error Handling**: Use `Result<T, E>` and `map_err()` for conversions
3. **Serialization**: Add `#[derive(Serialize, Deserialize)]` to API models
4. **Logging**: Use `log::info!`, `log::error!` and other macros

### API Design Patterns
```rust
#[post("/endpoint")]
async fn handler(
    data: web::Json<RequestModel>,
    state: web::Data<AppState>
) -> Result<Json<ResponseModel>> {
    // Database operations
    let result = sqlx::query_as("SQL")
        .bind(&data.field)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| error::ErrorBadRequest(e.to_string()))?;
    
    Ok(Json(result))
}
```

### Database Operation Patterns
```rust
// Query single record
let record = sqlx::query_as::<_, ModelStruct>("SELECT * FROM table WHERE id = $1")
    .bind(id)
    .fetch_one(&pool)
    .await?;

// Query multiple records  
let records = sqlx::query_as::<_, ModelStruct>("SELECT * FROM table")
    .fetch_all(&pool)
    .await?;
```

## 🚀 Deployment and Execution

### Development Environment
```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Or run directly
cargo run                    # Main server
cd game_server && cargo run # Game server
```

### Production Environment
```bash
# Build and run
docker-compose up -d

# Using Makefile
make build
make run
```

## 🧪 Testing

### High Concurrency Testing
The project supports high concurrency testing using Tokio:
```rust
#[tokio::main]
async fn main() {
    let handles: Vec<_> = (0..1000).map(|i| {
        tokio::spawn(async move {
            // Concurrent task logic
        })
    }).collect();
    
    futures::future::join_all(handles).await;
}
```

### API Testing
Use `game_server/test_api.sh` for API functionality testing.

## 🔐 Security Considerations

1. **JWT Authentication**: Game server uses JWT for user authentication
2. **Password Encryption**: Uses secure hashing algorithms
3. **CORS Configuration**: Properly configured Cross-Origin Resource Sharing
4. **Environment Variables**: Sensitive information managed through environment variables

## 📝 Code Completion Suggestions

### Common Patterns
1. **New API Endpoints**: Create new handler functions in `handlers/` directory
2. **Database Models**: Define in `models/` directory, implement `FromRow` trait
3. **Middleware**: Implement authentication, logging, etc. in `middleware/` directory
4. **Utility Functions**: Add common utilities in `utils/` directory

### Dependency Management
- Consider version compatibility when adding new dependencies
- Use `features` to load functionality as needed
- Ensure async runtime consistency (tokio vs async-std)

### File Organization Guidelines
- **Markdown Files**: All `.md` files should be placed in the `README/` directory to maintain documentation organization
- **SQL Files**: All `.sql` files should be placed in the `SQL/` directory for database-related scripts and schemas
- **Exception**: Core documentation files like `README.md` can remain in the project root

## 🔍 Debugging and Monitoring

### Log Configuration
```rust
env_logger::init();
log::info!("Server startup information");
log::error!("Error information: {}", error);
```

### Performance Monitoring
- Use Actix-web's Logger middleware
- Database connection pool monitoring
- Memory and CPU usage tracking

## 📚 Related Documentation

- `README.md`: Project introduction and quick start
- `PROJECT_SUMMARY.md`: Project functionality summary
- `DOCKER_DEPLOYMENT.md`: Detailed Docker deployment guide
- `DEPLOYMENT_QUICKSTART.md`: Quick deployment guide

---

**Note**: During development, please maintain code consistency and maintainability, following Rust best practices and this project's coding standards.
