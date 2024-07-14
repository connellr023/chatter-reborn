import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Subject, type Selector}
import gleam/option.{type Option}
import gleam/otp/actor.{type Next}
import actors/users_actor.{type UsersActorMessage}
import mist.{
  type Connection,
  type ResponseData,
  type WebsocketMessage,
  type WebsocketConnection
}

pub type WebsocketActorState {
  WebsocketActorState(
    users_actor: Subject(UsersActorMessage)
    // ...
  )
}

pub fn upgrade_to_websocket(req: Request(Connection), initial_state: WebsocketActorState, selector: Option(Selector(t)), on_disconnect: fn(WebsocketActorState) -> Nil) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) { #(initial_state, selector) },
    on_close: on_disconnect,
    handler: handle_websocket_message
  )
}

fn handle_websocket_message(state: WebsocketActorState, connection: WebsocketConnection, message: WebsocketMessage(t)) -> Next(t, WebsocketActorState) {

}
