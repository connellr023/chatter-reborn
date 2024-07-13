pub opaque type User {
  User(id: Int, name: String)
}

fn new(id: Int, name: String) -> User {
  User(id, name)
}

fn get_id(user: User) -> Int {
  user.id
}

fn get_name(user: User) -> String {
  user.name
}
