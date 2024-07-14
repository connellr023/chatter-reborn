import gleam/io
import gleam/function
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Spec, Ready, Stop}
import gleam/option.{type Option}
import gleam/dict.{type Dict}
import models/user.{type User}
import mist.{type WebsocketConnection}

/// The state of the users actor
/// It encapsulates a map of user id to user
pub opaque type UsersActorState {
  UsersActorState(users: Dict(WebsocketConnection, User))
}

fn new_state() -> UsersActorState {
  UsersActorState(dict.new())
}

fn insert_user(state: UsersActorState, user: User) -> UsersActorState {
  let new_users = dict.insert(state.users, user.get_connection(user), user)
  UsersActorState(new_users)
}

fn delete_user(state: UsersActorState, connection: WebsocketConnection) -> UsersActorState {
  let new_users = dict.delete(state.users, connection)
  UsersActorState(new_users)
}

fn get_user(state: UsersActorState, connection: WebsocketConnection) -> Option(User) {
  dict.get(state.users, connection) |> option.from_result
}

/// The messages that the users actor can receive
/// It can insert a user, delete a user, or shutdown
pub opaque type UsersActorMessage {
  InsertUser(user: User)
  DeleteUser(connection: WebsocketConnection)
  GetUser(
    connection: WebsocketConnection,
    client: Subject(Option(User))
  )
  Shutdown
}

pub fn start(_input: Nil, parent_subject: Subject(Subject(UsersActorMessage))) -> Result(Subject(UsersActorMessage), _) {
  actor.start_spec(Spec(
    init: fn() {
      // Create a users actor subject and send it to the parent process
      let actor_subject = process.new_subject()
      process.send(parent_subject, actor_subject)

      // Initialize a selector for receiving messages
      let selector = process.new_selector()
      |> process.selecting(actor_subject, function.identity)

      io.println("Users Actor started")
      Ready(new_state(), selector)
    },
    init_timeout: 1000,
    loop: handle_message
  ))
}

fn handle_message(message: UsersActorMessage, state: UsersActorState) -> Next(UsersActorMessage, UsersActorState) {
  case message {
    InsertUser(user) -> insert_user(state, user) |> actor.continue
    DeleteUser(connection) -> delete_user(state, connection) |> actor.continue
    GetUser(connection, client) -> {
      process.send(client, get_user(state, connection))
      state |> actor.continue
    }
    Shutdown -> Stop(Normal)
  }
}
