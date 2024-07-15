import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}
import gleam/dict.{type Dict}
import models/user.{type User}
import models/room.{type Room}
import actors/supervisor_actor.{type SupervisorQuery}

pub opaque type RoomsActorState {
  RoomsActorState(
    queued_users: List(User),
    room_id_counter: Int,
    rooms: Dict(Int, Room)
  )
}

pub opaque type RoomsActorMessage {
  /// Enqueues a new user
  /// Access to supervisor actor is required to update the user's room ID in the users actor
  EnqueueUser(user: User, supervisor_actor: Subject(SupervisorQuery))

  /// Deletes a user from the queue and its room (if its in one)
  /// Responds with None if the participants in the room after deletion is > 1
  /// Otherwise, responds with the only user left in the room wrapped in a Some variant
  DeleteUser(user: User, client: Subject(Option(User)))
}
