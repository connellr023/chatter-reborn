import models/user.{type User}

pub opaque type Chat {
  Chat(
    source: User,
    content: String
  )
}

pub fn new(source: User, content: String) -> Chat {
  Chat(
    source: source,
    content: content
  )
}
