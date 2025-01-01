use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;

#[derive(serde::Serialize)]
pub struct TagGet {
    id: i32,
    name: String,
}

#[derive(serde::Serialize)]
pub struct TagGetResponse {
    message: String,
    data: Option<Vec<TagGet>>,
}

impl From<String> for TagGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type TagGetError = RouteError<TagGetResponse>;

#[rocket::get("/tag")]
pub async fn route_tag_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<TagGetResponse>, TagGetError> {
    #[derive(sqlx::FromRow)]
    struct TagRow {
        activity_tag_id: i32,
        activity_tag_name: String,
    }

    let mut conn = try_authenticate(jar).await?;

    let tags = sqlx::query_as::<sqlx::postgres::Postgres, TagRow>(
        r##"
SELECT activity_tag_id, activity_tag_name FROM ActivityTag;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = tags
        .iter()
        .map(|r| TagGet {
            id: r.activity_tag_id,
            name: r.activity_tag_name.clone(),
        })
        .collect();

    Ok(Json(TagGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}
