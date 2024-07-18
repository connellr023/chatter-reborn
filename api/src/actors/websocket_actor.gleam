import gleam/function
import gleam/io
import gleam/json.{type Json}
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
import models/socket_message
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

        send_client_json(
          connection,
          socket_message.new("joined", "You have joined a room")
          |> socket_message.to_json
        )

        new_state |> actor.continue
      }
      SendToClient(message_json) -> {
        send_client_json(connection, message_json)
        state |> actor.continue
      }
      Disconnect -> {
        request_enqueue(connection, state)
        state |> actor.continue
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

              request_enqueue(connection, state)
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
          send_client_json(
            connection,
            socket_message.new("error", "Failed to decode message")
            |> socket_message.to_json
          )

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

fn send_client_json(connection: WebsocketConnection, json: Json) {
  let response = json |> json.to_string
  let assert Ok(_) = mist.send_text_frame(connection, response)

  Nil
}

fn request_enqueue(connection: WebsocketConnection, state: WebsocketActorState) {
  process.send(state.queue_subject, EnqueueUser(state.ws_subject))
  send_client_json(
    connection,
    socket_message.new("enqueued", "User successfully enqueued")
    |> socket_message.to_json
  )
}

fn cleanup(state: WebsocketActorState) {
  process.send(state.queue_subject, DequeueUser(state.ws_subject))

  option.then(state.room_subject, fn(room_subject) {
    Some(process.send(room_subject, DisconnectUser(state.ws_subject)))
  })
}
