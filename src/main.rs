use actix_files as fs;
use actix_web::middleware::Logger;
use actix_web::{
    delete, error, get, post, put,
    web::{self, Json},
    App, HttpServer, Responder, Result,
};
use dotenv::dotenv;
use serde::{Deserialize, Serialize};
use sqlx::postgres::PgPoolOptions;
use sqlx::{Executor, FromRow, PgPool, Pool, Postgres};
use std::env;
use std::sync::Mutex;

mod slot_config_api;
mod slots;
mod universal_slots;
use slots::{ProgressiveJackpot, SlotMachine};

#[get("/{id}")]
async fn retrieve(path: web::Path<i32>, state: web::Data<AppState>) -> Result<Json<Todo>> {
    let todo = sqlx::query_as("SELECT * FROM todos WHERE id = $1")
        .bind(*path)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| error::ErrorBadRequest(e.to_string()))?;

    Ok(Json(todo))
}

#[post("/add")]
async fn add(todo: web::Json<TodoNew>, state: web::Data<AppState>) -> Result<Json<Todo>> {
    let todo = sqlx::query_as("INSERT INTO todos(note) VALUES ($1) RETURNING id, note")
        .bind(&todo.note)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| error::ErrorBadRequest(e.to_string()))?;

    Ok(Json(todo))
}

#[get("/list")]
async fn list_todos(state: web::Data<AppState>) -> Result<Json<Vec<Todo>>> {
    let todos = sqlx::query_as("SELECT * FROM todos ORDER BY id")
        .fetch_all(&state.pool)
        .await
        .map_err(|e| error::ErrorBadRequest(e.to_string()))?;

    Ok(Json(todos))
}

#[put("/update/{id}")]
async fn update_todo(
    path: web::Path<i32>,
    todo: web::Json<TodoNew>,
    state: web::Data<AppState>,
) -> Result<Json<Todo>> {
    let updated_todo =
        sqlx::query_as("UPDATE todos SET note = $1 WHERE id = $2 RETURNING id, note")
            .bind(&todo.note)
            .bind(*path)
            .fetch_one(&state.pool)
            .await
            .map_err(|e| error::ErrorBadRequest(e.to_string()))?;

    Ok(Json(updated_todo))
}

#[delete("/delete/{id}")]
async fn delete_todo(
    path: web::Path<i32>,
    state: web::Data<AppState>,
) -> Result<Json<serde_json::Value>> {
    let result = sqlx::query("DELETE FROM todos WHERE id = $1")
        .bind(*path)
        .execute(&state.pool)
        .await
        .map_err(|e| error::ErrorBadRequest(e.to_string()))?;

    if result.rows_affected() == 0 {
        return Err(error::ErrorNotFound("Todo not found"));
    }

    Ok(Json(
        serde_json::json!({"message": "Todo deleted successfully"}),
    ))
}

// custom error
#[derive(Debug)]
enum MyError {
    SqlxError(sqlx::Error),
    IoError(std::io::Error),
}

impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            MyError::SqlxError(e) => write!(f, "sqlx error: {e}"),
            MyError::IoError(e) => write!(f, "io error: {e}"),
        }
    }
}

impl std::error::Error for MyError {}

impl From<sqlx::Error> for MyError {
    fn from(e: sqlx::Error) -> Self {
        MyError::SqlxError(e)
    }
}

impl From<std::io::Error> for MyError {
    fn from(e: std::io::Error) -> Self {
        MyError::IoError(e)
    }
}

#[derive(Clone)]
struct AppState {
    pool: PgPool,
    slot_machine: web::Data<Mutex<SlotMachine>>,
    jackpot: web::Data<Mutex<ProgressiveJackpot>>,
}

#[derive(Deserialize)]
struct TodoNew {
    pub note: String,
}

#[derive(Serialize, Deserialize, FromRow)]
struct Todo {
    pub id: i32,
    pub note: String,
}

#[get("/")]
async fn index() -> impl Responder {
    "Hello, World!"
}

#[get("/health")]
async fn health_check(state: web::Data<AppState>) -> Result<Json<serde_json::Value>> {
    // Check database connection
    let db_check = sqlx::query("SELECT 1").fetch_one(&state.pool).await.is_ok();

    let health_status = serde_json::json!({
        "status": if db_check { "healthy" } else { "unhealthy" },
        "timestamp": chrono::Utc::now(),
        "checks": {
            "database": {
                "status": if db_check { "up" } else { "down" }
            }
        }
    });

    if db_check {
        Ok(Json(health_status))
    } else {
        Err(error::ErrorServiceUnavailable(health_status))
    }
}

#[get("/{name}")]
async fn hello(name: web::Path<String>) -> impl Responder {
    format!("Hello {}!", &name)
}

