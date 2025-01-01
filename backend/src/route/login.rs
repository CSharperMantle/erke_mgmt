use rocket::serde::json::Json;
use sqlx::Connection;

use super::RouteError;

#[derive(serde::Deserialize)]
pub struct LoginRequest {
    username: String,
    password: String,
}

#[derive(serde::Serialize)]
pub struct LoginResponse {
    message: String,
}

impl From<String> for LoginResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type LoginError = RouteError<LoginResponse>;

#[rocket::post("/login", format = "application/json", data = "<req>")]
pub async fn route_login(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<LoginRequest>,
) -> Result<Json<LoginResponse>, LoginError> {
    let mut db_url = url::Url::parse("postgres://user:password@127.0.0.1:15432/erke")
        .map_err(|_| LoginError::make_other(None))?;
    db_url
        .set_username(&format!("erke_{}", req.username))
        .map_err(|_| LoginError::make_other(None))?;
    db_url
        .set_password(Some(&req.password))
        .map_err(|_| LoginError::make_other(None))?;
    db_url
        .set_host(Some(dotenvy_macro::dotenv!("DB_HOST")))
        .map_err(|_| LoginError::make_other(None))?;
    db_url
        .set_port(Some(
            dotenvy_macro::dotenv!("DB_PORT").parse::<u16>().unwrap(),
        ))
        .map_err(|_| LoginError::make_other(None))?;
    let mut conn = sqlx::postgres::PgConnection::connect(db_url.as_str())
        .await
        .map_err(|e| match e {
            sqlx::Error::Configuration(e) => LoginError::make_other(Some(e.to_string())),
            _ => LoginError::make_forbidden(Some("wrong username or password".to_string())),
        })?;
    let row: (i32,) = sqlx::query_as("SELECT 1;")
        .fetch_one(&mut conn)
        .await
        .map_err(|_| LoginError::make_forbidden(Some("no permission to select".to_string())))?;
    conn.close()
        .await
        .map_err(|_| LoginError::make_other(None))?;

    if row.0 == 1 {
        jar.add_private(("db_url", db_url.to_string()));
        Ok(Json(LoginResponse {
            message: Default::default(),
        }))
    } else {
        Err(LoginError::make_other(None))
    }
}
