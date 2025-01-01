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
            rocket::routes![
                route::activity::route_activity_get,
                route::do_checkinout::route_do_check_in_post,
                route::do_checkinout::route_do_check_out_post,
                route::rate::route_rating_agg_get,
                route::rate::route_my_rate_get,
                route::rate::route_my_rate_put,
            ],
        )
        .mount(
            "/api/organizer",
            rocket::routes![
                route::activity::route_activity_get,
                route::activity::route_activity_put,
                route::init_checkinout::route_initiate_check_in_post,
                route::init_checkinout::route_initiate_check_out_post,
                route::rate::route_rating_agg_get
            ],
        )
        .mount(
            "/api/auditor",
            rocket::routes![
                route::activity::route_activity_get,
                route::audit::route_my_audit_get,
                route::audit::route_my_audit_put,
                route::rate::route_rating_agg_get
            ],
        )
        .mount(
            "/",
            rocket::fs::FileServer::from(dotenvy_macro::dotenv!("FRONTEND_PATH")),
        )
}
