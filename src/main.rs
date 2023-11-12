use std::collections::HashMap;

use ntex::web;

#[derive(serde::Serialize)]
struct DefaultResponse {
  headers: HashMap<String, String>,
  envs: HashMap<String, String>,
}

#[web::get("{all}*")]
async fn endpoint(req: web::HttpRequest) -> web::HttpResponse {
  let envs = std::env::vars();
  let headers = req
    .headers()
    .iter()
    .fold(HashMap::new(), |mut acc, (k, v)| {
      acc.insert(k.to_string(), v.to_str().unwrap_or("").to_string());
      acc
    });
  let envs = envs.fold(HashMap::new(), |mut acc, (k, v)| {
    acc.insert(k, v);
    acc
  });
  let resp = DefaultResponse { headers, envs };
  web::HttpResponse::Ok().json(&resp)
}

#[ntex::main]
async fn main() -> std::io::Result<()> {
  let port = std::env::var("PORT").unwrap_or_else(|_| "8080".to_owned());
  let server = web::HttpServer::new(|| web::App::new().service(endpoint));
  server.bind(&format!("0.0.0.0:{port}"))?.run().await?;
  Ok(())
}
