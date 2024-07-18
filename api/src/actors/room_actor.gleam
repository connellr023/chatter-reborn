import gleam/io
import gleam/list
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/chat
import models/socket_message
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
  RoomActorState(participants: List(Subject(CustomWebsocketMessage)))
}

pub fn start(participants: List(Subject(CustomWebsocketMessage))) -> Subject(RoomActorMessage) {
  io.println("Started new room actor")

  let state = RoomActorState(participants: participants)
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
    SendToAll(chat) -> {
      let body_json = chat |> chat.to_json
      let message_json = socket_message.custom_body_to_json("chat", body_json)

      list.each(state.participants, fn(participant) {
        process.send(participant, SendToClient(message_json))
      })

      state |> actor.continue
    }
    DisconnectUser(user_subject) -> {
      let new_state = RoomActorState(
        participants: list.filter(state.participants, fn(subject) {
          case subject != user_subject {
            True -> True
            False -> {
              io.println("Disconnected a user from a room")
              False
            }
          }
        })
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
