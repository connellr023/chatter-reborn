import models/user.{type User}

pub opaque type Room {
  Room(id: Int, participants: List(User))
}

pub fn new(id: Int, participants: List(User)) -> Room {
  Room(id, participants)
}

pub fn get_id(room: Room) -> Int {
  room.id
}

pub fn get_participants(room: Room) -> List(User) {
  room.participants
}
