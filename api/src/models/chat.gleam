import gleam/json

pub opaque type Chat {
  Chat(
    source: String,
    content: String
  )
}

pub fn new(source: String, content: String) -> Chat {
  Chat(
    source: source,
    content: content
  )
}

pub fn serialize(chat: Chat) -> String {
  json.object([
    #("source", json.string(chat.source)),
    #("content", json.string(chat.content))
  ])
  |> json.to_string()
}
