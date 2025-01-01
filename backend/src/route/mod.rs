pub mod activity;
pub mod login;
pub mod logout;

#[derive(rocket::response::Responder)]
pub enum RouteError<T>
where
    T: From<String>,
{
    #[response(status = 403)]
    Forbidden(rocket::serde::json::Json<T>),

    #[response(status = 500)]
    Other(rocket::serde::json::Json<T>),
}

impl<T> RouteError<T>
where
    T: From<String>,
{
    fn make_forbidden(message: Option<String>) -> Self {
        RouteError::Forbidden(rocket::serde::json::Json(T::from(
            message.unwrap_or_default(),
        )))
    }
    fn make_other(message: Option<String>) -> Self {
        RouteError::Other(rocket::serde::json::Json(T::from(
            message.unwrap_or_default(),
        )))
    }
}

async fn try_authenticate<T>(jar: &rocket::http::CookieJar<'_>) -> Result<sqlx::postgres::PgConnection, RouteError<T>>
where
    T: From<String>
{
    use sqlx::Connection;
    type E<T> = RouteError<T>;

    let db_url = jar
        .get_private("db_url")
        .ok_or(E::make_forbidden(Some(
            "not logged in".to_string(),
        )))?
        .value()
        .to_string();
    let conn = sqlx::postgres::PgConnection::connect(&db_url)
        .await
        .map_err(|e| E::make_other(Some(e.to_string())))?;

    Ok(conn)
}
