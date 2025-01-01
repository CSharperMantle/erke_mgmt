use super::{try_authenticate, RouteError};
use rocket::serde::json::Json;
use sqlx::{types::chrono, Connection, Row};

#[derive(serde::Serialize)]
pub struct Activity {
    id: Option<i32>,
    organizer_id: String,
    description: String,
    location: String,
    signup_start_time: i64,
    signup_end_time: i64,
    start_time: i64,
    max_particp_count: i32,
    state: Option<i32>,
    tags: Vec<i32>,
    open_to: Vec<i32>,
}

#[derive(serde::Serialize)]
pub struct ActivitiesResponse {
    message: String,
    data: Option<Vec<Activity>>,
}

impl From<String> for ActivitiesResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type ActivitiesError = RouteError<ActivitiesResponse>;
#[rocket::get("/activities")]
pub async fn route_activities_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<ActivitiesResponse>, ActivitiesError> {
    #[derive(sqlx::FromRow)]
    struct ActivityRow {
        activity_id: i32,
        organizer_id: String,
        activity_description: String,
        activity_location: String,
        activity_signup_start_time: sqlx::types::chrono::DateTime<chrono::Utc>,
        activity_signup_end_time: sqlx::types::chrono::DateTime<chrono::Utc>,
        activity_start_time: sqlx::types::chrono::DateTime<chrono::Utc>,
        activity_max_particp_count: i32,
        activity_state: i32,
    }

    #[derive(sqlx::FromRow)]
    struct BeTaggedRow {
        activity_tag_id: i32,
        activity_id: i32,
    }

    #[derive(sqlx::FromRow)]
    struct BeOpenToRow {
        grade_value: i32,
        activity_id: i32,
    }

    let mut conn = try_authenticate(jar).await?;

    let activity_rows = sqlx::query_as::<sqlx::postgres::Postgres, ActivityRow>(
        r##"
SELECT
    a.activity_id,
    a.organizer_id,
    a.activity_description,
    a.activity_location,
    a.activity_signup_start_time,
    a.activity_signup_end_time,
    a.activity_start_time,
    a.activity_max_particp_count,
    a.activity_state
FROM Activity a;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .map_err(|e| ActivitiesError::make_other(Some(e.to_string())))?;

    let be_tagged_rows = sqlx::query_as::<sqlx::postgres::Postgres, BeTaggedRow>(
        r##"
SELECT
    bt.activity_tag_id,
    bt.activity_id
FROM BeTagged bt;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .map_err(|e| ActivitiesError::make_other(Some(e.to_string())))?;

    let be_open_to_rows = sqlx::query_as::<sqlx::postgres::Postgres, BeOpenToRow>(
        r##"
SELECT
    bo.grade_value,
    bo.activity_id
FROM BeOpenTo bo;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .map_err(|e| ActivitiesError::make_other(Some(e.to_string())))?;

    conn.close()
        .await
        .map_err(|e| ActivitiesError::make_other(Some(e.to_string())))?;

    let activities = activity_rows
        .iter()
        .map(|a| {
            let tags = be_tagged_rows
                .iter()
                .filter(|bt| bt.activity_id == a.activity_id)
                .map(|bt| bt.activity_tag_id)
                .collect();
            let open_to = be_open_to_rows
                .iter()
                .filter(|bo| bo.activity_id == a.activity_id)
                .map(|bo| bo.grade_value)
                .collect();
            Activity {
                id: Some(a.activity_id),
                organizer_id: a.organizer_id.clone(),
                description: a.activity_description.clone(),
                location: a.activity_location.clone(),
                signup_start_time: a.activity_signup_start_time.timestamp_millis(),
                signup_end_time: a.activity_signup_end_time.timestamp_millis(),
                start_time: a.activity_start_time.timestamp_millis(),
                max_particp_count: a.activity_max_particp_count,
                state: Some(a.activity_state),
                tags,
                open_to,
            }
        })
        .collect();

    Ok(Json(ActivitiesResponse {
        message: Default::default(),
        data: Some(activities),
    }))
}

#[derive(serde::Deserialize)]
pub struct ActivityPut {
    organizer_id: String,
    description: String,
    location: String,
    signup_start_time: i64,
    signup_end_time: i64,
    start_time: i64,
    max_particp_count: i32,
    tags: Vec<i32>,
    open_to: Vec<i32>,
}

#[derive(serde::Deserialize)]
pub struct ActivityPutRequest {
    data: ActivityPut,
}

#[derive(serde::Serialize)]
pub struct ActivityPutResponse {
    message: String,
}

impl From<String> for ActivityPutResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type ActivityPutError = RouteError<ActivitiesResponse>;

#[rocket::put("/activity", format = "application/json", data = "<req>")]
pub async fn route_activity_put(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<ActivityPutRequest>,
) -> Result<Json<ActivityPutResponse>, ActivityPutError> {
    let mut conn = try_authenticate(jar).await?;

    let mut tx = conn
        .begin()
        .await
        .map_err(|e| ActivitiesError::make_other(Some(e.to_string())))?;

    let result = sqlx::query(
        r##"
INSERT INTO Activity(
    organizer_id,
    activity_description,
    activity_location,
    activity_signup_start_time,
    activity_signup_end_time,
    activity_start_time,
    activity_max_particp_count
) VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING activity_id;
"##,
    )
    .bind(&req.data.organizer_id)
    .bind(&req.data.description)
    .bind(&req.data.location)
    .bind(chrono::DateTime::from_timestamp_millis(
        req.data.signup_start_time,
    ))
    .bind(chrono::DateTime::from_timestamp_millis(
        req.data.signup_end_time,
    ))
    .bind(chrono::DateTime::from_timestamp_millis(req.data.start_time))
    .bind(req.data.max_particp_count)
    .fetch_one(&mut *tx)
    .await
    .map_err(|e| ActivityPutError::make_invalid(Some(e.to_string())))?;

    let row_id: i32 = result
        .try_get("activity_id")
        .map_err(|e| ActivityPutError::make_other(Some(e.to_string())))?;
    for tag_id in req.data.tags.iter() {
        sqlx::query(
            r##"
INSERT INTO BeTagged(
    activity_tag_id,
    activity_id
) VALUES ($1, $2);
"##,
        )
        .bind(tag_id)
        .bind(row_id)
        .execute(&mut *tx)
        .await
        .map_err(|e| ActivityPutError::make_invalid(Some(e.to_string())))?;
    }
    for grade_value in req.data.open_to.iter() {
        sqlx::query(
            r##"
INSERT INTO BeOpenTo(
    grade_value,
    activity_id
) VALUES ($1, $2);
"##,
        )
        .bind(grade_value)
        .bind(row_id)
        .execute(&mut *tx)
        .await
        .map_err(|e| ActivityPutError::make_invalid(Some(e.to_string())))?;
    }

    tx.commit()
        .await
        .map_err(|e| ActivityPutError::make_other(Some(e.to_string())))?;

    conn.close()
        .await
        .map_err(|e| ActivityPutError::make_other(Some(e.to_string())))?;

    Ok(Json(ActivityPutResponse {
        message: Default::default(),
    }))
}
