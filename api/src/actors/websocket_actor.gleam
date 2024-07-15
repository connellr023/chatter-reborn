import gleam/io
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Subject, type Selector, Normal}
import gleam/option.{type Option}
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
import actors/supervisor_actor.{type SupervisorQuery}

/// There is a websocket actor for each client that is connected
/// The websocket actor receives access to a subject that allows it to interface with the supervisor actor

pub opaque type WebsocketActorState {
  WebsocketActorState(
    connection: WebsocketConnection,
    supervisor_actor: Subject(SupervisorQuery)
  )
}

pub fn upgrade_to_websocket(
  req: Request(Connection),
  supervisor_actor: Subject(SupervisorQuery),
  selector: Option(Selector(t))
) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(connection) {
      io.println("New connection initialized")

      let state = WebsocketActorState(
        connection: connection,
        supervisor_actor: supervisor_actor
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
