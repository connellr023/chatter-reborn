import gleam/io
import gleam/function
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}
import models/user.{type User}

pub opaque type UserActorState {
  UserActorState(
    user: User
    // room: ...
  )
}

/// The messages that the users actor can receive
/// It can insert a user, delete a user, or shutdown
pub type UserActorMessage {
  GetState(client: Subject(User))
  JoinRoom
  Shutdown
}

pub fn start(user: User) -> Subject(UserActorMessage) {
  io.println("Started user actor with name " <> user.get_name(user))

  let state = UserActorState(
    user: user
    // room: ...
  )

  let assert Ok(actor) = actor.start(state, handle_message)
  actor
}

fn handle_message(message: UserActorMessage, state: UserActorState) -> Next(UserActorMessage, UserActorState) {
  case message {
    Shutdown -> {
      io.println("Shutdown user actor with name " <> user.get_name(state.user))
      Stop(Normal)
    }
    _ -> state |> actor.continue
  }
}
