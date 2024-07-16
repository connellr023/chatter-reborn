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
  Closed,
  Shutdown
}
import models/user.{type User}
import actors/user_actor
import actors/actor_messages.{
  type QueueActorMessage,
  type UserActorMessage,
  EnqueueUser,
  DequeueUser,
  GetUser,
  SendSocketMessage,
  ShutdownUser
}

pub opaque type WebsocketActorState {
  WebsocketActorState(
    user_subject: Option(Subject(UserActorMessage)),
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
        user_subject: None,
        queue_subject: queue_subject
      )

      #(state, selector)
    },
    on_close: fn(state) {
      io.println("A connection was closed")
      state |> shutdown_and_dequeue_user

      Nil
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
    Text(json) -> {
      let message = json |> message.deserialize

      case message {
        Ok(message) -> case message.get_event(message) {
          "join" -> case state.user_subject {
            Some(_) -> {
              let name = message.get_body(message)
              let user = user.new(connection, name)
              let new_state = start_and_enqueue_user(user, state)

              case new_state.user_subject {
                Some(user_subject) -> {
                  let created_response = message.new("created", "User successfully created")
                  process.send(user_subject, SendSocketMessage(created_response))
                }
                None -> Nil
              }

              new_state |> actor.continue
            }
            None -> state |> actor.continue
          }
          "chat" -> case state.user_subject { // For now
            Some(_user) -> state |> actor.continue
            None -> state |> actor.continue
          }
          _ -> state |> actor.continue
        }
        Error(_) -> {
          case state.user_subject {
            Some(user_subject) -> {
              let error_response = message.new("error", "Failed to decode message")
              process.send(user_subject, SendSocketMessage(error_response))
            }
            None -> Nil
          }

          state |> actor.continue
        }
      }
    }
    Closed | Shutdown -> {
      state |> shutdown_and_dequeue_user
      Stop(Normal)
    }
    _ -> state |> actor.continue
  }
}

fn start_and_enqueue_user(user: User, state: WebsocketActorState) -> WebsocketActorState {
  let user_subject = user_actor.start(user)

  // Send message to queue actor to enqueue the new user subject
  process.send(state.queue_subject, EnqueueUser(user: user, user_subject: user_subject))

  WebsocketActorState(
    ..state,
    user_subject: Some(user_subject)
  )
}

fn shutdown_and_dequeue_user(state: WebsocketActorState) -> WebsocketActorState {
  case state.user_subject {
    Some(user_subject) -> {
      let user = process.call(user_subject, GetUser, 1000)

      process.send(state.queue_subject, DequeueUser(user))
      process.send(user_subject, ShutdownUser)

      WebsocketActorState(
        ..state,
        user_subject: None
      )
    }
    None -> state
  }
}
