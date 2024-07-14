import gleam/set.{type Set}
import models/user.{type User}
import models/room.{type Room}

pub opaque type RoomsActorState {
  RoomsActorState(
    queued_users: List(User),
    rooms: Set(Room)
  )
}
