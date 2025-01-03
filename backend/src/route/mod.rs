pub mod activity;
pub mod activity_audit;
pub mod audit;
pub mod do_checkinout;
pub mod init_checkinout;
pub mod login;
pub mod logout;
pub mod rate;
pub mod signup;
pub mod tag;

#[derive(rocket::response::Responder)]
pub enum RouteError<T>
where
    T: From<String>,
{
    #[response(status = 403)]
    Forbidden(rocket::serde::json::Json<T>),

    #[response(status = 409)]
    Conflict(rocket::serde::json::Json<T>),

    #[response(status = 422)]
    Invalid(rocket::serde::json::Json<T>),

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

    fn make_conflict(message: Option<String>) -> Self {
        RouteError::Conflict(rocket::serde::json::Json(T::from(
            message.unwrap_or_default(),
        )))
    }

    fn make_invalid(message: Option<String>) -> Self {
        RouteError::Invalid(rocket::serde::json::Json(T::from(
            message.unwrap_or_default(),
        )))
    }

    fn make_other(message: Option<String>) -> Self {
        RouteError::Other(rocket::serde::json::Json(T::from(
            message.unwrap_or_default(),
        )))
    }
}

async fn try_authenticate<T>(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<sqlx::postgres::PgConnection, RouteError<T>>
where
    T: From<String>,
{
    use sqlx::Connection;
    type E<T> = RouteError<T>;

    let db_url = jar
        .get_private("db_url")
        .ok_or(E::make_forbidden(Some("not logged in".to_string())))?
        .value()
        .to_string();
    let conn = sqlx::postgres::PgConnection::connect(&db_url)
        .await
        .dispatch_err()?;
    Ok(conn)
}

trait DispatchSqlxError<R, T>
where
    T: From<String>,
{
    fn dispatch_err(self) -> Result<R, RouteError<T>>;
}

impl<R, T> DispatchSqlxError<R, T> for Result<R, sqlx::Error>
where
    T: From<String>,
{
    fn dispatch_err(self) -> Result<R, RouteError<T>> {
        use sqlx::error::ErrorKind as DbErrorKind;
        use sqlx::Error as SqlxError;

        self.map_err(|e| match e {
            SqlxError::Database(dbe) => match dbe.kind() {
                DbErrorKind::CheckViolation
                | DbErrorKind::UniqueViolation
                | DbErrorKind::ForeignKeyViolation
                | DbErrorKind::NotNullViolation => RouteError::make_invalid(Some(dbe.to_string())),
                _ => RouteError::make_conflict(Some(dbe.to_string())),
            },
            _ => RouteError::make_other(Some(e.to_string())),
        })
    }
}
