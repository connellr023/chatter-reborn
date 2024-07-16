import gleam/function
import models/message
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
  Custom,
  Closed,
  Shutdown
}
import actors/actor_messages.{
  type CustomWebsocketMessage,
  type RoomActorMessage,
  type QueueActorMessage,
  EnqueueUser,
  DequeueUser,
  DisconnectUser,
  JoinRoom,
  Disconnect
}

pub opaque type WebsocketActorState {
  WebsocketActorState(
    name: Option(String),
    ws_subject: Subject(CustomWebsocketMessage),
    room_subject: Option(Subject(RoomActorMessage)),
    queue_subject: Subject(QueueActorMessage)
  )
}

pub fn start(
  req: Request(Connection),
  selector: Selector(CustomWebsocketMessage),
  queue_subject: Subject(QueueActorMessage)
) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) {
      io.println("New connection initialized")

      let ws_subject = process.new_subject()
      let new_selector = selector
      |> process.selecting(ws_subject, function.identity)

      let state = WebsocketActorState(
        name: None,
        ws_subject: ws_subject,
        room_subject: None,
        queue_subject: queue_subject
      )

      #(state, Some(new_selector))
    },
    on_close: fn(state) {
      io.println("A connection was closed")
      state |> on_shutdown

      Nil
    },
    handler: handle_message
  )
}

fn handle_message(
  state: WebsocketActorState,
  connection: WebsocketConnection,
  message: WebsocketMessage(CustomWebsocketMessage)
) -> Next(CustomWebsocketMessage, WebsocketActorState) {
  case message {
    Custom(message) -> case message {
      JoinRoom(room_subject) -> {
        let new_state = WebsocketActorState(
          ..state,
          room_subject: Some(room_subject)
        )

        new_state |> actor.continue
      }
      Disconnect -> {
        io.println("disconnect")
        state |> actor.continue
      }
      _ -> state |> actor.continue
    }
    Text(json) -> {
      let message = json |> message.deserialize

      case message {
        Ok(message) -> case message.get_event(message) {
          "join" -> case state.name {
            Some(_) -> state |> actor.continue
            None -> {
              let name = message.get_body(message)
              let new_state = WebsocketActorState(
                ..state,
                name: Some(name)
              )

              let created_response = message.new("created", "User successfully created") |> message.serialize
              let assert Ok(_) = mist.send_text_frame(connection, created_response)

              on_start(new_state)
              new_state |> actor.continue
            }
          }
          "chat" -> case state.room_subject { // For now
            Some(_room_subject) -> state |> actor.continue
            None -> state |> actor.continue
          }
          _ -> state |> actor.continue
        }
        Error(_) -> {
          let error_response = message.new("error", "Failed to decode message") |> message.serialize
          let assert Ok(_) = mist.send_text_frame(connection, error_response)

          state |> actor.continue
        }
      }
    }
    Closed | Shutdown -> {
      on_shutdown(state)
      Stop(Normal)
    }
    _ -> state |> actor.continue
  }
}

fn on_start(state: WebsocketActorState) {
  process.send(state.queue_subject, EnqueueUser(state.ws_subject))
}

fn on_shutdown(state: WebsocketActorState) {
  process.send(state.queue_subject, DequeueUser(state.ws_subject))

  case state.room_subject {
    Some(room_subject) -> process.send(room_subject, DisconnectUser(state.ws_subject))
    None -> Nil
  }
}
