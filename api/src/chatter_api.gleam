import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{Some}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData, Bytes}
import actors/supervisor_actor
import actors/websocket_actor

const port: Int = 3000

pub fn main() {
  let supervisor_actor = supervisor_actor.start()

  let assert Ok(_) = fn(req: Request(Connection)) -> Response(ResponseData) {
    let selector = process.new_selector()

    case request.path_segments(req) {
      ["api", "connect"] -> websocket_actor.upgrade_to_websocket(req, supervisor_actor, Some(selector))
      _ -> response.new(404) |> response.set_body(Bytes(bytes_builder.new()))
    }
  }
  |> mist.new
  |> mist.port(port)
  |> mist.start_http

  process.sleep_forever()
}
