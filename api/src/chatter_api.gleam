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

pub fn main() {
  io.println("Hello from chatter_api!")
}
