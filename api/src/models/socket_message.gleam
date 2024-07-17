import gleam/dynamic
import gleam/json

pub opaque type SocketMessage {
  SocketMessage(
    event: String,
    body: String
  )
}

pub fn get_event(message: SocketMessage) -> String {
  message.event
}

pub fn get_body(message: SocketMessage) -> String {
  message.body
}

pub fn new(event: String, body: String) -> SocketMessage {
  SocketMessage(
    event: event,
    body: body
  )
}

pub fn serialize(message: SocketMessage) -> String {
  json.object([
    #("event", json.string(message.event)),
    #("body", json.string(message.body))
  ])
  |> json.to_string
}

pub fn deserialize(json: String) -> Result(SocketMessage, _) {
  let message_decoder = dynamic.decode2(
    SocketMessage,
    dynamic.field("event", of: dynamic.string),
    dynamic.field("body", of: dynamic.string)
  )

  json.decode(from: json, using: message_decoder)
}
