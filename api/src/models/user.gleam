import gleam/option.{type Option, None}
import mist.{type WebsocketConnection}

pub opaque type User {
  User(
    connection: WebsocketConnection,
    name: String,
    room_id: Option(Int)
  )
}

pub fn new(id: WebsocketConnection, name: String) -> User {
  User(id, name, None)
}

pub fn get_connection(user: User) -> WebsocketConnection {
  user.connection
}

pub fn get_name(user: User) -> String {
  user.name
}

pub fn get_room_id(user: User) -> Option(Int) {
  user.room_id
}

pub fn set_room_id(user: User, room_id: Option(Int)) -> User {
  User(..user, room_id: room_id)
}
