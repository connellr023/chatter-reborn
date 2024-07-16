import gleam/erlang/process
import gleam/function
import gleam/option.{Some}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/bytes_builder
import mist.{type Connection, type ResponseData, Bytes}
import actors/websocket_actor
import actors/queue_actor

const port: Int = 3000

pub fn main() {
  let queue_actor = queue_actor.start()
  let selector = process.new_selector()

  let assert Ok(_) = fn(req: Request(Connection)) -> Response(ResponseData) {
    case request.path_segments(req) {
      ["api", "connect"] -> websocket_actor.start(req, selector, queue_actor)
      _ -> response.new(404) |> response.set_body(Bytes(bytes_builder.new()))
    }
  }
  |> mist.new
  |> mist.port(port)
  |> mist.start_http

  process.sleep_forever()
}
