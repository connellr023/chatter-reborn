import gleam/erlang/process.{type Subject}
import models/message.{type Message}
import mist.{type WebsocketMessage}

pub type CustomWebsocketMessage {
  JoinRoom(room_subject: Subject(RoomActorMessage))
  SendToRoom(message: Message)
  SendToClient(message: Message)
  Disconnect
}

pub type RoomActorMessage {
  DisconnectUser(user_subject: Subject(CustomWebsocketMessage))
  SendToAll(message: Message)
}

pub type QueueActorMessage {
  EnqueueUser(user_subject: Subject(CustomWebsocketMessage))
  DequeueUser(user_subject: Subject(CustomWebsocketMessage))
  ShutdownQueue
}
