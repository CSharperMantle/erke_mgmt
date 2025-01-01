use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;
use sqlx::Row;

// Shape coincides with the SQL relation
#[derive(serde::Serialize, sqlx::FromRow)]
pub struct RatingAggGet {
    activity_id: i32,
    rate_cnt: i64,
    rate_avg: Option<f64>,
    rate_max: Option<f64>,
    rate_min: Option<f64>,
}

#[derive(serde::Serialize)]
pub struct RatingGetResponse {
    message: String,
    data: Option<Vec<RatingAggGet>>,
}

impl From<String> for RatingGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type RatingGetError = RouteError<RatingGetResponse>;

#[rocket::get("/rating_agg")]
pub async fn route_rating_agg_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<RatingGetResponse>, RatingGetError> {
    let mut conn = try_authenticate(jar).await?;

    let data = sqlx::query_as::<sqlx::postgres::Postgres, RatingAggGet>(
        r##"
SELECT activity_id, rate_cnt, rate_avg, rate_max, rate_min FROM v_RatingAgg;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    Ok(Json(RatingGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Serialize, sqlx::FromRow)]
pub struct MyRateGet {
    student_id: String,
    activity_id: i32,
    rate_value: f64,
}

#[derive(serde::Serialize)]
pub struct MyRateGetResponse {
    message: String,
    data: Option<Vec<MyRateGet>>,
}

impl From<String> for MyRateGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type MyRateGetError = RouteError<MyRateGetResponse>;

#[rocket::get("/my_rate")]
pub async fn route_my_rate_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<MyRateGetResponse>, MyRateGetError> {
    let mut conn = try_authenticate(jar).await?;

    let data = sqlx::query_as::<sqlx::postgres::Postgres, MyRateGet>(
        r##"
SELECT student_id, activity_id, rate_value FROM v_StudentSelfRate;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    Ok(Json(MyRateGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Deserialize)]
pub struct MyRatePut {
    student_id: String,
    activity_id: i32,
    rate_value: f64,
}

#[derive(serde::Deserialize)]
pub struct MyRatePutRequest {
    data: MyRatePut,
}

#[derive(serde::Serialize)]
pub struct MyRatePutResponse {
    message: String,
}

impl From<String> for MyRatePutResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type MyRatePutError = RouteError<MyRatePutResponse>;

#[rocket::put("/my_rate", format = "application/json", data = "<req>")]
pub async fn route_my_rate_put(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<MyRatePutRequest>,
) -> Result<Json<MyRatePutResponse>, MyRatePutError> {
    let mut conn = try_authenticate(jar).await?;

    let result = sqlx::query(
        r##"
CALL p_rate($1, $2, $3, FALSE, '');
"##,
    )
    .bind(&req.data.student_id)
    .bind(req.data.activity_id)
    .bind(req.data.rate_value)
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = result.try_get(0).dispatch_err()?;
    if !okay {
        let message: String = result.try_get(1).dispatch_err()?;
        Err(RouteError::make_invalid(Some(message)))
    } else {
        Ok(Json(MyRatePutResponse {
            message: Default::default(),
        }))
    }
}
