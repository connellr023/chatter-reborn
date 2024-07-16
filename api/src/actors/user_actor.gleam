import mist
import models/message
import gleam/io
import gleam/option.{type Option, Some, None}
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/user.{type User}
import actors/actor_messages.{
  type RoomActorMessage,
  type UserActorMessage,
  DisconnectUser,
  JoinRoom,
  GetUser,
  SendSocketMessage,
  SendToRoom,
  ShutdownUser,
  SendToAll
}

pub opaque type UserActorState {
  UserActorState(
    user: User,
    room_subject: Option(Subject(RoomActorMessage))
  )
}

pub fn start(user: User) -> Subject(UserActorMessage) {
  io.println("Started user actor with name " <> user.get_name(user))

  let state = UserActorState(
    user: user,
    room_subject: None
  )

  let assert Ok(actor) = actor.start(state, handle_message)
  actor
}

fn handle_message(
  message: UserActorMessage,
  state: UserActorState
) -> Next(UserActorMessage, UserActorState) {
  case message {
    GetUser(client) -> {
      process.send(client, state.user)
      state |> actor.continue
    }
    JoinRoom(room_subject) -> {
      let new_state = UserActorState(
        ..state,
        room_subject: Some(room_subject)
      )

      new_state |> actor.continue
    }
    SendSocketMessage(message) -> {
      let json_string = message |> message.serialize
      let assert Ok(_) = mist.send_text_frame(user.get_connection(state.user), json_string)

      state |> actor.continue
    }
    SendToRoom(message) -> {
      case state.room_subject {
        Some(room_subject) -> process.send(room_subject, SendToAll(message))
        None -> Nil
      }

      state |> actor.continue
    }
    ShutdownUser -> {
      io.println("Shutdown user actor with name " <> user.get_name(state.user))

      // Tell room actor to disconnect this user if connected
      case state.room_subject {
        Some(room_subject) -> {
          process.send(room_subject, DisconnectUser(state.user))
        }
        None -> Nil
      }

      Stop(Normal)
    }
  }
}