// Slot machine endpoints
#[post("/slots/spin")]
async fn spin_slots(
    bet: web::Json<SlotBet>,
    state: web::Data<AppState>,
) -> Result<Json<slots::SpinResult>> {
    let mut machine = state.slot_machine.lock().unwrap();
    let mut jackpot = state.jackpot.lock().unwrap();

    // Add bet to progressive jackpot
    jackpot.add_contribution(bet.amount);

    // Spin the slot machine
    let result = machine.spin();

    // Check for jackpot win (three diamonds on center line)
    let is_jackpot = result
        .winning_lines
        .iter()
        .any(|line| matches!(&line.win_type, slots::WinType::ThreeDiamonds));

    let jackpot_win = jackpot.check_and_award(is_jackpot);

    // Create enhanced result with jackpot info
    let enhanced_result = SpinResultWithJackpot {
        grid: result.grid,
        winning_lines: result.winning_lines,
        total_win: result.total_win + jackpot_win.unwrap_or(0) as u32,
        jackpot_win,
    };

    Ok(Json(slots::SpinResult {
        grid: enhanced_result.grid,
        winning_lines: enhanced_result.winning_lines,
        total_win: enhanced_result.total_win,
    }))
}

#[get("/slots/jackpot")]
async fn get_jackpot(state: web::Data<AppState>) -> Result<Json<JackpotInfo>> {
    let jackpot = state.jackpot.lock().unwrap();
    Ok(Json(JackpotInfo {
        current_amount: jackpot.current_amount,
        last_won: jackpot.last_won,
    }))
}

#[get("/slots/rtp")]
async fn calculate_slot_rtp() -> Result<Json<RtpInfo>> {
    let rtp = slots::calculate_rtp(10000);
    Ok(Json(RtpInfo {
        rtp_percentage: rtp,
        sample_size: 10000,
    }))
}

#[derive(Deserialize)]
struct SlotBet {
    amount: u64,
}

#[derive(Serialize)]
struct SpinResultWithJackpot {
    grid: Vec<Vec<slots::Symbol>>,
    winning_lines: Vec<slots::WinningLine>,
    total_win: u32,
    jackpot_win: Option<u64>,
}

#[derive(Serialize)]
struct JackpotInfo {
    current_amount: u64,
    last_won: Option<chrono::DateTime<chrono::Utc>>,
}

#[derive(Serialize)]
struct RtpInfo {
    rtp_percentage: f64,
    sample_size: u32,
}

async fn establish_connection() -> Result<Pool<Postgres>, sqlx::Error> {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:password@localhost:5432/saber".to_string());

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await?;

    // Initialize database schema
    pool.execute(include_str!("../schema.sql")).await?;

    Ok(pool)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();
    let pool = establish_connection().await.unwrap();

    // Initialize slot machine and jackpot
    let slot_machine = web::Data::new(Mutex::new(SlotMachine::new(3, 3)));
    let jackpot = web::Data::new(Mutex::new(ProgressiveJackpot::new(10000, 0.02)));

    let state = web::Data::new(AppState {
        pool,
        slot_machine: slot_machine.clone(),
        jackpot: jackpot.clone(),
    });

    // Get host and port from environment variables
    let host = env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port = env::var("SERVER_PORT")
        .unwrap_or_else(|_| "8000".to_string())
        .parse::<u16>()
        .unwrap_or(8000);

    println!("Server starting at http://{host}:{port}");

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .service(index)
            .service(health_check)
            .service(hello)
            .service(
                web::scope("/todos")
                    .service(retrieve)
                    .service(add)
                    .service(list_todos)
                    .service(update_todo)
                    .service(delete_todo),
            )
            .service(
                web::scope("/slots")
                    .service(spin_slots)
                    .service(get_jackpot)
                    .service(calculate_slot_rtp),
            )
            .service(
                web::scope("/api/slot-config")
                    .route("", web::post().to(slot_config_api::create_slot_config))
                    .route("", web::get().to(slot_config_api::list_slot_configs))
                    .route("/{id}", web::get().to(slot_config_api::get_slot_config))
                    .route("/symbol", web::post().to(slot_config_api::add_symbol))
                    .route(
                        "/reel-symbol",
                        web::post().to(slot_config_api::add_reel_symbol),
                    )
                    .route("/payline", web::post().to(slot_config_api::add_payline))
                    .route(
                        "/{id}/symbols",
                        web::get().to(slot_config_api::get_slot_symbols),
                    )
                    .route(
                        "/{id}/reels",
                        web::get().to(slot_config_api::get_slot_reels),
                    )
                    .route(
                        "/{id}/paylines",
                        web::get().to(slot_config_api::get_slot_paylines),
                    )
                    .route("/spin", web::post().to(slot_config_api::test_spin)),
            )
            .service(fs::Files::new("/admin", "./admin").index_file("index.html"))
            .app_data(state.clone())
            .app_data(slot_machine.clone())
            .app_data(jackpot.clone())
    })
    .bind((host.as_str(), port))?
    .run()
    .await?;

    Ok(())
}
