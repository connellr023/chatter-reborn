import gleam/json
import gleeunit/should
import models/chat

pub fn serialization_test() {
  chat.new("sigma123", "hi")
  |> chat.to_json
  |> json.to_string
  |> should.equal("{\"source\":\"sigma123\",\"content\":\"hi\"}")
}
