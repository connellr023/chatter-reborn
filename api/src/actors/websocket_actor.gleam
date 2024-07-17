import gleam/function
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
  Custom
}
import models/socket_message.{type SocketMessage}
import models/chat
import actors/actor_messages.{
  type CustomWebsocketMessage,
  type RoomActorMessage,
  type QueueActorMessage,
  EnqueueUser,
  DequeueUser,
  DisconnectUser,
  JoinRoom,
  SendToClient,
  Disconnect,
  SendToAll
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
      state |> cleanup

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
      SendToClient(message) -> {
        send_client_message(connection, message)
        state |> actor.continue
      }
      Disconnect -> {
        option.then(state.name, fn(name) { Some(io.println("Disconnected " <> name)) })

        cleanup(state)
        Stop(Normal)
      }
    }
    Text(json) -> {
      let message = json |> socket_message.deserialize

      case message {
        Ok(message) -> case socket_message.get_event(message) {
          "join" -> case state.name {
            Some(_) -> state |> actor.continue
            None -> {
              let name = socket_message.get_body(message)
              let new_state = WebsocketActorState(
                ..state,
                name: Some(name)
              )

              process.send(state.queue_subject, EnqueueUser(state.ws_subject))
              send_client_message(connection, socket_message.new("enqueued", "User successfully created and enqueued"))

              new_state |> actor.continue
            }
          }
          "chat" -> {
            {
              use room_subject <- option.then(state.room_subject)
              use name <- option.then(state.name)

              let content = socket_message.get_body(message)
              let chat = chat.new(name, content)

              Some(process.send(room_subject, SendToAll(chat)))
            }

            state |> actor.continue
          }
          _ -> state |> actor.continue
        }
        Error(_) -> {
          send_client_message(connection, socket_message.new("error", "Failed to decode message"))
          state |> actor.continue
        }
      }
    }
    _ -> {
      cleanup(state)
      Stop(Normal)
    }
  }
}

fn send_client_message(connection: WebsocketConnection, message: SocketMessage) {
  let response = message |> socket_message.serialize
  let assert Ok(_) = mist.send_text_frame(connection, response)

  Nil
}

fn cleanup(state: WebsocketActorState) {
  process.send(state.queue_subject, DequeueUser(state.ws_subject))

  option.then(state.room_subject, fn(room_subject) {
    Some(process.send(room_subject, DisconnectUser(state.ws_subject)))
  })
}
