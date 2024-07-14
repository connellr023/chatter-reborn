import gleam/bytes_builder
import gleam/erlang/process
import gleam/io
import gleam/iterator
import gleam/otp/actor
import gleam/result
import gleam/string
import gleam/option.{None, Some}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}

fn init_server(req: Request(Connection)) -> Response(ResponseData) {

}

pub fn main() {
  let not_found = response.new(404) |> response.set_body(mist.Bytes(bytes_builder.new()))

  let assert Ok(_) = init_server
  |> mist.new
  |> mist.port(3000)
  |> mist.start_http

  process.sleep_forever()
}
