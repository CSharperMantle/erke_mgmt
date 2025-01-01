use rocket::response::status;
use rocket::serde::json::Json;

#[derive(serde::Serialize)]
pub struct LogoutResponse {
    message: String,
}

#[rocket::post("/logout")]
pub async fn route_logout(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<LogoutResponse>, status::Forbidden<Json<LogoutResponse>>> {
    if jar.get_private("db_url").is_none() {
        return Err(status::Forbidden(Json(LogoutResponse {
            message: "already logged out".to_string(),
        })));
    }
    jar.remove_private("db_url");
    Ok(Json(LogoutResponse {
        message: "ok".to_string(),
    }))
}
