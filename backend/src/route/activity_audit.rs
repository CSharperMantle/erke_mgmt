use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;

#[derive(serde::Serialize)]
pub struct ActivityAuditGet {
    id: i32,
    auditor_id: String,
    auditor_name: String,
    activity_id: i32,
    activity_name: String,
    audit_comment: String,
    audit_passed: bool,
}

#[derive(serde::Serialize)]
pub struct ActivityAuditGetResponse {
    message: String,
    data: Option<Vec<ActivityAuditGet>>,
}

impl From<String> for ActivityAuditGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type ActivityAuditGetError = RouteError<ActivityAuditGetResponse>;

#[rocket::get("/my_activity_audit")]
pub async fn route_my_activity_audit_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<ActivityAuditGetResponse>, ActivityAuditGetError> {
    #[derive(sqlx::FromRow)]
    struct ActivityAuditRow {
        audit_id: i32,
        auditor_id: String,
        auditor_name: String,
        activity_id: i32,
        activity_name: String,
        audit_comment: String,
        audit_passed: bool,
    }

    let mut conn = try_authenticate(jar).await?;

    let audits = sqlx::query_as::<sqlx::postgres::Postgres, ActivityAuditRow>(
        r##"
SELECT audit_id, auditor_id, auditor_name, activity_id, activity_name, audit_comment, audit_passed FROM v_OrganizerSelfAudit;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = audits
        .iter()
        .map(|r| ActivityAuditGet {
            id: r.audit_id,
            auditor_id: r.auditor_id.clone(),
            auditor_name: r.auditor_name.clone(),
            activity_id: r.activity_id,
            activity_name: r.activity_name.clone(),
            audit_comment: r.audit_comment.clone(),
            audit_passed: r.audit_passed,
        })
        .collect();

    Ok(Json(ActivityAuditGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}
