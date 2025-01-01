mod route;

#[rocket::launch]
fn rocket() -> _ {
    rocket::build().mount(
        "/api",
        rocket::routes![route::login::route_login, route::logout::route_logout],
    )
}
