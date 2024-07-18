import gleam/json.{type Json}

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

pub fn to_json(chat: Chat) -> Json {
  json.object([
    #("source", json.string(chat.source)),
    #("content", json.string(chat.content))
  ])
}
