import models/user.{type User}
import models/room.{type Room}

pub opaque type Chat {
  Chat(id: Int, content: String, source: User, target: Room)
}
