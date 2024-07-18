import gleam/json
import gleeunit/should
import models/chat
import models/socket_message

pub fn serialization_test() {
  socket_message.new("testevent", "testbody")
  |> socket_message.to_json
  |> json.to_string
  |> should.equal("{\"event\":\"testevent\",\"body\":\"testbody\"}")
}

pub fn custom_serialization_test() {
  let chat_json =
    chat.new("testuser", "testchat")
    |> chat.to_json

  let chat_str =
    chat_json
    |> json.to_string

  socket_message.custom_body_to_json("testevent", chat_json)
  |> json.to_string
  |> should.equal("{\"event\":\"testevent\",\"body\":" <> chat_str <> "}")
}

pub fn deserialize_test() {
  let expected = socket_message.new("testevent", "testbody")

  "{\"event\":\"testevent\",\"body\":\"testbody\"}"
  |> socket_message.deserialize
  |> should.equal(Ok(expected))
}
