import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{Some}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import actors/supervisor_actor
import actors/users_actor.{type UsersActorMessage, type UsersActorState}

const port: Int = 3000

pub fn main() {
  let _supervisor_actor = supervisor_actor.start()

  let assert Ok(_) = fn(req: Request(Connection)) -> Response(ResponseData) {
    let _selector = process.new_selector()

    case request.path_segments(req) {
      _ -> response.new(404) |> response.set_body(mist.Bytes(bytes_builder.new()))
    }
  }
  |> mist.new
  |> mist.port(port)
  |> mist.start_http

  process.sleep_forever()
}
