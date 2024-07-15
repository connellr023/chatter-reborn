import gleam/otp/supervisor
import gleam/io
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Subject, type Selector, Normal}
import gleam/option.{type Option, Some, None}
import gleam/otp/actor.{type Next, Stop}
import mist.{
  type Connection,
  type ResponseData,
  type WebsocketMessage,
  type WebsocketConnection,
  Text,
  Closed,
  Shutdown
}
import actors/queue_actor.{type QueueActorMessage}
import actors/user_actor.{type UserActorMessage}
import models/user.{type User}
import utilities/actor_parent_bond.{type ActorParentBond}

pub opaque type WebsocketActorState {
  WebsocketActorState(
    user: Option(ActorParentBond(UserActorMessage)),
    queue_subject: Subject(QueueActorMessage)
  )
}

pub fn start(
  req: Request(Connection),
  selector: Option(Selector(t)),
  queue_subject: Subject(QueueActorMessage)
) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) {
      io.println("New connection initialized")

      let state = WebsocketActorState(
        user: None,
        queue_subject: queue_subject
      )

      #(state, selector)
    },
    on_close: fn(_state) {
      io.println("A connection was closed")
    },
    handler: handle_websocket_message
  )
}

fn handle_websocket_message(
  state: WebsocketActorState,
  connection: WebsocketConnection,
  message: WebsocketMessage(t)
) -> Next(t, WebsocketActorState) {
  case message {
    Text(text) -> {
      // TODO: Decode JSON
      io.println(text)

      state |> actor.continue
    }
    Closed | Shutdown -> Stop(Normal)
    _ -> state |> actor.continue
  }
}

fn set_user_subject(user: User, state: WebsocketActorState) -> WebsocketActorState {
  let parent_subject = process.new_subject()
  let user_worker = supervisor.worker(user_actor.start(_, user, parent_subject))

  // Start supervisor
  let assert Ok(_) = supervisor.start(supervisor.add(_,  user_worker))

  // Receive subject
  let assert Ok(user_subject) = process.receive(parent_subject, 1000)

  WebsocketActorState(
    ..state,
    user: Some(#(user_subject, parent_subject))
  )
}
