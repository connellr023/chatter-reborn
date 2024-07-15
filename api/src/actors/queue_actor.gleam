import gleam/io
import gleam/otp/actor.{type Next, Stop}
import gleam/erlang/process.{type Subject, Normal}
import actors/user_actor.{type UserActorMessage}

const participants_per_room: Int = 2

pub type QueueActorMessage {
  /// Enqueues a new user subject
  EnqueueUser(user: Subject(UserActorMessage))

  /// Removes a user subject from the queue (can be done out of order)
  DequeueUser(user: Subject(UserActorMessage))

  Shutdown
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
    Shutdown -> Stop(Normal)
    _ -> queue |> actor.continue
  }
}
