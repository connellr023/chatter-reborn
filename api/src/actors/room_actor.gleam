import gleam/io
import gleam/list
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import mist.{type WebsocketMessage, Custom}
import models/chat.{type Chat}
import actors/actor_messages.{
  type CustomWebsocketMessage,
  type RoomActorMessage,
  DisconnectUser,
  SendToClient,
  SendToAll,
  JoinRoom,
  Disconnect
}

pub opaque type RoomActorState {
  RoomActorState(
    participants: List(Subject(CustomWebsocketMessage)),
    messages: List(Chat)
  )
}

pub fn start(participants: List(Subject(CustomWebsocketMessage))) -> Subject(RoomActorMessage) {
  io.println("Started new room actor")

  let state = RoomActorState(
    participants: participants,
    messages: []
  )

  let assert Ok(actor) = actor.start(state, handle_message)

  // Tell participants they have been put into a room
  list.each(participants, fn(participant) {
    process.send(participant, JoinRoom(room_subject: actor))
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
        process.send(participant, SendToClient(message))
      })

      actor.continue(state)
    }
    DisconnectUser(user_subject) -> {
      io.println("Disconnected a user from a room")

      let new_state = RoomActorState(
        ..state,
        participants: list.filter(state.participants, fn(subject) {subject != user_subject})
      )

      // Close the room if one or no participants left
      case new_state.participants {
        [] -> {
          Stop(Normal)
        }
        [subject] -> {
          process.send(subject, Disconnect)
          Stop(Normal)
        }
        _ -> new_state |> actor.continue
      }
    }
  }
}
