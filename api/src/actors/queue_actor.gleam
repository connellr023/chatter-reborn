import actors/room_actor
import gleam/io
import gleam/list
import gleam/otp/actor.{type Next, Stop}
import gleam/erlang/process.{type Subject, Normal}
import models/user.{type User}
import actors/actor_messages.{
  type UserActorMessage,
  type QueueActorMessage,
  EnqueueUser,
  DequeueUser,
  ShutdownQueue
}

pub opaque type QueueActorState {
  QueueActorState(queue: List(#(User, Subject(UserActorMessage))))
}

pub fn start() -> Subject(QueueActorMessage) {
  io.println("Queue actor started")

  let assert Ok(actor) = actor.start(QueueActorState([]), handle_message)
  actor
}

fn handle_message(
  message: QueueActorMessage,
  state: QueueActorState
) -> Next(QueueActorMessage, QueueActorState) {
  case message {
    EnqueueUser(user, user_subject) -> {
      let new_queue = case state.queue {
        [] -> [#(user, user_subject)]
        [first] -> {
          room_actor.start([first, #(user, user_subject)])
          []
        }
        [first, second, ..rest] -> {
          room_actor.start([first, second])
          list.append(rest, [#(user, user_subject)])
        }
      }
      let new_state = QueueActorState(queue: new_queue)

      new_state |> actor.continue
    }
    DequeueUser(user) -> {
      let new_queue = list.filter(state.queue, fn(tuple) {tuple.0 != user})
      let new_state = QueueActorState(queue: new_queue)

      new_state |> actor.continue
    }
    ShutdownQueue -> Stop(Normal)
  }
}
