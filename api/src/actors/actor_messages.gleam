import gleam/erlang/process.{type Subject}
import models/socket_message.{type SocketMessage}
import models/chat.{type Chat}

pub type CustomWebsocketMessage {
  JoinRoom(room_subject: Subject(RoomActorMessage))
  SendToRoom(chat: Chat)
  SendToClient(message: SocketMessage)
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
