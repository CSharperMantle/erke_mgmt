use sqlx::Connection;

type RouteResult<T, E = rocket::response::Debug<sqlx::Error>> = std::result::Result<T, E>;

#[rocket::get("/hello")]
async fn route_index() -> RouteResult<String> {
    Ok("Hello, world!".to_string())
}

#[rocket::get("/add?<v1>&<v2>")]
async fn route_add(v1: i32, v2: i32) -> RouteResult<String> {
    let mut conn = sqlx::postgres::PgConnection::connect("postgres://erke_admin:Database%40123@127.0.0.1:15432/erke")
        .await?;
    let row: (i32,) = sqlx::query_as("SELECT $1 + $2;")
        .bind(v1)
        .bind(v2)
        .fetch_one(&mut conn)
        .await?;
    conn.close().await?;
    Ok(format!("{}", row.0).to_string())
}

#[rocket::launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/test", rocket::routes![route_index])
        .mount("/test", rocket::routes![route_add])
}
