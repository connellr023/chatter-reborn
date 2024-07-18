import gleam/dynamic
import gleam/json.{type Json}

pub opaque type SocketMessage {
  SocketMessage(event: String, body: String)
}

pub fn get_event(message: SocketMessage) -> String {
  message.event
}

pub fn get_body(message: SocketMessage) -> String {
  message.body
}

pub fn new(event: String, body: String) -> SocketMessage {
  SocketMessage(event: event, body: body)
}

pub fn to_json(message: SocketMessage) -> Json {
  json.object([
    #("event", json.string(message.event)),
    #("body", json.string(message.body)),
  ])
}

pub fn custom_body_to_json(event: String, body: Json) -> Json {
  json.object([#("event", json.string(event)), #("body", body)])
}

pub fn deserialize(json: String) -> Result(SocketMessage, _) {
  let message_decoder =
    dynamic.decode2(
      SocketMessage,
      dynamic.field("event", of: dynamic.string),
      dynamic.field("body", of: dynamic.string),
    )

  json.decode(from: json, using: message_decoder)
}
