use super::{try_authenticate, DispatchSqlxError, RouteError};
use bigdecimal::ToPrimitive;
use rocket::serde::json::Json;
use sqlx::Row;

#[derive(serde::Serialize)]
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
    #[derive(sqlx::FromRow)]
    pub struct RatingAggRow {
        activity_id: i32,
        rate_cnt: i64,
        rate_avg: Option<bigdecimal::BigDecimal>,
        rate_max: Option<bigdecimal::BigDecimal>,
        rate_min: Option<bigdecimal::BigDecimal>,
    }

    let mut conn = try_authenticate(jar).await?;

    let rows = sqlx::query_as::<sqlx::postgres::Postgres, RatingAggRow>(
        r##"
SELECT activity_id, rate_cnt, rate_avg, rate_max, rate_min FROM v_RatingAgg;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = rows
        .iter()
        .map(|r| RatingAggGet {
            activity_id: r.activity_id,
            rate_cnt: r.rate_cnt,
            rate_avg: r.rate_avg.as_ref().and_then(|v| v.to_f64()),
            rate_max: r.rate_max.as_ref().and_then(|v| v.to_f64()),
            rate_min: r.rate_min.as_ref().and_then(|v| v.to_f64()),
        })
        .collect();

    Ok(Json(RatingGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Serialize, sqlx::FromRow)]
pub struct MyRateGet {
    student_id: String,
    activity_id: i32,
    rate_value: Option<f64>,
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
    #[derive(sqlx::FromRow)]
    pub struct RateRow {
        student_id: String,
        activity_id: i32,
        rate_value: bigdecimal::BigDecimal,
    }

    let mut conn = try_authenticate(jar).await?;

    let rows = sqlx::query_as::<sqlx::postgres::Postgres, RateRow>(
        r##"
SELECT student_id, activity_id, rate_value FROM v_StudentSelfRate;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = rows
        .iter()
        .map(|r| MyRateGet {
            student_id: r.student_id.clone(),
            activity_id: r.activity_id,
            rate_value: r.rate_value.to_f64(),
        })
        .collect();

    Ok(Json(MyRateGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Deserialize)]
pub struct MyRatePut {
    student_id: String,
    activity_id: i32,
    rate_value: bigdecimal::BigDecimal,
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
    .bind(&req.data.rate_value)
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
