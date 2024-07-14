import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Subject, type Selector}
import gleam/option.{type Option}
import gleam/otp/actor.{type Next}
import mist.{
  type Connection,
  type ResponseData,
  type WebsocketMessage,
  type WebsocketConnection
}
import actors/supervisor_actor.{type SupervisorQuery}

/// There is a websocket actor for each client that is connected
/// The websocket actor receives access to a subject that allows it to interface with the supervisor subject

pub fn upgrade_to_websocket(
  req: Request(Connection),
  supervisor_subject: Subject(SupervisorQuery),
  selector: Option(Selector(t)),
  on_disconnect: fn(Subject(SupervisorQuery)) -> Nil
) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) { #(supervisor_subject, selector) },
    on_close: on_disconnect,
    handler: handle_websocket_message
  )
}

fn handle_websocket_message(
  supervisor_subject: Subject(SupervisorQuery),
  connection: WebsocketConnection,
  message: WebsocketMessage(t)
) -> Next(t, Subject(SupervisorQuery)) {

}
