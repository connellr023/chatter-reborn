import actors/actor_messages.{DequeueUser, EnqueueUser, JoinRoom}
import actors/queue_actor
import gleam/erlang/process
import gleeunit/should

pub fn enqueue_exactly_one_user_test() {
  let user_subject = process.new_subject()
  let queue_subject = queue_actor.start()

  process.send(queue_subject, EnqueueUser("test", user_subject))

  process.receive(user_subject, 200)
  |> should.be_error
}

pub fn enqueue_two_users_test() {
  let user_subject_1 = process.new_subject()
  let user_subject_2 = process.new_subject()

  let queue_subject = queue_actor.start()

  process.send(queue_subject, EnqueueUser("test1", user_subject_1))
  process.send(queue_subject, EnqueueUser("test2", user_subject_2))

  let assert Ok(JoinRoom(room_subject, ["test2"])) =
    process.receive(user_subject_1, 1000)

  process.receive(user_subject_2, 1000)
  |> should.equal(Ok(JoinRoom(room_subject, ["test1"])))
}

pub fn dequeue_user_test() {
  let user_subject_1 = process.new_subject()
  let user_subject_2 = process.new_subject()

  let queue_subject = queue_actor.start()

  process.send(queue_subject, EnqueueUser("test1", user_subject_1))
  process.send(queue_subject, DequeueUser(user_subject_1))

  process.send(queue_subject, EnqueueUser("test2", user_subject_2))

  process.receive(user_subject_2, 200)
  |> should.be_error
}
