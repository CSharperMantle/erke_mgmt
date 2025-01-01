use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use sqlx::Row;

#[derive(Deserialize)]
pub struct DoCheckInOutPost {
    student_id: String,
    code: String,
}

#[derive(Deserialize)]
pub struct DoCheckInOutPostRequest {
    data: DoCheckInOutPost,
}

#[derive(Serialize)]
pub struct DoCheckInOutPostResponse {
    message: String,
}

impl From<String> for DoCheckInOutPostResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type DoCheckInOutPostError = RouteError<DoCheckInOutPostResponse>;

#[rocket::post("/do_check_in", format = "application/json", data = "<req>")]
pub async fn route_do_check_in_post(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<DoCheckInOutPostRequest>,
) -> Result<Json<DoCheckInOutPostResponse>, DoCheckInOutPostError> {
    let mut conn = try_authenticate(jar).await?;

    let row = sqlx::query(
        r##"
CALL p_do_checkin($1, $2, FALSE, '');
"##,
    )
    .bind(&req.data.student_id)
    .bind(&req.data.code)
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let message: String = row.try_get(1).dispatch_err()?;
        Err(DoCheckInOutPostError::make_invalid(Some(message)))
    } else {
        Ok(Json(DoCheckInOutPostResponse {
            message: Default::default(),
        }))
    }
}

#[rocket::post("/do_check_out", format = "application/json", data = "<req>")]
pub async fn route_do_check_out_post(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<DoCheckInOutPostRequest>,
) -> Result<Json<DoCheckInOutPostResponse>, DoCheckInOutPostError> {
    let mut conn = try_authenticate(jar).await?;

    let row = sqlx::query(
        r##"
CALL p_do_checkout($1, $2, FALSE, '');
"##,
    )
    .bind(&req.data.student_id)
    .bind(&req.data.code)
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let message: String = row.try_get(1).dispatch_err()?;
        Err(DoCheckInOutPostError::make_invalid(Some(message)))
    } else {
        Ok(Json(DoCheckInOutPostResponse {
            message: Default::default(),
        }))
    }
}
