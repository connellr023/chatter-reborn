import gleam/io
import gleam/list
import gleam/otp/actor.{type Next, Stop}
import gleam/erlang/process.{type Subject, Normal}
import actors/actor_messages.{
  type UserActorMessage,
  type QueueActorMessage,
  EnqueueUser,
  DequeueUser,
  ShutdownQueue
}

pub fn start() -> Subject(QueueActorMessage) {
  io.println("Queue actor started")

  let assert Ok(actor) = actor.start([], handle_message)
  actor
}

fn handle_message(
  message: QueueActorMessage,
  queue: List(Subject(UserActorMessage))
) -> Next(QueueActorMessage, List(Subject(UserActorMessage))) {
  case message {
    EnqueueUser(_user_subject) -> queue |> actor.continue
    DequeueUser(user_subject) -> {
      let new_queue = list.filter(queue, fn(s) {s != user_subject})
      new_queue |> actor.continue
    }
    ShutdownQueue -> Stop(Normal)
  }
}
