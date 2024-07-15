import gleam/io
import gleam/list
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/chat.{type Chat}
import models/user.{type User}
import actors/actor_messages.{
  type RoomActorMessage,
  ConnectUser,
  DisconnectUser
}

pub opaque type RoomActorState {
  RoomActorState(
    participants: List(User),
    messages: List(Chat)
  )
}

pub fn start() -> Subject(RoomActorMessage) {
  io.println("Started new room actor")

  let state = RoomActorState(
    participants: [],
    messages: []
  )

  let assert Ok(actor) = actor.start(state, handle_message)
  actor
}

fn handle_message(
  message: RoomActorMessage,
  state: RoomActorState
) -> Next(RoomActorMessage, RoomActorState) {
  case message {
    ConnectUser(user) -> {
      io.println("Connected user with name " <> user.get_name(user) <> " to a room")

      let new_state = RoomActorState(
        ..state,
        participants: [user, ..state.participants]
      )

      new_state |> actor.continue
    }
    DisconnectUser(user) -> {
      io.println("Disconnected user with name " <> user.get_name(user) <> " from a room")

      let new_state = RoomActorState(
        ..state,
        participants: list.filter(state.participants, fn(u) {u != user})
      )

      case new_state.participants {
        [] | [_] -> Stop(Normal)
        _ -> new_state |> actor.continue
      }
    }
  }
}
