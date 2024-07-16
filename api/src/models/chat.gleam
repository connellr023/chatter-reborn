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
