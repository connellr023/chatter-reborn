import gleam/io
import gleam/option.{type Option, Some, None}
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/user.{type User}
import actors/actor_messages.{
  type RoomActorMessage,
  type UserActorMessage,
  DisconnectUser,
  ShutdownUser
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

fn handle_message(message: UserActorMessage, state: UserActorState) -> Next(UserActorMessage, UserActorState) {
  case message {
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
    _ -> state |> actor.continue
  }
}
