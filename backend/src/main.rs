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
            "/api/student",
            rocket::routes![route::activity::route_activity_get],
        )
        .mount(
            "/api/organizer",
            rocket::routes![
                route::activity::route_activity_get,
                route::activity::route_activity_put
            ],
        )
        .mount(
            "/api/auditor",
            rocket::routes![route::activity::route_activity_get],
        )
        .mount(
            "/",
            rocket::fs::FileServer::from(dotenvy_macro::dotenv!("FRONTEND_PATH")),
        )
}
