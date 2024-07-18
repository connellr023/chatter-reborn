import actors/actor_messages.{
  type CustomWebsocketMessage, type QueueActorMessage, DequeueUser, EnqueueUser,
}
import actors/room_actor
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/list
import gleam/otp/actor.{type Next}

pub opaque type QueueActorState {
  QueueActorState(queue: List(Subject(CustomWebsocketMessage)))
}

pub fn start() -> Subject(QueueActorMessage) {
  io.println("Queue actor started")

  let assert Ok(actor) = actor.start(QueueActorState([]), handle_message)
  actor
}

fn handle_message(
  message: QueueActorMessage,
  state: QueueActorState,
) -> Next(QueueActorMessage, QueueActorState) {
  case message {
    EnqueueUser(user_subject) -> {
      io.println("Enqueued a user")

      let new_queue = case state.queue {
        [] -> [user_subject]
        [first] -> {
          room_actor.start([first, user_subject])
          []
        }
        [first, second, ..rest] -> {
          room_actor.start([first, second])
          list.append(rest, [user_subject])
        }
      }
      let new_state = QueueActorState(queue: new_queue)

      new_state |> actor.continue
    }
    DequeueUser(user_subject) -> {
      io.println("Dequeued a user")

      let new_queue =
        list.filter(state.queue, fn(subject) { subject != user_subject })
      let new_state = QueueActorState(queue: new_queue)

      new_state |> actor.continue
    }
  }
}
