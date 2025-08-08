# Saber - Web Game Server

A high-performance web game server built with Rust, featuring slot machine games and extensible architecture for multiple game types.

## Features

- **RESTful API** with Actix-web framework
- **PostgreSQL** database for data persistence
- **Slot Machine Game** with progressive jackpot
- **Environment-based configuration**
- **Comprehensive error handling**
- **Extensible architecture** for adding more games

## Tech Stack

- **Language**: Rust
- **Web Framework**: Actix-web 4.3.1
- **Database**: PostgreSQL with SQLx
- **Serialization**: Serde
- **Logging**: env_logger

## Quick Start

### Prerequisites

- Rust 1.70+
- PostgreSQL 12+
- Git

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/saber.git
cd saber
```

2. Set up environment variables:

```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. Set up the database:

```bash
createdb saber
psql saber < schema.sql
```

4. Run the server:

```bash
cargo run
```

The server will start at `http://127.0.0.1:8080`

## API Documentation

### General Endpoints

- `GET /` - Welcome message
- `GET /{name}` - Personalized greeting

### Todo Endpoints

- `GET /todos/{id}` - Get todo by ID
- `GET /todos/list` - List all todos
- `POST /todos/add` - Create new todo
- `PUT /todos/update/{id}` - Update todo
- `DELETE /todos/delete/{id}` - Delete todo

### Slot Machine Endpoints

#### Spin the Slots

```http
POST /slots/spin
Content-Type: application/json

{
  "amount": 100
}
```

Response:

```json
{
  "grid": [
    ["Cherry", "Lemon", "Orange"],
    ["Bell", "Cherry", "Plum"],
    ["Seven", "Bar", "Cherry"]
  ],
  "winning_lines": [{
    "line_type": {"Horizontal": 0},
    "symbols": ["Cherry", "Cherry", "Cherry"],
    "win_type": {"ThreeOfKind": "Cherry"}
  }],
  "total_win": 20
}
```

#### Get Jackpot Info

```http
GET /slots/jackpot
```

Response:

```json
{
  "current_amount": 15000,
  "last_won": "2024-12-27T10:30:00Z"
}
```

#### Calculate RTP

```http
GET /slots/rtp
```

Response:

```json
{
  "rtp_percentage": 96.5,
  "sample_size": 10000
}
```

## Slot Machine Algorithm

### Symbols and Values

- 🍒 Cherry: 2 credits
- 🍋 Lemon: 3 credits
- 🍊 Orange: 5 credits
- 🟣 Plum: 8 credits
- 🔔 Bell: 10 credits
- 📊 Bar: 15 credits
- 7️⃣ Seven: 25 credits
- 💎 Diamond: 50 credits

### Winning Combinations

- **Three of a Kind**: Base multiplier × symbol value
- **Two of a Kind**: Smaller multiplier × symbol value
- **Three Sevens**: 100× bet
- **Three Diamonds**: 200× bet + Progressive Jackpot
- **Mixed Bars**: 5× bet

### Progressive Jackpot

- 2% of each bet contributes to the jackpot
- Minimum jackpot: 10,000 credits
- Won by hitting three diamonds on any line

## Database Schema

The project includes tables for:

- **players**: User accounts and balances
- **game_sessions**: Track player sessions
- **slot_spin_history**: Record all spins
- **jackpot_wins**: Track jackpot winners
- **todos**: Simple todo items (for testing)

## Development

### Running Tests

```bash
cargo test
```

### Building for Production

```bash
cargo build --release
```

### Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `RUST_LOG`: Logging level (debug, info, warn, error)

## Project Status

Current version: **0.2.0**

### Completed Features ✅

- Basic CRUD operations
- Slot machine game implementation
- Progressive jackpot system
- Environment configuration
- Database schema design

### Upcoming Features 🚀

- User authentication system
- WebSocket support for real-time gaming
- Additional game types (Poker, Blackjack)
- Leaderboard system
- API documentation (OpenAPI/Swagger)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
