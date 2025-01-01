#![deny(clippy::all)]

mod route;

#[rocket::launch]
fn rocket() -> _ {
    rocket::build()
        .mount(
            "/api",
            rocket::routes![route::login::route_login, route::logout::route_logout],
        )
        .mount(
            "/",
            rocket::fs::FileServer::from(dotenvy_macro::dotenv!("FRONTEND_PATH")),
        )
}
