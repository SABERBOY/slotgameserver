-- Drop existing tables if they exist
DROP TABLE IF EXISTS slot_spin_history;
DROP TABLE IF EXISTS jackpot_wins;
DROP TABLE IF EXISTS game_sessions;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS todos;
DROP TABLE IF EXISTS slot_reel_symbols;
DROP TABLE IF EXISTS slot_symbols;
DROP TABLE IF EXISTS slot_paylines;
DROP TABLE IF EXISTS slot_configurations;

-- Basic todos table (keeping for compatibility)
CREATE TABLE IF NOT EXISTS todos (
  id serial PRIMARY KEY,
  note TEXT NOT NULL
);

-- Players table
CREATE TABLE IF NOT EXISTS players (
  id serial PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  balance BIGINT DEFAULT 1000,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP WITH TIME ZONE
);

-- Game sessions table
CREATE TABLE IF NOT EXISTS game_sessions (
  id serial PRIMARY KEY,
  player_id INTEGER REFERENCES players(id),
  session_start TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  session_end TIMESTAMP WITH TIME ZONE,
  total_spins INTEGER DEFAULT 0,
  total_bet BIGINT DEFAULT 0,
  total_won BIGINT DEFAULT 0
);

-- Slot configurations table (通用slot配置)
CREATE TABLE IF NOT EXISTS slot_configurations (
  id serial PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  rows INTEGER NOT NULL DEFAULT 3,
  reels INTEGER NOT NULL DEFAULT 5,
  is_megaway BOOLEAN DEFAULT FALSE,
  min_megaway_rows INTEGER DEFAULT 2,
  max_megaway_rows INTEGER DEFAULT 7,
  default_bet INTEGER DEFAULT 1,
  min_bet INTEGER DEFAULT 1,
  max_bet INTEGER DEFAULT 1000,
  wild_enabled BOOLEAN DEFAULT TRUE,
  free_spins_enabled BOOLEAN DEFAULT TRUE,
  rtp_percentage DECIMAL(5,2) DEFAULT 96.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

-- Slot symbols table (存储所有可用的符号)
CREATE TABLE IF NOT EXISTS slot_symbols (
  id serial PRIMARY KEY,
  slot_config_id INTEGER REFERENCES slot_configurations(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  symbol_type VARCHAR(20) NOT NULL CHECK (symbol_type IN ('normal', 'wild', 'scatter', 'bonus')),
  value INTEGER NOT NULL,
  image_url VARCHAR(255),
  payout_2x INTEGER DEFAULT 0,
  payout_3x INTEGER DEFAULT 0,
  payout_4x INTEGER DEFAULT 0,
  payout_5x INTEGER DEFAULT 0,
  payout_6x INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Slot reel symbols table (定义每个卷轴上的符号顺序)
CREATE TABLE IF NOT EXISTS slot_reel_symbols (
  id serial PRIMARY KEY,
  slot_config_id INTEGER REFERENCES slot_configurations(id) ON DELETE CASCADE,
  reel_number INTEGER NOT NULL,
  position INTEGER NOT NULL,
  symbol_id INTEGER REFERENCES slot_symbols(id) ON DELETE CASCADE,
  weight INTEGER DEFAULT 1,
  UNIQUE(slot_config_id, reel_number, position)
);

-- Slot paylines table (定义支付线)
CREATE TABLE IF NOT EXISTS slot_paylines (
  id serial PRIMARY KEY,
  slot_config_id INTEGER REFERENCES slot_configurations(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  pattern JSONB NOT NULL, -- 存储支付线模式，如 [[0,0],[1,0],[2,0],[3,0],[4,0]] 表示第一行
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(slot_config_id, line_number)
);

-- Slot spin history (更新以支持通用配置)
CREATE TABLE IF NOT EXISTS slot_spin_history (
  id serial PRIMARY KEY,
  player_id INTEGER REFERENCES players(id),
  session_id INTEGER REFERENCES game_sessions(id),
  slot_config_id INTEGER REFERENCES slot_configurations(id),
  bet_amount BIGINT NOT NULL,
  win_amount BIGINT NOT NULL,
  symbols JSONB NOT NULL,
  winning_lines JSONB,
  is_megaway_spin BOOLEAN DEFAULT FALSE,
  megaway_rows JSONB, -- 存储每个卷轴的行数（megaway模式）
  spin_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Jackpot wins history
CREATE TABLE IF NOT EXISTS jackpot_wins (
  id serial PRIMARY KEY,
  player_id INTEGER REFERENCES players(id),
  win_amount BIGINT NOT NULL,
  win_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_players_username ON players(username);
CREATE INDEX idx_sessions_player_id ON game_sessions(player_id);
CREATE INDEX idx_spins_player_id ON slot_spin_history(player_id);
CREATE INDEX idx_spins_session_id ON slot_spin_history(session_id);
CREATE INDEX idx_slot_configs_active ON slot_configurations(is_active);
CREATE INDEX idx_slot_symbols_config ON slot_symbols(slot_config_id);
CREATE INDEX idx_slot_reels_config ON slot_reel_symbols(slot_config_id);
CREATE INDEX idx_slot_paylines_config ON slot_paylines(slot_config_id);
