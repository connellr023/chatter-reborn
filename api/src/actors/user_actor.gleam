import gleam/io
import gleam/function
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Spec, Ready, Stop}
import models/user.{type User}

/// The messages that the users actor can receive
/// It can insert a user, delete a user, or shutdown
pub type UserActorMessage {
  GetState(client: Subject(User))
  Shutdown
}

pub fn start(
  _input: Nil,
  initial_state: User,
  parent_subject: Subject(Subject(UserActorMessage))
) -> Result(Subject(UserActorMessage), _) {
  actor.start_spec(Spec(
    init: fn() {
      // Create a users actor subject and send it to the parent process
      let actor_subject = process.new_subject()
      process.send(parent_subject, actor_subject)

      // Initialize a selector for receiving messages
      let selector = process.new_selector()
      |> process.selecting(actor_subject, function.identity)

      io.println("Started user actor with name " <> user.get_name(initial_state))
      Ready(initial_state, selector)
    },
    init_timeout: 1000,
    loop: handle_message
  ))
}

fn handle_message(message: UserActorMessage, state: User) -> Next(UserActorMessage, User) {
  case message {
    Shutdown -> {
      io.println("Shutdown user actor with name " <> user.get_name(state))
      Stop(Normal)
    }
    _ -> state |> actor.continue
  }
}
