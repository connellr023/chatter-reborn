pub opaque type User {
  User(id: Int, name: String)
}

pub fn new(id: Int, name: String) -> User {
  User(id, name)
}

pub fn get_id(user: User) -> Int {
  user.id
}

pub fn get_name(user: User) -> String {
  user.name
}
