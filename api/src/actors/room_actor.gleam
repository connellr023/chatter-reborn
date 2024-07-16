import gleam/io
import gleam/list
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/chat.{type Chat}
import models/user.{type User}
import actors/actor_messages.{
  type UserActorMessage,
  type RoomActorMessage,
  DisconnectUser,
  SendSocketMessage,
  SendToAll,
  JoinRoom
}

pub opaque type RoomActorState {
  RoomActorState(
    participants: List(#(User, Subject(UserActorMessage))),
    messages: List(Chat)
  )
}

pub fn start(participants: List(#(User, Subject(UserActorMessage)))) -> Subject(RoomActorMessage) {
  io.println("Started new room actor")

  let state = RoomActorState(
    participants: participants,
    messages: []
  )

  let assert Ok(actor) = actor.start(state, handle_message)

  // Tell participants they have been put into a room
  list.each(participants, fn(participant) {
    process.send(participant.1, JoinRoom(room_subject: actor))
  })

  actor
}

fn handle_message(
  message: RoomActorMessage,
  state: RoomActorState
) -> Next(RoomActorMessage, RoomActorState) {
  case message {
    SendToAll(message) -> {
      list.each(state.participants, fn(participant) {
        process.send(participant.1, SendSocketMessage(message))
      })

      actor.continue(state)
    }
    DisconnectUser(user) -> {
      io.println("Disconnected user with name " <> user.get_name(user) <> " from a room")

      let new_state = RoomActorState(
        ..state,
        participants: list.filter(state.participants, fn(tuple) {tuple.0 != user})
      )

      // Close the room if one or no participants left
      case new_state.participants {
        [] | [_] -> Stop(Normal)
        _ -> new_state |> actor.continue
      }
    }
  }
}
