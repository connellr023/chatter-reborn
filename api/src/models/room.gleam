import gleam/list
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

pub fn add_participant(room: Room, user: User) -> Room {
  Room(..room, participants: list.prepend(room.participants, user))
}

pub fn delete_participant(room: Room, user: User) -> Room {
  Room(..room, participants: list.filter(room.participants, fn(u) { u != user }))
}
