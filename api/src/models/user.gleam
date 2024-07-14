import mist.{type WebsocketConnection}

pub opaque type User {
  User(connection: WebsocketConnection, name: String)
}

pub fn new(id: WebsocketConnection, name: String) -> User {
  User(id, name)
}

pub fn get_connection(user: User) -> WebsocketConnection {
  user.connection
}

pub fn get_name(user: User) -> String {
  user.name
}
