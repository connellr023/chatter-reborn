import gleam/erlang/process.{type Subject}
import models/user.{type User}

pub type UserActorMessage {
  JoinRoom(room_subject: Subject(RoomActorMessage))
  ShutdownUser
}

pub type RoomActorMessage {
  ConnectUser(user: User)
  DisconnectUser(user: User)
}

pub type QueueActorMessage {
  EnqueueUser(user_subject: Subject(UserActorMessage))
  DequeueUser(user_subject: Subject(UserActorMessage))
  ShutdownQueue
}
