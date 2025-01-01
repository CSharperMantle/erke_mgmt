use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use sqlx::Row;

#[derive(Deserialize)]
pub struct InitiateCheckInOutPost {
    organizer_id: String,
    activity_id: i32,
    valid_duration: u32,
}

#[derive(Deserialize)]
pub struct InitiateCheckInOutPostRequest {
    data: InitiateCheckInOutPost,
}

#[derive(Serialize)]
pub struct InitiateCheckInOutCode {
    code: String,
}

#[derive(Serialize)]
pub struct InitiateCheckInOutPostResponse {
    message: String,
    data: Option<InitiateCheckInOutCode>,
}

impl From<String> for InitiateCheckInOutPostResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type InitiateCheckInOutPostError = RouteError<InitiateCheckInOutPostResponse>;

#[rocket::post("/initiate_check_in", format = "application/json", data = "<req>")]
pub async fn route_initiate_check_in_post(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<InitiateCheckInOutPostRequest>,
) -> Result<Json<InitiateCheckInOutPostResponse>, InitiateCheckInOutPostError> {
    let mut conn = try_authenticate(jar).await?;

    let valid_duration_time = sqlx::types::chrono::NaiveTime::from_num_seconds_from_midnight_opt(
        req.data.valid_duration,
        0,
    )
    .ok_or(InitiateCheckInOutPostError::make_invalid(Some(
        "invalid valid_duration".to_string(),
    )))?;
    let row = sqlx::query(
        r##"
CALL p_initiate_checkin($1, $2, $3, FALSE, '', '');
"##,
    )
    .bind(&req.data.organizer_id)
    .bind(req.data.activity_id)
    .bind(valid_duration_time) // Convert seconds to NaiveTime
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let msg: String = row.try_get(1).dispatch_err()?;
        Err(InitiateCheckInOutPostError::make_invalid(Some(msg)))
    } else {
        let code = InitiateCheckInOutCode {
            code: row.try_get(2).dispatch_err()?,
        };
        Ok(Json(InitiateCheckInOutPostResponse {
            message: Default::default(),
            data: Some(code),
        }))
    }
}

#[rocket::post("/initiate_check_out", format = "application/json", data = "<req>")]
pub async fn route_initiate_check_out_post(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<InitiateCheckInOutPostRequest>,
) -> Result<Json<InitiateCheckInOutPostResponse>, InitiateCheckInOutPostError> {
    let mut conn = try_authenticate(jar).await?;

    let valid_duration_time = sqlx::types::chrono::NaiveTime::from_num_seconds_from_midnight_opt(
        req.data.valid_duration,
        0,
    )
    .ok_or(InitiateCheckInOutPostError::make_invalid(Some(
        "invalid valid_duration".to_string(),
    )))?;

    let row = sqlx::query(
        r##"
CALL p_initiate_checkout($1, $2, $3, FALSE, '', '');
"##,
    )
    .bind(&req.data.organizer_id)
    .bind(req.data.activity_id)
    .bind(valid_duration_time) // Convert seconds to NaiveTime
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let msg: String = row.try_get(1).dispatch_err()?;
        Err(InitiateCheckInOutPostError::make_invalid(Some(msg)))
    } else {
        let code = InitiateCheckInOutCode {
            code: row.try_get(2).dispatch_err()?,
        };
        Ok(Json(InitiateCheckInOutPostResponse {
            message: Default::default(),
            data: Some(code),
        }))
    }
}
