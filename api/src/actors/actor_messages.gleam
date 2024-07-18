import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import models/chat.{type Chat}

pub type CustomWebsocketMessage {
  JoinRoom(room_subject: Subject(RoomActorMessage))
  SendToClient(message_json: Json)
  Disconnect
}

pub type RoomActorMessage {
  DisconnectUser(user_subject: Subject(CustomWebsocketMessage))
  SendToAll(chat: Chat)
}

pub type QueueActorMessage {
  EnqueueUser(user_subject: Subject(CustomWebsocketMessage))
  DequeueUser(user_subject: Subject(CustomWebsocketMessage))
  ShutdownQueue
}
