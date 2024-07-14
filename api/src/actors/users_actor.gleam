import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type Next}
import gleam/dict.{type Dict}
import models/user.{type User}

/// The state of the users actor
/// It encapsulates a map of user id to user
pub type UsersActorState {
  UsersActorState(users: Dict(Int, User))
}

fn insert_user(state: UsersActorState, user: User) -> UsersActorState {
  let new_users = dict.insert(state.users, user.get_id(user), user)
  UsersActorState(new_users)
}

fn delete_user(state: UsersActorState, id: Int) -> UsersActorState {
  let new_users = dict.delete(state.users, id)
  UsersActorState(new_users)
}

/// The messages that the users actor can receive
/// It can insert a user, delete a user, or shutdown
pub opaque type UsersActorMessage {
  InsertUser(user: User)
  DeleteUser(id: Int)
  Shutdown
}

pub fn start() -> Result(Subject(UsersActorMessage), _) {
  actor.start(UsersActorState(dict.new()), handle_message)
}

fn handle_message(message: UsersActorMessage, state: UsersActorState) -> Next(UsersActorMessage, UsersActorState) {
  case message {
    InsertUser(user) -> insert_user(state, user) |> actor.continue
    DeleteUser(id) -> delete_user(state, id) |> actor.continue
    Shutdown -> actor.Stop(process.Normal)
  }
}
