#[derive(rocket_db_pools::Database)]
#[database("erke")]
struct ErkeDb(rocket_db_pools::sqlx::PgPool);

#[rocket::get("/")]
fn route_index() -> &'static str {
    "Hello, world!"
}

#[rocket::launch]
fn rocket() -> _ {
    rocket::build().mount("/", rocket::routes![route_index])
}
