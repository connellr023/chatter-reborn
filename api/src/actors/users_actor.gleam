import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type Next}
import gleam/option.{type Option}
import gleam/dict.{type Dict}
import models/user.{type User}
import mist.{type WebsocketConnection}

/// The state of the users actor
/// It encapsulates a map of user id to user
pub opaque type UsersActorState {
  UsersActorState(users: Dict(WebsocketConnection, User))
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
  GetUser(connection: WebsocketConnection, reply: Subject(Option(User)))
  Shutdown
}

pub fn start() -> Result(Subject(UsersActorMessage), _) {
  actor.start(UsersActorState(dict.new()), handle_message)
}

fn handle_message(message: UsersActorMessage, state: UsersActorState) -> Next(UsersActorMessage, UsersActorState) {
  case message {
    InsertUser(user) -> insert_user(state, user) |> actor.continue
    DeleteUser(connection) -> delete_user(state, connection) |> actor.continue
    GetUser(connection, client) -> {
      process.send(client, get_user(state, connection))
      state |> actor.continue
    }
    Shutdown -> process.Normal |> actor.Stop
  }
}
