use std::collections::HashMap;

use ntex::{web, http};

#[derive(serde::Serialize)]
struct DefaultResponse {
  headers: http::HeaderMap,
  envs: HashMap<String, String>,
}

#[web::get("{all}*")]
async fn endpoint(req: web::HttpRequest) -> web::HttpResponse {
  let headers = req.headers().clone();
  let envs = std::env::vars().fold(HashMap::new(), |mut acc, (k, v)| {
    acc.insert(k, v);
    acc
  });
  let resp = DefaultResponse { headers, envs };
  web::HttpResponse::Ok().json(&resp)
}

fn main() -> std::io::Result<()> {
  ntex::rt::System::new("main").block_on(async {
    let port = std::env::var("PORT").unwrap_or_else(|_| "9000".to_owned());
    let server = web::HttpServer::new(|| web::App::new().service(endpoint));
    let addr = &format!("0.0.0.0:{port}");
    println!("Listening on: {addr}");
    server.bind(addr)?.run().await?;
    Ok::<_, std::io::Error>(())
  })?;
  Ok(())
}
