import actors/actor_messages.{
  type CustomWebsocketMessage, type RoomActorMessage, Disconnect, DisconnectUser,
  JoinRoom, SendToAll, SendToClient,
}
import gleam/erlang/process.{type Subject, Normal}
import gleam/io
import gleam/list
import gleam/otp/actor.{type Next, Stop}
import models/chat
import models/socket_message

pub opaque type RoomActorState {
  RoomActorState(participants: List(#(String, Subject(CustomWebsocketMessage))))
}

pub fn start(
  participants: List(#(String, Subject(CustomWebsocketMessage))),
) -> Subject(RoomActorMessage) {
  io.println("Started new room actor")

  let state = RoomActorState(participants: participants)
  let assert Ok(actor) = actor.start(state, handle_message)

  // Tell participants they have been put into a room
  list.each(participants, fn(participant) {
    process.send(
      participant.1,
      JoinRoom(
        room_subject: actor,
        participants: participants
          |> list.filter_map(fn(p) {
            case p.1 != participant.1 {
              True -> Ok(p.0)
              False -> Error(Nil)
            }
          }),
      ),
    )
  })

  actor
}

fn handle_message(
  message: RoomActorMessage,
  state: RoomActorState,
) -> Next(RoomActorMessage, RoomActorState) {
  case message {
    SendToAll(chat) -> {
      let body_json = chat |> chat.to_json
      let message_json = socket_message.custom_body_to_json("chat", body_json)

      list.each(state.participants, fn(p) {
        process.send(p.1, SendToClient(message_json))
      })

      state |> actor.continue
    }
    DisconnectUser(user_subject) -> {
      let new_state =
        RoomActorState(
          participants: list.filter(state.participants, fn(p) {
            case p.1 != user_subject {
              True -> True
              False -> {
                io.println("Disconnected a user from a room")
                False
              }
            }
          }),
        )

      // Close the room if one or no participants left
      case new_state.participants {
        [] -> {
          io.println("No participants left. Closed a room actor")
          Stop(Normal)
        }
        [participant] -> {
          io.println("Only one participant left. Closed a room actor")

          process.send(participant.1, Disconnect)
          Stop(Normal)
        }
        _ -> new_state |> actor.continue
      }
    }
  }
}
