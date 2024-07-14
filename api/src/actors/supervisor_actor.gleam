import gleam/io
import gleam/otp/supervisor
import gleam/otp/actor.{type Next}
import gleam/erlang/process.{type Subject}
import actors/users_actor.{type UsersActorState, type UsersActorMessage}

/// The supervisor actor (this one) is the top level actor in this application
/// It will allow the websocket actor to get the current subject for a
/// worker node and request restart if something goes wrong

pub opaque type SupervisorQuery {
  FinishInit
  GetUsersActor(client: Subject(Subject(UsersActorState)))
  RestartUsersActor
}

/// State of the supervisor actor
/// For each actor, it contains its subject and a corresponding subject to the parent process (which is this one)
type SupervisorState {
  SupervisorState(
    users_actor_parent: Subject(Subject(UsersActorMessage)),
    users_actor: Subject(UsersActorMessage)
    // ...
  )
  Initializing
}

pub fn start() -> Subject(SupervisorQuery) {
  let assert Ok(actor) = actor.start(Initializing, handle_query)

  // Finish initialization in the new supervisor actor process
  process.send(actor, FinishInit)

  actor
}

/// Must be called from within the supervisor actor process
/// Returns a finalized SupervisorState variant
fn handle_init_state() -> SupervisorState {
  let users_actor_parent = process.new_subject()
  let users_actor_worker = supervisor.worker(users_actor.start(_, users_actor_parent))

  // Start supervisor
  let assert Ok(_) = supervisor.start(fn (children) {
    io.println("Supervisor started")

    children
    |> supervisor.add(users_actor_worker)
  })

  // Receive actor subjects
  let assert Ok(users_actor) = process.receive(users_actor_parent, 1000)

  SupervisorState(
    users_actor_parent: users_actor_parent,
    users_actor: users_actor
  )
}

fn handle_query(query: SupervisorQuery, state: SupervisorState) -> Next(SupervisorQuery, SupervisorState) {
  case query {
    FinishInit -> case state {
      SupervisorState(..) -> panic // The supervisor actor has already been initialized
      Initializing -> handle_init_state() |> actor.continue
    }
    _ -> panic // For now
  }
}
