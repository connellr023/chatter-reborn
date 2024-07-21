import actors/queue_actor
import actors/websocket_actor
import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import mist.{type Connection, type ResponseData, Bytes}

const port: Int = 3000
const build_path: String = "dist"

pub fn main() {
  let queue_actor = queue_actor.start()

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["api", "connect"] -> websocket_actor.start(req, queue_actor)
        [] -> serve_file([build_path, "index.html"])
        path -> serve_file([build_path, ..path])
      }
    }
    |> mist.new
    |> mist.port(port)
    |> mist.after_start(fn(_, _) {
      { "Listening on port: " <> { port |> int.to_string } }
      |> io.println
    })
    |> mist.start_http

  process.sleep_forever()
}

fn not_found() -> Response(ResponseData) {
  404
  |> response.new
  |> response.set_body(Bytes(bytes_builder.new()))
}

fn serve_file(path: List(String)) -> Response(ResponseData) {
  let file_path = string.join(path, "/")

  mist.send_file(file_path, offset: 0, limit: None)
  |> result.map(fn(file) {
    let assert Some(content_type) = get_content_type(file_path)

    response.new(200)
    |> response.prepend_header("content-type", content_type)
    |> response.set_body(file)
  })
  |> result.lazy_unwrap(not_found)
}

pub fn get_content_type(path: String) -> Option(String) {
  case string.split_once(path, on: ".") {
    Ok(#(_, suffix)) ->
      Some(case suffix {
        "js" -> "text/javascript"
        "css" -> "text/css"
        "html" -> "text/html"
        "png" -> "image/png"
        "ico" -> "image/x-icon"
        "svg" -> "image/svg+xml"
        "jpg" | "jpeg" -> "image/jpeg"
        _ -> "text/plain"
      })
    Error(_) -> None
  }
}
