import actors/actor_messages.{
  type CustomWebsocketMessage, type QueueActorMessage, type RoomActorMessage,
  DequeueUser, Disconnect, DisconnectUser, EnqueueUser, JoinRoom, SendToAll,
  SendToClient,
}
import gleam/erlang/process.{type Selector, type Subject, Normal}
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/otp/actor.{type Next, Stop}
import gleam/regex
import gleam/string
import mist.{
  type Connection, type ResponseData, type WebsocketConnection,
  type WebsocketMessage, Custom, Text,
}
import models/chat
import models/socket_message

pub opaque type WebsocketActorState {
  WebsocketActorState(
    name: Option(String),
    ws_subject: Subject(CustomWebsocketMessage),
    room_subject: Option(Subject(RoomActorMessage)),
    queue_subject: Subject(QueueActorMessage),
  )
}

pub fn start(
  req: Request(Connection),
  selector: Selector(CustomWebsocketMessage),
  queue_subject: Subject(QueueActorMessage),
) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) {
      io.println("New connection initialized")

      let ws_subject = process.new_subject()
      let new_selector =
        selector
        |> process.selecting(ws_subject, function.identity)

      let state =
        WebsocketActorState(
          name: None,
          ws_subject: ws_subject,
          room_subject: None,
          queue_subject: queue_subject,
        )

      #(state, Some(new_selector))
    },
    on_close: fn(state) {
      io.println("A connection was closed")
      state |> cleanup

      Nil
    },
    handler: handle_message,
  )
}

fn handle_message(
  state: WebsocketActorState,
  connection: WebsocketConnection,
  message: WebsocketMessage(CustomWebsocketMessage),
) -> Next(CustomWebsocketMessage, WebsocketActorState) {
  case message {
    Custom(message) ->
      case message {
        JoinRoom(room_subject, participants) -> {
          let new_state =
            WebsocketActorState(..state, room_subject: Some(room_subject))

          send_client_json(
            connection,
            socket_message.custom_body_to_json(
              "joined",
              json.array(participants, of: json.string),
            ),
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
        Ok(message) ->
          case socket_message.get_event(message) {
            "join" ->
              case state.name {
                Some(_) -> state |> actor.continue
                None -> {
                  let assert Ok(name_pattern) =
                    regex.from_string("^[a-zA-Z0-9]{3,16}$")
                  let name = socket_message.get_body(message)

                  case
                    regex.check(name_pattern, name) && !string.is_empty(name)
                  {
                    True -> {
                      let new_state =
                        WebsocketActorState(..state, name: Some(name))

                      request_enqueue(connection, new_state)
                      new_state |> actor.continue
                    }
                    False -> {
                      send_client_json(
                        connection,
                        socket_message.new("error", "Invalid name received")
                          |> socket_message.to_json,
                      )

                      state |> actor.continue
                    }
                  }
                }
              }
            "chat" -> {
              {
                use room_subject <- option.then(state.room_subject)
                use name <- option.then(state.name)

                let content = socket_message.get_body(message)
                let assert Ok(chat_pattern) =
                  regex.from_string("^[a-zA-Z0-9 .,!?'\"@#%^&*()_+-=;:~`]*$")

                case
                  regex.check(chat_pattern, content)
                  && !string.is_empty(content)
                {
                  True -> {
                    let chat = chat.new(name, content)
                    Some(process.send(room_subject, SendToAll(chat)))
                  }
                  False -> None
                }
              }

              state |> actor.continue
            }
            "skip" -> {
              let new_state = cleanup(state)
              request_enqueue(connection, new_state)

              new_state |> actor.continue
            }
            "disconnect" -> {
              let new_state = cleanup(state)
              let new_state = WebsocketActorState(
                ..new_state,
                name: None
              )

              new_state |> actor.continue
            }
            _ -> state |> actor.continue
          }
        Error(_) -> {
          send_client_json(
            connection,
            socket_message.new("error", "Failed to decode message")
              |> socket_message.to_json,
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

/// Sends a request to the queue actor to enqueue this actor to be matched
fn request_enqueue(connection: WebsocketConnection, state: WebsocketActorState) {
  {
    use name <- option.then(state.name)

    process.send(state.queue_subject, EnqueueUser(name, state.ws_subject))
    Some(send_client_json(
      connection,
      socket_message.new("enqueued", "User successfully enqueued")
        |> socket_message.to_json,
    ))
  }

  Nil
}

/// Cleans up any connections this actor has with the queue and room actors
/// Returns an updated state reflecting the removal of these connections
fn cleanup(state: WebsocketActorState) -> WebsocketActorState {
  {
    use _ <- option.then(state.name)
    Some(process.send(state.queue_subject, DequeueUser(state.ws_subject)))
  }

  case state.room_subject {
    Some(room_subject) -> {
      process.send(room_subject, DisconnectUser(state.ws_subject))

      WebsocketActorState(
        ..state,
        room_subject: None
      )
    }
    None -> state
  }
}
