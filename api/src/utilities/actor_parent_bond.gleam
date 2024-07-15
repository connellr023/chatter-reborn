import gleam/erlang/process.{type Subject}

pub type ActorParentBond(m) = #(Subject(m), Subject(Subject(m)))
