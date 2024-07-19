import actors/actor_messages.{
  Disconnect, DisconnectUser, JoinRoom, SendToAll, SendToClient,
}
import actors/room_actor
import gleam/erlang/process
import gleeunit/should
import models/chat
import models/socket_message

pub fn send_to_all_test() {
  let user_subject_1 = process.new_subject()
  let user_subject_2 = process.new_subject()

  let room_subject =
    room_actor.start([#("test1", user_subject_1), #("test2", user_subject_2)])

  let assert Ok(JoinRoom(_, ["test2"])) = process.receive(user_subject_1, 1000)
  let assert Ok(JoinRoom(_, ["test1"])) = process.receive(user_subject_2, 1000)

  let chat = chat.new("testuser", "hi")
  let expected_json =
    socket_message.custom_body_to_json("chat", chat |> chat.to_json)

  process.send(room_subject, SendToAll(chat))

  process.receive(user_subject_1, 1000)
  |> should.equal(Ok(SendToClient(expected_json)))

  process.receive(user_subject_2, 1000)
  |> should.equal(Ok(SendToClient(expected_json)))
}

pub fn disconnect_test() {
  let user_subject_1 = process.new_subject()
  let user_subject_2 = process.new_subject()

  let room_subject =
    room_actor.start([#("test1", user_subject_1), #("test2", user_subject_2)])

  let assert Ok(JoinRoom(_, ["test2"])) = process.receive(user_subject_1, 1000)
  let assert Ok(JoinRoom(_, ["test1"])) = process.receive(user_subject_2, 1000)

  process.send(room_subject, DisconnectUser(user_subject_1))

  process.receive(user_subject_2, 1000)
  |> should.equal(Ok(Disconnect))
}
