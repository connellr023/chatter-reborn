import gleam/dynamic
import gleam/json

pub opaque type Message {
  Message(
    event: String,
    body: String
  )
}

pub fn get_event(message: Message) -> String {
  message.event
}

pub fn get_body(message: Message) -> String {
  message.body
}

pub fn new(event: String, body: String) -> Message {
  Message(
    event: event,
    body: body
  )
}

pub fn serialize(message: Message) -> String {
  json.object([
    #("event", json.string(message.event)),
    #("body", json.string(message.body))
  ])
  |> json.to_string
}

pub fn deserialize(json: String) -> Result(Message, _) {
  let message_decoder = dynamic.decode2(
    Message,
    dynamic.field("event", of: dynamic.string),
    dynamic.field("body", of: dynamic.string)
  )

  json.decode(from: json, using: message_decoder)
}
