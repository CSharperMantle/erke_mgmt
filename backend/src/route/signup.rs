use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;
use sqlx::{types::chrono, Row};

#[derive(serde::Serialize)]
pub struct MySignUpGet {
    student_id: String,
    activity_id: i32,
    signup_time: i64,
}

#[derive(serde::Serialize)]
pub struct MySignUpGetResponse {
    message: String,
    data: Option<Vec<MySignUpGet>>,
}

impl From<String> for MySignUpGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type MySignUpGetError = RouteError<MySignUpGetResponse>;

#[rocket::get("/my_signup")]
pub async fn route_my_signup_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<MySignUpGetResponse>, MySignUpGetError> {
    #[derive(sqlx::FromRow)]
    struct SignUpRow {
        student_id: String,
        activity_id: i32,
        signup_time: chrono::DateTime<chrono::Utc>,
    }

    let mut conn = try_authenticate(jar).await?;

    let signups = sqlx::query_as::<sqlx::postgres::Postgres, SignUpRow>(
        r##"
SELECT student_id, activity_id, signup_time FROM v_StudentSelfSignUp;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = signups
        .iter()
        .map(|r| MySignUpGet {
            student_id: r.student_id.clone(),
            activity_id: r.activity_id,
            signup_time: r.signup_time.timestamp_millis(),
        })
        .collect();

    Ok(Json(MySignUpGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Deserialize)]
pub struct MySignUpPut {
    student_id: String,
    activity_id: i32,
}

#[derive(serde::Deserialize)]
pub struct MySignUpPutRequest {
    data: MySignUpPut,
}

#[derive(serde::Serialize)]
pub struct MySignUpPutResponse {
    message: String,
}

impl From<String> for MySignUpPutResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type MySignUpPutError = RouteError<MySignUpPutResponse>;

#[rocket::put("/my_signup", format = "application/json", data = "<req>")]
pub async fn route_my_signup_put(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<MySignUpPutRequest>,
) -> Result<Json<MySignUpPutResponse>, MySignUpPutError> {
    let mut conn = try_authenticate(jar).await?;

    let row = sqlx::query(
        r##"
CALL p_signup($1, $2, FALSE, '');
"##,
    )
    .bind(&req.data.student_id)
    .bind(req.data.activity_id)
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let message: String = row.try_get(1).dispatch_err()?;
        Err(MySignUpPutError::make_invalid(Some(message)))
    } else {
        Ok(Json(MySignUpPutResponse {
            message: Default::default(),
        }))
    }
}
