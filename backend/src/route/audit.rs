use super::{try_authenticate, DispatchSqlxError, RouteError};
use rocket::serde::json::Json;
use sqlx::Row;

#[derive(serde::Serialize)]
pub struct AuditGet {
    id: i32,
    auditor_id: String,
    activity_id: i32,
    audit_comment: String,
    audit_passed: bool,
}

#[derive(serde::Serialize)]
pub struct AuditGetResponse {
    message: String,
    data: Option<Vec<AuditGet>>,
}

impl From<String> for AuditGetResponse {
    fn from(value: String) -> Self {
        Self {
            message: value,
            data: None,
        }
    }
}

type AuditGetError = RouteError<AuditGetResponse>;

#[rocket::get("/my_audit")]
pub async fn route_my_audit_get(
    jar: &rocket::http::CookieJar<'_>,
) -> Result<Json<AuditGetResponse>, AuditGetError> {
    #[derive(sqlx::FromRow)]
    struct AuditRow {
        audit_id: i32,
        auditor_id: String,
        activity_id: i32,
        audit_comment: String,
        audit_passed: bool,
    }

    let mut conn = try_authenticate(jar).await?;

    let audits = sqlx::query_as::<sqlx::postgres::Postgres, AuditRow>(
        r##"
SELECT * FROM v_AuditorSelfAudit;
"##,
    )
    .fetch_all(&mut conn)
    .await
    .dispatch_err()?;

    let data = audits
        .iter()
        .map(|r| AuditGet {
            id: r.audit_id,
            auditor_id: r.auditor_id.clone(),
            activity_id: r.activity_id,
            audit_comment: r.audit_comment.clone(),
            audit_passed: r.audit_passed,
        })
        .collect();

    Ok(Json(AuditGetResponse {
        message: Default::default(),
        data: Some(data),
    }))
}

#[derive(serde::Deserialize)]
pub struct AuditPut {
    auditor_id: String,
    activity_id: i32,
    audit_comment: String,
    audit_passed: bool,
}

#[derive(serde::Deserialize)]
pub struct AuditPutRequest {
    data: AuditPut,
}

#[derive(serde::Serialize)]
pub struct AuditPutResponse {
    message: String,
}

impl From<String> for AuditPutResponse {
    fn from(value: String) -> Self {
        Self { message: value }
    }
}

type AuditPutError = RouteError<AuditPutResponse>;

#[rocket::put("/my_audit", format = "application/json", data = "<req>")]
pub async fn route_my_audit_put(
    jar: &rocket::http::CookieJar<'_>,
    req: Json<AuditPutRequest>,
) -> Result<Json<AuditPutResponse>, AuditPutError> {
    let mut conn = try_authenticate(jar).await?;

    let row = sqlx::query(
        r##"
CALL p_audit($1, $2, $3, $4, FALSE, '');
"##,
    )
    .bind(&req.data.auditor_id)
    .bind(req.data.activity_id)
    .bind(&req.data.audit_comment)
    .bind(req.data.audit_passed)
    .fetch_one(&mut conn)
    .await
    .dispatch_err()?;

    let okay: bool = row.try_get(0).dispatch_err()?;

    if !okay {
        let message: String = row.try_get(1).dispatch_err()?;
        Err(AuditPutError::make_invalid(Some(message)))
    } else {
        Ok(Json(AuditPutResponse {
            message: Default::default(),
        }))
    }
}
