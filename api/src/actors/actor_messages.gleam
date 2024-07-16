import gleam/erlang/process.{type Subject}
import models/message.{type Message}
import models/user.{type User}

pub type UserActorMessage {
  GetUser(client: Subject(User))
  JoinRoom(room_subject: Subject(RoomActorMessage))
  SendSocketMessage(message: Message)
  SendToRoom(message: Message)
  ShutdownUser
}

pub type RoomActorMessage {
  DisconnectUser(user: User)
  SendToAll(message: Message)
}

pub type QueueActorMessage {
  EnqueueUser(user: User, user_subject: Subject(UserActorMessage))
  DequeueUser(user: User)
  ShutdownQueue
}
